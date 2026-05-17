import SwiftUI

struct LunarHUDView: View {
    let snapshot: LunarSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                hudHeader

                HStack(alignment: .center, spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(HeuraiBrand.ring, lineWidth: 1)
                            .frame(width: 188, height: 188)

                        Circle()
                            .trim(from: 0, to: snapshot.phase)
                            .stroke(HeuraiBrand.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .frame(width: 188, height: 188)
                            .rotationEffect(.degrees(-90))

                        Circle()
                            .fill(HeuraiBrand.panelStrong)
                            .frame(width: 156, height: 156)
                            .overlay {
                                Text(snapshot.phaseGlyph)
                                    .font(HeuraiBrand.mono(84, weight: .light))
                                    .foregroundStyle(HeuraiBrand.textPrimary)
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(snapshot.phaseName)
                            .font(HeuraiBrand.mono(26, weight: .bold))
                            .foregroundStyle(HeuraiBrand.textPrimary)

                        Text(snapshot.trajectoryLabel)
                            .font(HeuraiBrand.mono(12))
                            .foregroundStyle(HeuraiBrand.textSecondary)

                        Text("lunation \(snapshot.lunation)")
                            .font(HeuraiBrand.mono(11))
                            .foregroundStyle(HeuraiBrand.textMuted)

                        Text(snapshot.nextPhaseDisplayText)
                            .font(HeuraiBrand.mono(12, weight: .medium))
                            .foregroundStyle(HeuraiBrand.textPrimary)
                            .padding(.top, 8)
                    }
                }

                phaseRail
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                metricCard(label: "illumination", value: snapshot.illuminationPercentText)
                metricCard(label: "moon age", value: snapshot.ageText)
                metricCard(label: "lunation progress", value: snapshot.progressText)
                metricCard(label: "next event", value: snapshot.nextPhaseDate.formatted(date: .abbreviated, time: .shortened))
            }
            .frame(width: 250, alignment: .leading)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .heuraiPanelSurface()
    }

    private var hudHeader: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            Text("∆:∴")
                .font(HeuraiBrand.mono(13, weight: .medium))
                .tracking(3)
                .foregroundStyle(HeuraiBrand.textSecondary)

            Text("lunar observatory")
                .font(HeuraiBrand.mono(22, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)

            Text(snapshot.date.formatted(date: .abbreviated, time: .shortened))
                .font(HeuraiBrand.mono(11))
                .foregroundStyle(HeuraiBrand.textMuted)
        }
    }

    private var compact: Bool { false }

    private var phaseRail: some View {
        HStack(spacing: 10) {
            railMarker("new", active: snapshot.phase < 0.125 || snapshot.phase >= 0.875)
            railLine
            railMarker("first", active: snapshot.phase >= 0.125 && snapshot.phase < 0.375)
            railLine
            railMarker("full", active: snapshot.phase >= 0.375 && snapshot.phase < 0.625)
            railLine
            railMarker("last", active: snapshot.phase >= 0.625 && snapshot.phase < 0.875)
        }
    }

    private var railLine: some View {
        Rectangle()
            .fill(HeuraiBrand.hairline)
            .frame(height: 1)
    }

    private func railMarker(_ label: String, active: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(active ? HeuraiBrand.accent : HeuraiBrand.panelStrong)
                .frame(width: 9, height: 9)
            Text(label)
                .font(HeuraiBrand.mono(9))
                .foregroundStyle(active ? HeuraiBrand.textPrimary : HeuraiBrand.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(HeuraiBrand.mono(10))
                .foregroundStyle(HeuraiBrand.textMuted)
            Text(value)
                .font(HeuraiBrand.mono(14, weight: .semibold))
                .foregroundStyle(HeuraiBrand.textPrimary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(HeuraiBrand.panel)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(HeuraiBrand.hairline, lineWidth: 1)
        }
    }
}

#Preview("Observatory HUD") {
    LunarHUDView(snapshot: MoonMath.snapshot())
        .frame(width: 860, height: 420)
}
