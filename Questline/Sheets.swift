import SwiftUI
import UIKit

// MARK: - Scaffold shared by every sheet

struct SheetScaffold<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let confirm: String?
    let canConfirm: Bool
    let onConfirm: () -> Void
    let content: Content

    init(title: String, confirm: String? = nil, canConfirm: Bool = true,
         onConfirm: @escaping () -> Void = {}, @ViewBuilder content: () -> Content) {
        self.title = title
        self.confirm = confirm
        self.canConfirm = canConfirm
        self.onConfirm = onConfirm
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { content }
                    .padding(18)
            }
            .background(Theme.panel.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(confirm == nil ? "Done" : "Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if let confirm = confirm {
                        Button(confirm) { onConfirm(); dismiss() }
                            .fontWeight(.bold)
                            .disabled(!canConfirm)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}

struct StatPicker: View {
    @Binding var stat: StatKind
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(StatKind.allCases) { k in
                Button { stat = k; Haptics.light() } label: {
                    Text("\(k.icon) \(k.name)")
                        .font(.subheadline)
                        .foregroundColor(Theme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(stat == k ? Theme.xp.opacity(0.2) : Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(stat == k ? Theme.xp : Theme.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DifficultyPicker: View {
    @Binding var diff: Int
    var body: some View {
        Picker("Difficulty", selection: $diff) {
            ForEach(1...3, id: \.self) { d in Text(DIFFICULTY[d] ?? "").tag(d) }
        }
        .pickerStyle(.segmented)
    }
}

private func clean(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }

// MARK: - Add sheets

struct AddHabitSheet: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var stat: StatKind = .body
    @State private var diff = 1

    var body: some View {
        SheetScaffold(title: "New daily habit", confirm: "Add", canConfirm: !clean(name).isEmpty, onConfirm: {
            store.addHabit(Habit(name: clean(name), stat: stat, diff: diff))
        }) {
            FieldLabel("Habit")
            TextField("e.g. Walk 20 minutes", text: $name).input()
            FieldLabel("Which stat does it train?")
            StatPicker(stat: $stat)
            FieldLabel("How hard is it for you?")
            DifficultyPicker(diff: $diff)
            Text("Easy = 10 XP · Medium = 20 · Hard = 30. Streaks add up to +50%.").meta()
        }
    }
}

struct AddTaskSheet: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var stat: StatKind = .craft
    @State private var diff = 1

    var body: some View {
        SheetScaffold(title: "New side quest", confirm: "Add", canConfirm: !clean(name).isEmpty, onConfirm: {
            store.addTask(SideTask(name: clean(name), stat: stat, diff: diff))
        }) {
            FieldLabel("One-time task")
            TextField("e.g. Book the dentist appointment", text: $name).input()
            FieldLabel("Stat")
            StatPicker(stat: $stat)
            FieldLabel("Difficulty")
            DifficultyPicker(diff: $diff)
            Text("Easy = 15 XP · Medium = 30 · Hard = 45.").meta()
        }
    }
}

struct AddQuestSheet: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var why = ""
    @State private var milestones = ""
    @State private var hasDeadline = false
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var stat: StatKind = .body
    @State private var diff = 2

    private var steps: [String] {
        Array(milestones.split(whereSeparator: \.isNewline).map { clean(String($0)) }.filter { !$0.isEmpty }.prefix(15))
    }

    var body: some View {
        SheetScaffold(title: "New main quest", confirm: "Start", canConfirm: !clean(name).isEmpty && !steps.isEmpty, onConfirm: {
            store.addQuest(Quest(name: clean(name), why: clean(why),
                                 deadline: hasDeadline ? Day.key(deadline) : "",
                                 stat: stat, diff: diff,
                                 milestones: steps.map { Milestone(text: $0) }))
        }) {
            FieldLabel("The real goal")
            TextField("e.g. Run a 5K, launch my app, read 12 books", text: $name).input()
            FieldLabel("Why it matters to you")
            TextField("Shows on the quest when motivation dips", text: $why).input()
            FieldLabel("Milestones — one per line, small and checkable")
            TextField("Make a plan\nFirst 25%\nHalfway\nFinal push", text: $milestones, axis: .vertical)
                .lineLimit(5...12)
                .input()
            Toggle("Set a target date", isOn: $hasDeadline).tint(Theme.xp).foregroundColor(Theme.text)
            if hasDeadline {
                DatePicker("Target date", selection: $deadline, in: Date()..., displayedComponents: .date)
                    .foregroundColor(Theme.text)
            }
            FieldLabel("Stat")
            StatPicker(stat: $stat)
            FieldLabel("Difficulty")
            DifficultyPicker(diff: $diff)
            Text("Each milestone = 25 XP × difficulty. Beating the final boss = 120 XP × difficulty + gold.").meta()
        }
    }
}

struct AddRewardSheet: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var cost = 100

    var body: some View {
        SheetScaffold(title: "New real-life reward", confirm: "Add", canConfirm: !clean(name).isEmpty, onConfirm: {
            store.addReward(Reward(name: clean(name), cost: max(1, cost)))
        }) {
            FieldLabel("Reward")
            TextField("e.g. Movie night, new book, favorite takeout", text: $name).input()
            FieldLabel("Gold cost")
            HStack {
                TextField("100", value: $cost, format: .number)
                    .keyboardType(.numberPad)
                    .input()
                Stepper("", value: $cost, in: 1...100_000, step: 25).labelsHidden()
            }
            Text("Guilt-free: you only get it when you've earned it. Habits give ~5–15 gold each.").meta()
        }
    }
}

// MARK: - Proof (milestone / boss)

enum ProofTarget: Identifiable {
    case milestone(quest: Quest, milestone: Milestone)
    case boss(quest: Quest)

    var id: String {
        switch self {
        case .milestone(_, let m): return "m-" + m.id
        case .boss(let q): return "b-" + q.id
        }
    }
}

struct ProofSheet: View {
    @EnvironmentObject var store: GameStore
    let target: ProofTarget
    @State private var note = ""

    private var title: String {
        switch target {
        case .milestone: return "Milestone cleared"
        case .boss: return "🐲 Final boss"
        }
    }
    private var heading: String {
        switch target {
        case .milestone(_, let m): return m.text
        case .boss(let q): return q.name
        }
    }
    private var prompt: String {
        switch target {
        case .milestone: return "What did you actually do? (optional, but it makes it real)"
        case .boss: return "You did it. Write down how — future you will want to read this."
        }
    }

    var body: some View {
        SheetScaffold(title: title, confirm: "Claim XP", onConfirm: {
            let n = clean(note)
            switch target {
            case .milestone(let q, let m): store.completeMilestone(questID: q.id, milestoneID: m.id, note: n)
            case .boss(let q): store.slayBoss(questID: q.id, note: n)
            }
        }) {
            Text(heading).font(.title3.weight(.bold)).foregroundColor(Theme.text)
            FieldLabel(prompt)
            TextField("e.g. Ran 2.1 miles at the park in 24 min", text: $note, axis: .vertical)
                .lineLimit(3...8)
                .input()
        }
    }
}

// MARK: - Profile & backup

struct ProfileSheet: View {
    @EnvironmentObject var store: GameStore
    @State private var name = ""
    @State private var avatar = 0
    @State private var loaded = false

    var body: some View {
        SheetScaffold(title: "Your character", confirm: "Save", onConfirm: {
            let n = clean(name)
            if !n.isEmpty { store.s.name = n }
            store.s.avatar = avatar
        }) {
            FieldLabel("Name")
            TextField("Name", text: $name).input()
            FieldLabel("Avatar")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 8)], spacing: 8) {
                ForEach(AVATARS.indices, id: \.self) { i in
                    Button { avatar = i; Haptics.light() } label: {
                        Text(AVATARS[i])
                            .font(.system(size: 26))
                            .frame(width: 52, height: 52)
                            .background(avatar == i ? Theme.xp.opacity(0.25) : Theme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(avatar == i ? Theme.xp : Theme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            if !loaded { name = store.s.name; avatar = store.s.avatar; loaded = true }
        }
    }
}

struct BackupSheet: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var pasted = ""
    @State private var failed = false

    var body: some View {
        SheetScaffold(title: "Backup & restore") {
            Text("Your progress is saved on this iPhone. Export a backup to keep it safe or move it to another device. Backups from the Questline web app work here too.")
                .font(.subheadline)
                .foregroundColor(Theme.muted)

            HStack(spacing: 8) {
                ShareLink(item: store.exportJSON(), subject: Text("Questline backup")) {
                    Label("Share backup", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(GhostButton())
                Button {
                    UIPasteboard.general.string = store.exportJSON()
                    store.show("📋 Backup copied")
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(GhostButton())
            }

            FieldLabel("Restore: paste a backup below")
                .padding(.top, 8)
            TextField("{ … }", text: $pasted, axis: .vertical)
                .lineLimit(4...10)
                .font(.caption.monospaced())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .input()
            HStack(spacing: 8) {
                Button("Paste from clipboard") { pasted = UIPasteboard.general.string ?? "" }
                    .buttonStyle(GhostButton())
                Button("Restore") {
                    if store.importJSON(pasted) {
                        store.show("✅ Restored")
                        dismiss()
                    } else {
                        failed = true
                    }
                }
                .buttonStyle(PrimaryButton())
                .disabled(clean(pasted).isEmpty)
            }
            if failed {
                Text("⚠️ That backup isn't valid.").font(.caption).foregroundColor(Theme.bad)
            }
        }
    }
}
