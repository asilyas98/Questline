import SwiftUI

// MARK: - Stats

enum StatKind: String, Codable, CaseIterable, Identifiable {
    case body, mind, spirit, craft, bond
    var id: String { rawValue }

    var name: String {
        switch self {
        case .body: return "Body"
        case .mind: return "Mind"
        case .spirit: return "Spirit"
        case .craft: return "Craft"
        case .bond: return "Bond"
        }
    }
    var icon: String {
        switch self {
        case .body: return "💪"
        case .mind: return "🧠"
        case .spirit: return "🕊️"
        case .craft: return "🛠️"
        case .bond: return "🤝"
        }
    }
    var hint: String {
        switch self {
        case .body: return "fitness, sleep, health"
        case .mind: return "learning, reading, focus"
        case .spirit: return "faith, calm, gratitude"
        case .craft: return "career, skills, money"
        case .bond: return "family, friends, community"
        }
    }
    var color: Color {
        switch self {
        case .body: return Color(hex: 0xFF7A59)
        case .mind: return Color(hex: 0x4CC3FF)
        case .spirit: return Color(hex: 0x3DDC97)
        case .craft: return Color(hex: 0xFFC94A)
        case .bond: return Color(hex: 0xFF6FB5)
        }
    }
}

let DIFFICULTY = [1: "Easy", 2: "Medium", 3: "Hard"]

// MARK: - Data (JSON-compatible with the Questline web app backup)

struct Habit: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var name: String
    var stat: StatKind
    var diff: Int
    var done: [String] = []
}

struct Milestone: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var text: String
    var done = false
}

struct Quest: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var name: String
    var why: String
    var deadline: String = ""
    var stat: StatKind
    var diff: Int
    var milestones: [Milestone]
    var done = false
    var doneDate: String? = nil
    var created = Day.today()
}

struct SideTask: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var name: String
    var stat: StatKind
    var diff: Int
    var done = false
}

struct Reward: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var name: String
    var cost: Int
}

struct LogEntry: Codable, Identifiable, Equatable {
    var id = UUID().uuidString
    var t: Double = Date().timeIntervalSince1970 * 1000
    var date = Day.today()
    var type: String
    var label: String
    var xp: Int
    var gold: Int
    var stat: StatKind? = nil
    var ref: String? = nil
    var note: String? = nil
}

struct GameState: Codable {
    var name = ""
    var avatar = 0
    var habits: [Habit] = []
    var quests: [Quest] = []
    var tasks: [SideTask] = []
    var rewards: [Reward] = []
    var log: [LogEntry] = []
    var ach: [String: String] = [:]
    var challengeDone: [String: Int] = [:]
    var created = Day.today()
    var reminderOn = false
    var reminderHour = 8
    var reminderMinute = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        avatar = try c.decodeIfPresent(Int.self, forKey: .avatar) ?? 0
        habits = try c.decodeIfPresent([Habit].self, forKey: .habits) ?? []
        quests = try c.decodeIfPresent([Quest].self, forKey: .quests) ?? []
        tasks = try c.decodeIfPresent([SideTask].self, forKey: .tasks) ?? []
        rewards = try c.decodeIfPresent([Reward].self, forKey: .rewards) ?? []
        log = try c.decodeIfPresent([LogEntry].self, forKey: .log) ?? []
        ach = try c.decodeIfPresent([String: String].self, forKey: .ach) ?? [:]
        challengeDone = try c.decodeIfPresent([String: Int].self, forKey: .challengeDone) ?? [:]
        created = try c.decodeIfPresent(String.self, forKey: .created) ?? Day.today()
        reminderOn = try c.decodeIfPresent(Bool.self, forKey: .reminderOn) ?? false
        reminderHour = try c.decodeIfPresent(Int.self, forKey: .reminderHour) ?? 8
        reminderMinute = try c.decodeIfPresent(Int.self, forKey: .reminderMinute) ?? 0
    }
}

// MARK: - Game content

let TITLES = ["Wanderer", "Apprentice", "Seeker", "Adventurer", "Pathfinder", "Veteran", "Champion", "Hero", "Legend", "Mythic"]
let AVATARS = ["🧙", "🦸", "🥷", "🧝", "🦊", "🐉", "🦁", "🚀", "⚔️", "🌟"]

struct Achievement: Identifiable { let id: String; let emoji: String; let name: String; let desc: String }

let ACHIEVEMENTS: [Achievement] = [
    Achievement(id: "first", emoji: "👣", name: "First Step", desc: "Log your first win"),
    Achievement(id: "streak3", emoji: "🔥", name: "Kindling", desc: "3-day habit streak"),
    Achievement(id: "streak7", emoji: "⚡", name: "On Fire", desc: "7-day habit streak"),
    Achievement(id: "streak30", emoji: "🌋", name: "Unstoppable", desc: "30-day habit streak"),
    Achievement(id: "lvl5", emoji: "⭐", name: "Rising", desc: "Reach level 5"),
    Achievement(id: "lvl10", emoji: "🌟", name: "Ascended", desc: "Reach level 10"),
    Achievement(id: "boss", emoji: "🐲", name: "Boss Slayer", desc: "Complete a main quest"),
    Achievement(id: "perfect", emoji: "💎", name: "Perfect Day", desc: "Finish every habit in a day"),
    Achievement(id: "balanced", emoji: "☯️", name: "Balanced", desc: "All 5 stats at level 2+"),
    Achievement(id: "treat", emoji: "🎁", name: "Earned It", desc: "Claim a real reward"),
    Achievement(id: "xp1000", emoji: "🏆", name: "Grinder", desc: "Earn 1,000 total XP"),
    Achievement(id: "honest", emoji: "📜", name: "Chronicler", desc: "Write 10 proof notes")
]

struct QuestTemplate: Identifiable {
    let id: String
    let name: String
    let why: String
    let habits: [(String, StatKind, Int)]
    let quest: String
    let questStat: StatKind
    let questDiff: Int
    let milestones: [String]
}

let TEMPLATES: [QuestTemplate] = [
    QuestTemplate(id: "fitness", name: "Get in shape", why: "Feel strong and have energy",
                  habits: [("Workout 20+ min", .body, 2), ("Drink 8 glasses of water", .body, 1)],
                  quest: "Run a 5K", questStat: .body, questDiff: 3,
                  milestones: ["Run 1 mile without stopping", "Run 2 miles", "Run 3 miles in training", "Sign up for a race", "Finish the 5K"]),
    QuestTemplate(id: "learn", name: "Learn a skill", why: "Grow into who I want to be",
                  habits: [("Study 30 min", .mind, 2), ("Read 10 pages", .mind, 1)],
                  quest: "Finish an online course", questStat: .mind, questDiff: 3,
                  milestones: ["Pick the course", "Complete 25%", "Complete 50%", "Complete 75%", "Finish + build a project"]),
    QuestTemplate(id: "faith", name: "Spiritual growth", why: "Peace and closeness to God",
                  habits: [("Pray on time", .spirit, 2), ("Read / reflect 10 min", .spirit, 1), ("Write 3 gratitudes", .spirit, 1)],
                  quest: "Memorize a new surah / passage", questStat: .spirit, questDiff: 3,
                  milestones: ["Choose it", "Memorize the first third", "Memorize two thirds", "Recite it fully from memory"]),
    QuestTemplate(id: "career", name: "Level up career", why: "Freedom and stability",
                  habits: [("Deep work block (90 min)", .craft, 3), ("No phone first hour", .mind, 1)],
                  quest: "Ship a side project", questStat: .craft, questDiff: 3,
                  milestones: ["Write the one-page plan", "Build the MVP", "Get 3 people to try it", "Launch publicly"]),
    QuestTemplate(id: "social", name: "Strengthen relationships", why: "The people I love matter most",
                  habits: [("Text / call someone I care about", .bond, 1), ("Phone-free dinner", .bond, 1)],
                  quest: "Host a gathering", questStat: .bond, questDiff: 2,
                  milestones: ["Pick a date", "Invite people", "Plan food", "Host it"]),
    QuestTemplate(id: "money", name: "Fix my finances", why: "Less stress, more options",
                  habits: [("Log every expense", .craft, 1), ("No impulse buys", .craft, 2)],
                  quest: "Build an emergency fund", questStat: .craft, questDiff: 3,
                  milestones: ["Make a budget", "Save first $250", "Save first $500", "Save first $1,000"])
]

struct DailyChallenge { let emoji: String; let text: String; let stat: StatKind }

let DAILY_CHALLENGES: [DailyChallenge] = [
    DailyChallenge(emoji: "🚶", text: "Take a 15-minute walk without your phone", stat: .body),
    DailyChallenge(emoji: "📵", text: "One hour with zero screens", stat: .mind),
    DailyChallenge(emoji: "💌", text: "Send someone a genuine compliment", stat: .bond),
    DailyChallenge(emoji: "🧹", text: "Clean one area for 10 minutes", stat: .craft),
    DailyChallenge(emoji: "🌅", text: "Go to bed 30 minutes earlier tonight", stat: .body),
    DailyChallenge(emoji: "📖", text: "Learn one new thing and explain it to someone", stat: .mind),
    DailyChallenge(emoji: "🙏", text: "Sit in silence/reflection for 5 minutes", stat: .spirit),
    DailyChallenge(emoji: "🥗", text: "Eat one fully home-cooked meal", stat: .body),
    DailyChallenge(emoji: "📞", text: "Call a family member just to check in", stat: .bond),
    DailyChallenge(emoji: "✍️", text: "Write down the one thing that would make today a win", stat: .spirit),
    DailyChallenge(emoji: "🎯", text: "Do the task you have been avoiding for 25 minutes", stat: .craft),
    DailyChallenge(emoji: "🤲", text: "Do one kind thing for a stranger", stat: .spirit)
]

// MARK: - Dates (local "yyyy-MM-dd" keys, same as the web app)

enum Day {
    static var cal: Calendar { Calendar.current }

    static func key(_ d: Date = Date()) -> String {
        let c = cal.dateComponents([.year, .month, .day], from: d)
        return String(format: "%04d-%02d-%02d", c.year ?? 2000, c.month ?? 1, c.day ?? 1)
    }
    static func today() -> String { key() }

    static func date(_ k: String) -> Date {
        let p = k.split(separator: "-").compactMap { Int($0) }
        guard p.count == 3 else { return Date() }
        return cal.date(from: DateComponents(year: p[0], month: p[1], day: p[2])) ?? Date()
    }
    static func add(_ k: String, _ n: Int) -> String {
        key(cal.date(byAdding: .day, value: n, to: date(k)) ?? Date())
    }
    static func dayOfYear(_ d: Date = Date()) -> Int {
        cal.ordinality(of: .day, in: .year, for: d) ?? 1
    }
    static func daysBetween(_ a: String, _ b: String) -> Int {
        cal.dateComponents([.day], from: date(a), to: date(b)).day ?? 0
    }
}
