import SwiftUI

enum HeuraiBrand {
    static let background = Color(red: 0.03, green: 0.03, blue: 0.04)
    static let panel = Color.white.opacity(0.06)
    static let panelStrong = Color.white.opacity(0.1)
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.66)
    static let textMuted = Color.white.opacity(0.34)
    static let accent = Color.white.opacity(0.9)
    static let warning = Color(red: 0.98, green: 0.54, blue: 0.22)
    static let ring = Color.white.opacity(0.2)
    static let hairline = Color.white.opacity(0.12)

    static let heroGradient = LinearGradient(
        colors: [
            Color.black.opacity(0.98),
            Color.black.opacity(0.94),
            Color.white.opacity(0.04)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct HeuraiBackdrop: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    HeuraiBrand.background

                    HeuraiBrand.heroGradient

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.04),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .mask {
                            GeometryReader { proxy in
                                VStack(spacing: 3) {
                                    ForEach(0..<Int(max(proxy.size.height / 4, 1)), id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(height: 1)
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 2)
                                    }
                                }
                            }
                        }
                        .opacity(0.16)
                }
                .allowsHitTesting(false)
            }
    }
}

struct HeuraiPanelSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.03),
                                Color.white.opacity(0.015)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(HeuraiBrand.hairline, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 16)
    }
}

extension View {
    func heuraiBackdrop() -> some View {
        modifier(HeuraiBackdrop())
    }

    func heuraiPanelSurface() -> some View {
        modifier(HeuraiPanelSurface())
    }
}
