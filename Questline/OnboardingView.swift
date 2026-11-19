import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var picks: Set<String> = ["fitness", "learn"]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Text("QUESTLINE")
                        .font(.caption.monospaced().weight(.bold))
                        .tracking(2)
                        .foregroundColor(Theme.xp2)
                    Text("Your life is the game.")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    Text("Real goals become quests. Daily habits earn XP. Five stats show who you're becoming. Spend gold on rewards you've actually earned.")
                        .font(.subheadline)
                        .foregroundColor(Theme.muted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)

                VStack(alignment: .leading, spacing: 12) {
                    FieldLabel("What should we call you, hero?")
                    TextField("Your name", text: $name)
                        .textInputAutocapitalization(.words)
                        .input()

                    FieldLabel("Pick what you want to work on — we'll set up starter quests you can edit later")
                        .padding(.top, 6)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(TEMPLATES) { t in
                            let on = picks.contains(t.id)
                            Button {
                                if on { picks.remove(t.id) } else { picks.insert(t.id) }
                                Haptics.light()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(t.questStat.icon) \(t.name)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(Theme.text)
                                    Text("\(t.quest) + \(t.habits.count) habits")
                                        .font(.caption)
                                        .foregroundColor(Theme.muted)
                                }
                                .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
                                .padding(12)
                                .background(on ? Theme.xp.opacity(0.15) : Theme.panel2)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(on ? Theme.xp : Theme.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Begin my adventure ⚔️") {
                        store.startAdventure(name: name, picks: picks)
                    }
                    .buttonStyle(PrimaryButton(fullWidth: true))
                    .padding(.top, 6)

                    Button("or start with a blank slate") {
                        store.startAdventure(name: name, picks: [])
                    }
                    .font(.footnote)
                    .foregroundColor(Theme.xp2)
                    .frame(maxWidth: .infinity)
                }
                .card()
            }
            .padding(16)
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}
