import SwiftUI

@main
struct QuestlineApp: App {
    @StateObject private var store = GameStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active { store.refreshReminders() }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if store.s.name.isEmpty {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabs()
                    .transition(.opacity)
            }

            if let message = store.toast {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(Theme.panel2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
                        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 70)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .allowsHitTesting(false)
                .zIndex(5)
            }

            if let level = store.levelUpTo {
                LevelUpView(level: level) { withAnimation { store.levelUpTo = nil } }
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.s.name.isEmpty)
    }
}

struct MainTabs: View {
    init() {
        let a = UITabBarAppearance()
        a.configureWithOpaqueBackground()
        a.backgroundColor = UIColor(Theme.panel)
        UITabBar.appearance().standardAppearance = a
        UITabBar.appearance().scrollEdgeAppearance = a
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "bolt.fill") }
            QuestsView()
                .tabItem { Label("Quests", systemImage: "map.fill") }
            CharacterView()
                .tabItem { Label("Character", systemImage: "person.crop.circle.fill") }
            ShopView()
                .tabItem { Label("Rewards", systemImage: "gift.fill") }
            JournalView()
                .tabItem { Label("Journal", systemImage: "book.closed.fill") }
        }
        .tint(Theme.xp2)
    }
}

struct HUDView: View {
    @EnvironmentObject var store: GameStore
    @State private var showProfile = false

    var body: some View {
        let info = GameStore.levelInfo(store.totalXP)
        let avatar = AVATARS[min(max(store.s.avatar, 0), AVATARS.count - 1)]

        HStack(spacing: 14) {
            Button { showProfile = true } label: {
                Text(avatar)
                    .font(.system(size: 28))
                    .frame(width: 54, height: 54)
                    .background(LinearGradient(colors: [Theme.xp, Theme.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(store.s.name).font(.headline).foregroundColor(Theme.text).lineLimit(1)
                    Text(GameStore.title(info.lvl))
                        .font(.caption.monospaced().weight(.bold))
                        .foregroundColor(Theme.xp2)
                    Spacer(minLength: 0)
                    Text("LV \(info.lvl)")
                        .font(.caption.monospaced().weight(.bold))
                        .foregroundColor(Theme.muted)
                }
                XPBar(value: Double(info.cur) / Double(info.need))
                Text("\(info.cur) / \(info.need) XP to level \(info.lvl + 1)")
                    .font(.caption2)
                    .foregroundColor(Theme.muted)
            }

            VStack(alignment: .trailing, spacing: 4) {
                Text("🪙 \(store.gold)").font(.subheadline.weight(.bold)).foregroundColor(Theme.gold)
                Text("🔥 \(store.bestStreak)").font(.subheadline.weight(.bold)).foregroundColor(Theme.fire)
            }
        }
        .card()
        .sheet(isPresented: $showProfile) { ProfileSheet() }
    }
}

struct LevelUpView: View {
    let level: Int
    let onClose: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()
                .onTapGesture(perform: onClose)
            VStack(spacing: 14) {
                Text("LEVEL \(level)!")
                    .font(.system(size: 46, weight: .black, design: .monospaced))
                    .foregroundColor(Theme.gold)
                    .shadow(color: Theme.gold.opacity(0.6), radius: 24)
                    .scaleEffect(appear ? 1 : 0.3)
                (Text("You are now a ") + Text(GameStore.title(level)).bold().foregroundColor(Theme.xp2))
                    .font(.title3)
                    .foregroundColor(Theme.text)
                Text("Real progress. Real you.")
                    .font(.footnote)
                    .foregroundColor(Theme.muted)
                Button("Keep going", action: onClose)
                    .buttonStyle(PrimaryButton())
                    .padding(.top, 10)
            }
            .padding(30)
        }
        .transition(.opacity)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.5)) { appear = true }
        }
    }
}
