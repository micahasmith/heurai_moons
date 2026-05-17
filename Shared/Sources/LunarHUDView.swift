import SwiftUI

struct CelestialSectionView: View {
    let snapshot: CelestialSnapshot
    let density: InterfaceScale.Density
    let scale: Double

    var body: some View {
        Group {
            if density == .tiled {
                VStack(alignment: .leading, spacing: outerSpacing) {
                    hudHeader

                    HStack(alignment: .center, spacing: contentSpacing) {
                        ringView
                        summaryBlock
                    }

                    visibilityRail

                    metricsGrid
                }
            } else {
                HStack(alignment: .top, spacing: outerSpacing) {
                    VStack(alignment: .leading, spacing: outerSpacing) {
                        hudHeader

                        HStack(alignment: .center, spacing: contentSpacing) {
                            ringView
                            summaryBlock
                        }

                        visibilityRail
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    metricsColumn
                }
            }
        }
        .padding(containerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .opacity(snapshot.visibleNow ? 1 : 0.7)
        .heuraiPanelSurface()
    }

    private var hudHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("∆:∴")
                .font(HeuraiBrand.mono(eyebrowSize, weight: .medium))
                .tracking(3)
                .foregroundStyle(HeuraiBrand.textSecondary)

            Text(L10n.planetaryObservatory())
                .font(HeuraiBrand.mono(titleSize, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)

            Text(snapshot.visibleNow ? L10n.visibleInCurrentSky() : L10n.belowLocalHorizon())
                .font(HeuraiBrand.mono(detailSize))
                .foregroundStyle(HeuraiBrand.textMuted)
        }
    }

    private var visibilityRail: some View {
        HStack(spacing: 10) {
            railMarker("hz", active: snapshot.ringFraction > 0.01)
            railLine
            railMarker("low", active: snapshot.ringFraction > 0.16)
            railLine
            railMarker("mid", active: snapshot.ringFraction > 0.4)
            railLine
            railMarker("high", active: snapshot.ringFraction > 0.72)
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
                .frame(width: 9 * scale, height: 9 * scale)
            Text(label)
                .font(HeuraiBrand.mono(9 * scale))
                .foregroundStyle(active ? HeuraiBrand.textPrimary : HeuraiBrand.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(HeuraiBrand.mono(10 * scale))
                .foregroundStyle(HeuraiBrand.textMuted)
            Text(value)
                .font(HeuraiBrand.mono(14 * scale, weight: .semibold))
                .foregroundStyle(HeuraiBrand.textPrimary)
                .lineLimit(2)
        }
        .padding(12 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14 * scale, style: .continuous)
                .fill(HeuraiBrand.panel)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14 * scale, style: .continuous)
                .stroke(HeuraiBrand.hairline, lineWidth: 1)
        }
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(HeuraiBrand.ring, lineWidth: 1)
                .frame(width: outerRingSize, height: outerRingSize)

            Circle()
                .trim(from: 0, to: snapshot.ringFraction)
                .stroke(HeuraiBrand.accent, style: StrokeStyle(lineWidth: ringStroke, lineCap: .round))
                .frame(width: outerRingSize, height: outerRingSize)
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(HeuraiBrand.panelStrong)
                .frame(width: innerRingSize, height: innerRingSize)
                .overlay {
                    VStack(spacing: 6 * scale) {
                        Text(snapshot.glyph)
                            .font(HeuraiBrand.mono(glyphSize, weight: .light))
                            .foregroundStyle(HeuraiBrand.textPrimary)
                        Text(snapshot.ringText)
                            .font(HeuraiBrand.mono(11 * scale, weight: .medium))
                            .foregroundStyle(HeuraiBrand.textSecondary)
                    }
                }
        }
    }

    private var summaryBlock: some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            Text(snapshot.name)
                .font(HeuraiBrand.mono(nameSize, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)

            Text(snapshot.statusTitle)
                .font(HeuraiBrand.mono(statusSize, weight: .semibold))
                .foregroundStyle(HeuraiBrand.textPrimary)

            Text(snapshot.statusDetail)
                .font(HeuraiBrand.mono(detailSize))
                .foregroundStyle(HeuraiBrand.textSecondary)

            Text(snapshot.footer)
                .font(HeuraiBrand.mono(11 * scale))
                .foregroundStyle(HeuraiBrand.textMuted)

            Text("\(snapshot.primaryLabel) \(snapshot.primaryValue)")
                .font(HeuraiBrand.mono(12 * scale, weight: .medium))
                .foregroundStyle(HeuraiBrand.textPrimary)
                .padding(.top, 6 * scale)
        }
    }

    private var metricsColumn: some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            ForEach(snapshot.metrics) { metric in
                metricCard(label: metric.label, value: metric.value)
            }
        }
        .frame(width: metricsWidth, alignment: .leading)
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: density == .tiled ? 138 * scale : 180 * scale), spacing: 10 * scale)],
            alignment: .leading,
            spacing: 10 * scale
        ) {
            ForEach(snapshot.metrics) { metric in
                metricCard(label: metric.label, value: metric.value)
            }
        }
    }

    private var outerSpacing: Double {
        density == .editorial ? 24 * scale : 16 * scale
    }

    private var contentSpacing: Double {
        density == .editorial ? 20 * scale : 14 * scale
    }

    private var containerPadding: Double {
        density == .editorial ? 28 * scale : 20 * scale
    }

    private var outerRingSize: Double {
        switch density {
        case .editorial: 188 * scale
        case .balanced: 148 * scale
        case .tiled: 110 * scale
        }
    }

    private var innerRingSize: Double {
        outerRingSize * 0.83
    }

    private var ringStroke: Double {
        max(3, 5 * scale)
    }

    private var glyphSize: Double {
        switch density {
        case .editorial: 72 * scale
        case .balanced: 54 * scale
        case .tiled: 34 * scale
        }
    }

    private var metricsWidth: Double {
        density == .balanced ? 210 * scale : 250 * scale
    }

    private var eyebrowSize: Double { density == .tiled ? 10 * scale : 13 * scale }
    private var titleSize: Double { density == .editorial ? 22 * scale : 16 * scale }
    private var nameSize: Double { density == .editorial ? 26 * scale : density == .balanced ? 20 * scale : 16 * scale }
    private var statusSize: Double { density == .tiled ? 12 * scale : 14 * scale }
    private var detailSize: Double { density == .tiled ? 10 * scale : 12 * scale }
}

#Preview("Celestial Section") {
    CelestialSectionView(
        snapshot: CelestialSnapshot(
            id: "moon",
            name: "Moon",
            glyph: "◔",
            statusTitle: "waxing crescent",
            statusDetail: "light increasing • well placed",
            primaryValue: "34%",
            primaryLabel: "illumination",
            visibleNow: true,
            ringFraction: 0.58,
            ringText: "52°",
            metrics: [
                CelestialMetric(label: "altitude", value: "52°"),
                CelestialMetric(label: "azimuth", value: "SE 132°"),
                CelestialMetric(label: "rise", value: "in 2h"),
                CelestialMetric(label: "set", value: "in 9h")
            ],
            footer: "local phase window • new york city"
        ),
        density: .editorial,
        scale: 1
    )
        .frame(width: 860, height: 420)
}
