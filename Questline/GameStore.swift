import SwiftUI
import UIKit

/// All game logic. XP, gold and stat levels are derived from the log, so undo is exact.
final class GameStore: ObservableObject {
    @Published var s: GameState { didSet { save() } }
    @Published var levelUpTo: Int? = nil
    @Published var toast: String? = nil
    private var toastID = 0

    private static let fileURL: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("questline.json")

    init() {
        if let data = try? Data(contentsOf: GameStore.fileURL),
           let state = try? JSONDecoder().decode(GameState.self, from: data) {
            s = state
        } else {
            s = GameState()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(s) else { return }
        try? data.write(to: GameStore.fileURL, options: .atomic)
    }

    // MARK: Derived values

    var totalXP: Int { s.log.reduce(0) { $0 + $1.xp } }
    var gold: Int { s.log.reduce(0) { $0 + $1.gold } }

    static func levelInfo(_ xp: Int) -> (lvl: Int, cur: Int, need: Int) {
        var lvl = 1, need = 100, rem = xp
        while rem >= need { rem -= need; lvl += 1; need = 100 + (lvl - 1) * 60 }
        return (lvl, rem, need)
    }
    static func title(_ lvl: Int) -> String { TITLES[min(TITLES.count - 1, (lvl - 1) / 3)] }

    func statXP(_ k: StatKind) -> Int {
        s.log.filter { $0.stat == k && $0.xp > 0 }.reduce(0) { $0 + $1.xp }
    }
    static func statLevel(_ xp: Int) -> Int { Int((Double(xp) / 40).squareRoot()) + 1 }
    static func statProgress(_ xp: Int) -> (lvl: Int, pct: Double) {
        let l = statLevel(xp)
        let a = 40 * (l - 1) * (l - 1), b = 40 * l * l
        return (l, Double(xp - a) / Double(b - a))
    }

    func streak(_ h: Habit) -> Int {
        let set = Set(h.done)
        var d = Day.today()
        if !set.contains(d) { d = Day.add(d, -1) }
        var n = 0
        while set.contains(d) { n += 1; d = Day.add(d, -1) }
        return n
    }
    var bestStreak: Int { s.habits.map(streak).max() ?? 0 }
    static func multiplier(_ streak: Int) -> Double { 1 + min(0.5, Double(streak / 7) * 0.1) }
    static func habitXP(_ h: Habit, streak: Int) -> Int { Int((10 * Double(h.diff) * multiplier(streak)).rounded()) }

    var challenge: DailyChallenge {
        var h: UInt32 = 0
        for c in Day.today().unicodeScalars { h = h &* 31 &+ c.value }
        return DAILY_CHALLENGES[Int(h % UInt32(DAILY_CHALLENGES.count))]
    }
    var challengeDoneToday: Bool { s.challengeDone[Day.today()] != nil }

    // MARK: XP

    private func award(xp: Int, stat: StatKind?, label: String, type: String, ref: String? = nil, note: String = "", goldMul: Double = 0.5) {
        let before = Self.levelInfo(totalXP).lvl
        s.log.append(LogEntry(type: type, label: label, xp: xp, gold: Int((Double(xp) * goldMul).rounded()),
                              stat: stat, ref: ref, note: note))
        let after = Self.levelInfo(totalXP).lvl
        if after > before {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation { self.levelUpTo = after }
                Haptics.success()
            }
        }
    }
    private func unaward(_ match: (LogEntry) -> Bool) {
        if let i = s.log.firstIndex(where: match) { s.log.remove(at: i) }
    }

    // MARK: Actions

    func toggleHabit(_ id: String) {
        guard let i = s.habits.firstIndex(where: { $0.id == id }) else { return }
        let d = Day.today()
        if s.habits[i].done.contains(d) {
            s.habits[i].done.removeAll { $0 == d }
            unaward { $0.ref == id && $0.date == d && $0.type == "habit" }
            Haptics.light()
        } else {
            s.habits[i].done.append(d)
            let h = s.habits[i]
            let st = streak(h)
            award(xp: Self.habitXP(h, streak: st), stat: h.stat, label: h.name, type: "habit", ref: id)
            Haptics.medium()
            if st > 1 && st % 7 == 0 { show("🔥 \(st)-day streak on “\(h.name)” — XP bonus up!") }
        }
        checkAchievements()
    }

    func toggleTask(_ id: String) {
        guard let i = s.tasks.firstIndex(where: { $0.id == id }) else { return }
        if s.tasks[i].done {
            s.tasks[i].done = false
            unaward { $0.ref == id && $0.type == "task" }
            Haptics.light()
        } else {
            s.tasks[i].done = true
            let t = s.tasks[i]
            award(xp: 15 * t.diff, stat: t.stat, label: t.name, type: "task", ref: id)
            Haptics.medium()
        }
        checkAchievements()
    }

    func completeMilestone(questID: String, milestoneID: String, note: String) {
        guard let qi = s.quests.firstIndex(where: { $0.id == questID }),
              let mi = s.quests[qi].milestones.firstIndex(where: { $0.id == milestoneID }),
              !s.quests[qi].done else { return }
        s.quests[qi].milestones[mi].done = true
        let q = s.quests[qi]
        let xp = 25 * q.diff
        award(xp: xp, stat: q.stat, label: "\(q.name) → \(q.milestones[mi].text)", type: "milestone", ref: milestoneID, note: note)
        Haptics.success()
        show("✅ +\(xp) XP · milestone cleared")
        checkAchievements()
    }

    func uncheckMilestone(questID: String, milestoneID: String) {
        guard let qi = s.quests.firstIndex(where: { $0.id == questID }),
              let mi = s.quests[qi].milestones.firstIndex(where: { $0.id == milestoneID }),
              !s.quests[qi].done else { return }
        s.quests[qi].milestones[mi].done = false
        unaward { $0.ref == milestoneID }
        Haptics.light()
    }

    func slayBoss(questID: String, note: String) {
        guard let qi = s.quests.firstIndex(where: { $0.id == questID }) else { return }
        s.quests[qi].done = true
        s.quests[qi].doneDate = Day.today()
        let q = s.quests[qi]
        let xp = 120 * q.diff
        award(xp: xp, stat: q.stat, label: "QUEST COMPLETE: \(q.name)", type: "quest", ref: questID, note: note, goldMul: 1)
        Haptics.success()
        show("🏆 Quest complete! +\(xp) XP, +\(xp) gold")
        checkAchievements()
    }

    func toggleChallenge() {
        let d = Day.today()
        if challengeDoneToday {
            s.challengeDone.removeValue(forKey: d)
            unaward { $0.type == "challenge" && $0.date == d }
            Haptics.light()
        } else {
            s.challengeDone[d] = 1
            let c = challenge
            award(xp: 30, stat: c.stat, label: "Daily challenge: \(c.text)", type: "challenge")
            Haptics.medium()
        }
        checkAchievements()
    }

    func buy(_ id: String) {
        guard let r = s.rewards.first(where: { $0.id == id }), gold >= r.cost else { return }
        s.log.append(LogEntry(type: "reward", label: "Claimed: \(r.name)", xp: 0, gold: -r.cost))
        Haptics.success()
        show("🎁 Enjoy it — you earned “\(r.name)”")
        checkAchievements()
    }

    func addHabit(_ h: Habit) { s.habits.append(h) }
    func addTask(_ t: SideTask) { s.tasks.append(t) }
    func addQuest(_ q: Quest) { s.quests.append(q) }
    func addReward(_ r: Reward) { s.rewards.append(r) }

    func deleteHabit(_ id: String) { s.habits.removeAll { $0.id == id } }
    func deleteTask(_ id: String) { s.tasks.removeAll { $0.id == id } }
    func deleteQuest(_ id: String) { s.quests.removeAll { $0.id == id } }
    func deleteReward(_ id: String) { s.rewards.removeAll { $0.id == id } }

    func startAdventure(name: String, picks: Set<String>) {
        var st = GameState()
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        st.name = n.isEmpty ? "Hero" : n
        for t in TEMPLATES where picks.contains(t.id) {
            for h in t.habits { st.habits.append(Habit(name: h.0, stat: h.1, diff: h.2)) }
            st.quests.append(Quest(name: t.quest, why: t.why, stat: t.questStat, diff: t.questDiff,
                                   milestones: t.milestones.map { Milestone(text: $0) }))
        }
        st.rewards = [Reward(name: "Favorite treat / takeout", cost: 80),
                      Reward(name: "Guilt-free gaming or show night", cost: 150),
                      Reward(name: "Buy something I've wanted", cost: 600)]
        st.tasks = [SideTask(name: "Set up my first week of quests", stat: .craft, diff: 1)]
        s = st
        Haptics.success()
        show("⚔️ Your adventure begins")
    }

    func reset() {
        Reminders.cancel()
        s = GameState()
    }

    // MARK: Backup (same JSON as the web app)

    func exportJSON() -> String {
        guard let d = try? JSONEncoder().encode(s) else { return "{}" }
        return String(decoding: d, as: UTF8.self)
    }

    func importJSON(_ text: String) -> Bool {
        guard let data = text.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
              let state = try? JSONDecoder().decode(GameState.self, from: data),
              !state.name.isEmpty || !state.log.isEmpty else { return false }
        s = state
        refreshReminders()
        return true
    }

    // MARK: Reminders

    func setReminder(on: Bool) {
        if on {
            Reminders.requestPermission { granted in
                if granted {
                    self.s.reminderOn = true
                    self.refreshReminders()
                    self.show("🔔 Daily reminder set")
                } else {
                    self.s.reminderOn = false
                    self.show("Allow notifications for Questline in Settings")
                }
            }
        } else {
            s.reminderOn = false
            Reminders.cancel()
        }
    }

    func setReminderTime(hour: Int, minute: Int) {
        s.reminderHour = hour
        s.reminderMinute = minute
        refreshReminders()
    }

    func refreshReminders() {
        if s.reminderOn { Reminders.schedule(hour: s.reminderHour, minute: s.reminderMinute) }
    }

    // MARK: Achievements & feedback

    func checkAchievements() {
        func give(_ id: String) {
            guard s.ach[id] == nil else { return }
            s.ach[id] = Day.today()
            if let a = ACHIEVEMENTS.first(where: { $0.id == id }) {
                show("🏅 Achievement: \(a.emoji) \(a.name)")
                Haptics.success()
            }
        }
        if s.log.contains(where: { $0.xp > 0 }) { give("first") }
        let bs = bestStreak
        if bs >= 3 { give("streak3") }
        if bs >= 7 { give("streak7") }
        if bs >= 30 { give("streak30") }
        let lvl = Self.levelInfo(totalXP).lvl
        if lvl >= 5 { give("lvl5") }
        if lvl >= 10 { give("lvl10") }
        if s.quests.contains(where: { $0.done }) { give("boss") }
        let today = Day.today()
        if s.habits.count >= 2 && s.habits.allSatisfy({ $0.done.contains(today) }) { give("perfect") }
        if StatKind.allCases.allSatisfy({ Self.statLevel(statXP($0)) >= 2 }) { give("balanced") }
        if s.log.contains(where: { $0.type == "reward" }) { give("treat") }
        if totalXP >= 1000 { give("xp1000") }
        let notes = s.log.filter { ($0.note ?? "").trimmingCharacters(in: .whitespaces).count > 3 }.count
        if notes >= 10 { give("honest") }
    }

    func show(_ message: String) {
        toastID += 1
        let id = toastID
        withAnimation(.spring(response: 0.35)) { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            if self.toastID == id { withAnimation { self.toast = nil } }
        }
    }
}

enum Haptics {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
