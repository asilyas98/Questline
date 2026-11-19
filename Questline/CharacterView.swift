import SwiftUI
import Charts

struct DayXP: Identifiable {
    let id: String
    let label: String
    let xp: Int
}

struct CharacterView: View {
    @EnvironmentObject var store: GameStore
    @State private var showProfile = false
    @State private var showBackup = false
    @State private var confirmReset = false

    var body: some View {
        let today = Day.today()
        let days: [DayXP] = (0..<14).map { i in
            let k = Day.add(today, i - 13)
            let xp = store.s.log.filter { $0.date == k && $0.xp > 0 }.reduce(0) { $0 + $1.xp }
            return DayXP(id: k, label: String(k.suffix(2)), xp: xp)
        }

        Screen {
            // Stats
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Stats")
                ForEach(StatKind.allCases) { k in
                    let p = GameStore.statProgress(store.statXP(k))
                    HStack(spacing: 12) {
                        Text(k.icon)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(k.color.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(k.name).font(.subheadline.weight(.semibold)).foregroundColor(Theme.text)
                                Text("· \(k.hint)").font(.caption).foregroundColor(Theme.muted).lineLimit(1)
                                Spacer()
                                Text("LV\(p.lvl)").font(.caption.monospaced().weight(.bold)).foregroundColor(k.color)
                            }
                            XPBar(value: p.pct, color: k.color, height: 8)
                        }
                    }
                }
            }
            .card()

            // Chart
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Last 14 days")
                Chart(days) { d in
                    BarMark(x: .value("Day", d.label), y: .value("XP", d.xp))
                        .foregroundStyle(LinearGradient(colors: [Theme.xp, Theme.xp2], startPoint: .bottom, endPoint: .top))
                        .cornerRadius(4)
                }
                .frame(height: 150)
                HStack(spacing: 14) {
                    Text("Total XP: \(store.totalXP)").meta()
                    Text("Quests won: \(store.s.quests.filter { $0.done }.count)").meta()
                    Text("Best streak: \(store.bestStreak)").meta()
                }
            }
            .card()

            // Achievements
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Achievements · \(store.s.ach.count)/\(ACHIEVEMENTS.count)")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                    ForEach(ACHIEVEMENTS) { a in
                        let unlocked = store.s.ach[a.id] != nil
                        VStack(spacing: 4) {
                            Text(a.emoji).font(.system(size: 28))
                            Text(a.name).font(.caption.weight(.bold)).foregroundColor(Theme.text)
                            Text(a.desc).font(.caption2).foregroundColor(Theme.muted).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 96)
                        .padding(8)
                        .background(Theme.panel2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
                        .opacity(unlocked ? 1 : 0.35)
                        .saturation(unlocked ? 1 : 0)
                    }
                }
            }
            .card()

            ReminderCard()

            // Settings
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Settings")
                HStack(spacing: 8) {
                    Button("Edit character") { showProfile = true }.buttonStyle(GhostButton())
                    Button("Backup / restore") { showBackup = true }.buttonStyle(GhostButton())
                    Button("Reset") { confirmReset = true }.buttonStyle(GhostButton(textColor: Theme.bad))
                }
            }
            .card()
        }
        .sheet(isPresented: $showProfile) { ProfileSheet() }
        .sheet(isPresented: $showBackup) { BackupSheet() }
        .confirmationDialog("Reset ALL progress? This cannot be undone.", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset everything", role: .destructive) { store.reset() }
        }
    }
}

struct ReminderCard: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        let isOn = Binding<Bool>(
            get: { store.s.reminderOn },
            set: { store.setReminder(on: $0) }
        )
        let time = Binding<Date>(
            get: { Calendar.current.date(from: DateComponents(hour: store.s.reminderHour, minute: store.s.reminderMinute)) ?? Date() },
            set: {
                let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                store.setReminderTime(hour: c.hour ?? 8, minute: c.minute ?? 0)
            }
        )

        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Daily reminder")
            Toggle(isOn: isOn) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remind me every day").foregroundColor(Theme.text)
                    Text("Includes the quote of the day").font(.caption).foregroundColor(Theme.muted)
                }
            }
            .tint(Theme.xp)
            if store.s.reminderOn {
                DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                    .foregroundColor(Theme.text)
            }
        }
        .card()
    }
}
