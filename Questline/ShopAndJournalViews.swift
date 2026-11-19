import SwiftUI

struct ShopView: View {
    @EnvironmentObject var store: GameStore
    @State private var adding = false

    var body: some View {
        let g = store.gold
        let rewards = store.s.rewards.sorted { $0.cost < $1.cost }

        Screen {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Reward shop · 🪙 \(g)", actionLabel: "+ Reward") { adding = true }
                Text("Set real rewards and price them honestly. Only claim them once you can afford them — that's the deal.")
                    .font(.caption)
                    .foregroundColor(Theme.muted)
                if rewards.isEmpty { EmptyNote("Add something you'd genuinely enjoy.") }
                ForEach(rewards) { r in
                    let affordable = g >= r.cost
                    HStack(spacing: 12) {
                        Text("🎁").font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.name).fontWeight(.semibold).foregroundColor(Theme.text)
                            Text(affordable ? "Affordable!" : "\(r.cost - g) more gold needed")
                                .font(.caption)
                                .foregroundColor(affordable ? Theme.good : Theme.muted)
                        }
                        Spacer(minLength: 0)
                        Button("🪙 \(r.cost)") { store.buy(r.id) }
                            .buttonStyle(PrimaryButton(color: Theme.gold, textColor: Color(hex: 0x241A00)))
                            .disabled(!affordable)
                            .opacity(affordable ? 1 : 0.35)
                    }
                    .row()
                    .contextMenu {
                        Button(role: .destructive) { store.deleteReward(r.id) } label: { Label("Delete reward", systemImage: "trash") }
                    }
                }
            }
            .card()
        }
        .sheet(isPresented: $adding) { AddRewardSheet() }
    }
}

struct JournalView: View {
    @EnvironmentObject var store: GameStore

    private func icon(_ type: String) -> String {
        switch type {
        case "habit": return "✅"
        case "task": return "📌"
        case "milestone": return "🚩"
        case "quest": return "🏆"
        case "challenge": return "🎯"
        case "reward": return "🎁"
        default: return "•"
        }
    }

    var body: some View {
        let items = Array(store.s.log.reversed().prefix(200))

        Screen {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: "Adventure journal").padding(.bottom, 10)
                if items.isEmpty {
                    EmptyNote("Your wins will show up here — proof that you're changing.")
                }
                ForEach(items) { l in
                    HStack(alignment: .top, spacing: 10) {
                        Text(icon(l.type))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(l.label).font(.subheadline).foregroundColor(Theme.text)
                            if let note = l.note, !note.isEmpty {
                                Text("“\(note)”").font(.caption).foregroundColor(Theme.muted)
                            }
                            Text(l.date + (l.stat.map { " · \($0.name)" } ?? "")).font(.caption2).foregroundColor(Theme.muted)
                        }
                        Spacer(minLength: 0)
                        Text(l.gold < 0 ? "−\(-l.gold) 🪙" : "+\(l.xp) XP")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(l.gold < 0 ? Theme.gold : Theme.xp2)
                    }
                    .padding(.vertical, 9)
                    Divider().background(Theme.line)
                }
            }
            .card()
        }
    }
}
