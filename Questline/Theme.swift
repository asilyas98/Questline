import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

enum Theme {
    static let bg = Color(hex: 0x0D0F1A)
    static let panel = Color(hex: 0x151A2C)
    static let panel2 = Color(hex: 0x1C2238)
    static let line = Color(hex: 0x2A3150)
    static let text = Color(hex: 0xE9ECF8)
    static let muted = Color(hex: 0x8B93B3)
    static let gold = Color(hex: 0xFFC94A)
    static let xp = Color(hex: 0x7C5CFF)
    static let xp2 = Color(hex: 0xB39BFF)
    static let good = Color(hex: 0x3DDC97)
    static let bad = Color(hex: 0xFF5D73)
    static let fire = Color(hex: 0xFF9F43)
    static let pink = Color(hex: 0xFF6FB5)
}

// MARK: - Reusable styling

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.line, lineWidth: 1))
    }
}

struct RowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.panel2)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct InputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1))
            .foregroundColor(Theme.text)
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
    func row() -> some View { modifier(RowStyle()) }
    func input() -> some View { modifier(InputStyle()) }
    func meta() -> some View { font(.caption).foregroundColor(Theme.muted) }
}

struct PrimaryButton: ButtonStyle {
    var color: Color = Theme.xp
    var textColor: Color = .white
    var fullWidth = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(color)
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GhostButton: ButtonStyle {
    var textColor: Color = Theme.text
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Theme.panel2)
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

// MARK: - Small components

struct SectionHeader: View {
    let title: String
    var actionLabel: String = "+ Add"
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundColor(Theme.muted)
            Spacer()
            if let action = action {
                Button(actionLabel, action: action)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.panel2)
                    .foregroundColor(Theme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line, lineWidth: 1))
            }
        }
    }
}

struct XPBar: View {
    var value: Double
    var color: Color = Theme.xp
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.bg)
                Capsule()
                    .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, value.isFinite ? value : 0)) * g.size.width)
            }
        }
        .frame(height: height)
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: value)
    }
}

struct CheckBox: View {
    var done: Bool
    var size: CGFloat = 30
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .fill(done ? Theme.good : Color.clear)
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .stroke(done ? Theme.good : Theme.line, lineWidth: 2)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.5, weight: .bold))
                        .foregroundColor(Theme.bg)
                }
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct StatTag: View {
    let stat: StatKind
    var body: some View {
        Text("\(stat.icon) \(stat.name)")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
            .foregroundColor(stat.color)
    }
}

struct EmptyNote: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(Theme.muted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(14)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.line, style: StrokeStyle(lineWidth: 1, dash: [5])))
    }
}

struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.caption.weight(.semibold)).foregroundColor(Theme.muted)
    }
}

/// Main-tab page: HUD + scrolling content on the game background.
struct Screen<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HUDView()
                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}
