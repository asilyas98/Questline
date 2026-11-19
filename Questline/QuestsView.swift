import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var store: GameStore
    @State private var adding = false
    @State private var proof: ProofTarget?

    var body: some View {
        let active = store.s.quests.filter { !$0.done }
        let won = store.s.quests.filter { $0.done }

        Screen {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Main quests", actionLabel: "+ New quest") { adding = true }
                if active.isEmpty {
                    EmptyNote("A quest is a real goal broken into checkable milestones. Start one.")
                }
                ForEach(active) { q in QuestCard(quest: q, proof: $proof) }
            }
            .card()

            if !won.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Hall of victories")
                    ForEach(won) { q in QuestCard(quest: q, proof: $proof) }
                }
                .card()
            }
        }
        .sheet(isPresented: $adding) { AddQuestSheet() }
        .sheet(item: $proof) { p in ProofSheet(target: p) }
    }
}

struct QuestCard: View {
    @EnvironmentObject var store: GameStore
    let quest: Quest
    @Binding var proof: ProofTarget?
    @State private var confirmDelete = false

    var body: some View {
        let n = quest.milestones.filter { $0.done }.count
        let all = max(quest.milestones.count, 1)
        let ready = n == quest.milestones.count
        let daysLeft: Int? = quest.deadline.isEmpty ? nil : Day.daysBetween(Day.today(), quest.deadline)

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text((quest.done ? "🏆 " : "") + quest.name)
                        .font(.headline)
                        .foregroundColor(Theme.text)
                    HStack(spacing: 8) {
                        StatTag(stat: quest.stat)
                        Text(DIFFICULTY[quest.diff] ?? "").meta()
                        Text("\(n)/\(quest.milestones.count)").meta()
                        if let d = daysLeft, !quest.done {
                            Text(d < 0 ? "\(-d)d overdue" : "\(d)d left")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(d < 0 ? Theme.bad : (d < 8 ? Theme.fire : Theme.muted))
                        }
                        if quest.done, let dd = quest.doneDate {
                            Text("Won \(dd)").font(.caption).foregroundColor(Theme.gold)
                        }
                    }
                }
                Spacer()
                Menu {
                    Button(role: .destructive) { confirmDelete = true } label: { Label("Delete quest", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis").foregroundColor(Theme.muted).padding(6)
                }
            }

            if !quest.why.isEmpty {
                Text("“\(quest.why)”").font(.footnote.italic()).foregroundColor(Theme.muted)
            }

            XPBar(value: Double(n) / Double(all), color: quest.stat.color, height: 8)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(quest.milestones) { m in
                    HStack(spacing: 10) {
                        CheckBox(done: m.done, size: 22) {
                            guard !quest.done else { return }
                            if m.done {
                                store.uncheckMilestone(questID: quest.id, milestoneID: m.id)
                            } else {
                                proof = .milestone(quest: quest, milestone: m)
                            }
                        }
                        .disabled(quest.done)
                        Text(m.text)
                            .font(.subheadline)
                            .strikethrough(m.done)
                            .foregroundColor(m.done ? Theme.muted : Theme.text)
                    }
                }
            }
            .padding(.top, 4)

            if !quest.done {
                Button {
                    proof = .boss(quest: quest)
                } label: {
                    Text(ready ? "⚔️ FIGHT THE FINAL BOSS" : "🔒 BOSS LOCKED · \(quest.milestones.count - n) TO GO")
                        .font(.subheadline.monospaced().weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(LinearGradient(colors: [Theme.bad, Theme.fire], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(Color(hex: 0x1A0B0E))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .opacity(ready ? 1 : 0.3)
                        .saturation(ready ? 1 : 0)
                }
                .buttonStyle(.plain)
                .disabled(!ready)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(quest.done
                    ? AnyShapeStyle(LinearGradient(colors: [Theme.gold.opacity(0.1), Theme.panel2], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(Theme.panel2))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(quest.done ? Theme.gold : Theme.line, lineWidth: 1))
        .confirmationDialog("Delete “\(quest.name)”? Its XP history stays in your journal.", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete quest", role: .destructive) { store.deleteQuest(quest.id) }
        }
    }
}
