import SwiftUI

struct NextStep: Identifiable {
    let quest: Quest
    let milestone: Milestone
    var id: String { milestone.id }
}

struct TodayView: View {
    @EnvironmentObject var store: GameStore
    @State private var addingHabit = false
    @State private var addingTask = false
    @State private var proof: ProofTarget?

    var body: some View {
        let today = Day.today()
        let doneCount = store.s.habits.filter { $0.done.contains(today) }.count
        let next: [NextStep] = Array(store.s.quests.filter { !$0.done }.compactMap { q in
            q.milestones.first(where: { !$0.done }).map { NextStep(quest: q, milestone: $0) }
        }.prefix(3))
        let tasks = store.s.tasks.sorted { !$0.done && $1.done }

        Screen {
            QuoteCard()
            ChallengeCard()

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Daily habits · \(doneCount)/\(store.s.habits.count)", actionLabel: "+ Habit") { addingHabit = true }
                if store.s.habits.isEmpty { EmptyNote("Add a small habit you can do daily.") }
                ForEach(store.s.habits) { h in HabitRow(habit: h) }
            }
            .card()

            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Next quest steps")
                if next.isEmpty { EmptyNote("No active quests. Start one in the Quests tab.") }
                ForEach(next) { step in
                    HStack(spacing: 12) {
                        CheckBox(done: false) {
                            proof = .milestone(quest: step.quest, milestone: step.milestone)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.milestone.text).fontWeight(.semibold).foregroundColor(Theme.text)
                            HStack(spacing: 8) {
                                StatTag(stat: step.quest.stat)
                                Text("🗺️ \(step.quest.name)").meta().lineLimit(1)
                                Text("\(25 * step.quest.diff) XP").meta()
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .row()
                }

                SectionHeader(title: "Side quests", actionLabel: "+ Task") { addingTask = true }
                    .padding(.top, 10)
                if tasks.isEmpty { EmptyNote("One-off tasks go here.") }
                ForEach(tasks) { t in
                    HStack(spacing: 12) {
                        CheckBox(done: t.done) { store.toggleTask(t.id) }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(t.name)
                                .fontWeight(.semibold)
                                .strikethrough(t.done)
                                .foregroundColor(t.done ? Theme.muted : Theme.text)
                            HStack(spacing: 8) {
                                StatTag(stat: t.stat)
                                Text("\(15 * t.diff) XP").meta()
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .row()
                    .contextMenu {
                        Button(role: .destructive) { store.deleteTask(t.id) } label: { Label("Delete task", systemImage: "trash") }
                    }
                }
                Text("Tip: long-press a habit or task to delete it.").font(.caption2).foregroundColor(Theme.muted).padding(.top, 4)
            }
            .card()
        }
        .sheet(isPresented: $addingHabit) { AddHabitSheet() }
        .sheet(isPresented: $addingTask) { AddTaskSheet() }
        .sheet(item: $proof) { p in ProofSheet(target: p) }
    }
}

struct QuoteCard: View {
    var body: some View {
        let q = Quotes.forDate()
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("QUOTE OF THE DAY · \(Day.dayOfYear())/365")
                    .font(.caption2.monospaced().weight(.bold))
                    .foregroundColor(Theme.gold)
                Spacer()
                ShareLink(item: "“\(q.text)” — \(q.author)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.footnote)
                        .foregroundColor(Theme.muted)
                }
            }
            Text("“\(q.text)”")
                .font(.title3.weight(.medium))
                .foregroundColor(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
            Text("— \(q.author)")
                .font(.footnote)
                .foregroundColor(Theme.muted)
        }
        .padding(.leading, 4)
        .card()
        .overlay(alignment: .leading) {
            Rectangle().fill(Theme.gold).frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.vertical, 10)
        }
    }
}

struct ChallengeCard: View {
    @EnvironmentObject var store: GameStore
    var body: some View {
        let c = store.challenge
        HStack(spacing: 12) {
            Text(c.emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("DAILY CHALLENGE · +30 XP")
                    .font(.caption2.monospaced().weight(.bold))
                    .foregroundColor(Theme.xp2)
                Text(c.text).fontWeight(.semibold).foregroundColor(Theme.text)
            }
            Spacer(minLength: 0)
            CheckBox(done: store.challengeDoneToday) { store.toggleChallenge() }
        }
        .padding(14)
        .background(LinearGradient(colors: [Theme.xp.opacity(0.18), Theme.pink.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.xp.opacity(0.35), lineWidth: 1))
    }
}

struct HabitRow: View {
    @EnvironmentObject var store: GameStore
    let habit: Habit

    var body: some View {
        let done = habit.done.contains(Day.today())
        let st = store.streak(habit)
        let m = GameStore.multiplier(st)

        HStack(spacing: 12) {
            CheckBox(done: done) { store.toggleHabit(habit.id) }
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .fontWeight(.semibold)
                    .strikethrough(done)
                    .foregroundColor(done ? Theme.muted : Theme.text)
                HStack(spacing: 8) {
                    StatTag(stat: habit.stat)
                    Text("\(GameStore.habitXP(habit, streak: st)) XP").meta()
                    if st > 0 {
                        Text("🔥 \(st)").font(.caption.weight(.bold)).foregroundColor(Theme.fire)
                    }
                    if m > 1 {
                        Text(String(format: "×%.1f", m)).font(.caption.weight(.bold)).foregroundColor(Theme.good)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .row()
        .contextMenu {
            Button(role: .destructive) { store.deleteHabit(habit.id) } label: { Label("Delete habit", systemImage: "trash") }
        }
    }
}
