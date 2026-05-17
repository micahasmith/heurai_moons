import SwiftUI

struct AppShellView: View {
    @EnvironmentObject private var store: ObservatoryStore
    @AppStorage(InterfaceScale.storageKey) private var uiScale = InterfaceScale.default

    private var density: InterfaceScale.Density {
        InterfaceScale.density(for: uiScale)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                hero(bundle: store.bundle)
                observatorySections(bundle: store.bundle)
            }
            .padding(shellPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .heuraiBackdrop()
        .task {
            store.start()
        }
    }

    private func hero(bundle: ObservatorySnapshotBundle) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("∆:∴")
                .font(HeuraiBrand.mono(symbolSize, weight: .medium))
                .tracking(6)
                .foregroundStyle(HeuraiBrand.textSecondary)

            heroPillLayout {
                pill(label: L10n.heroSite(bundle.location.name))
                pill(label: L10n.heroTrackedBodies(bundle.sections.count))
                pill(label: L10n.heroAboveHorizon(bundle.visibleCount))
                pill(label: store.notificationsEnabled ? L10n.heroAlertsArmed() : L10n.heroAlertsOff())
                pill(label: L10n.heroTime(bundle.generatedAt.formatted(date: .omitted, time: .shortened)))
            }
        }
    }

    private func observatorySections(bundle: ObservatorySnapshotBundle) -> some View {
        LazyVGrid(columns: observatoryColumns, alignment: .leading, spacing: cardSpacing) {
            ForEach(bundle.sections) { snapshot in
                CelestialSectionView(snapshot: snapshot, density: density, scale: uiScale)
                    .frame(minHeight: observatoryHeight)
                    .clipShape(RoundedRectangle(cornerRadius: observatoryCornerRadius, style: .continuous))
            }
        }
    }

    private func pill(label: String) -> some View {
        Text(label)
            .font(HeuraiBrand.mono(11 * uiScale, weight: .medium))
            .foregroundStyle(HeuraiBrand.textPrimary)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 12 * uiScale)
            .padding(.vertical, 8 * uiScale)
            .background(Capsule().fill(HeuraiBrand.panelStrong))
            .overlay {
                Capsule().stroke(HeuraiBrand.hairline, lineWidth: 1)
            }
    }

    private var shellPadding: Double {
        28 * uiScale + (density == .tiled ? 4 : 12)
    }

    private var symbolSize: Double {
        22 * uiScale
    }

    private var cardSpacing: Double {
        density == .tiled ? 16 : 22
    }

    private var observatoryColumns: [GridItem] {
        [GridItem(.adaptive(minimum: observatoryTileWidth, maximum: density == .editorial ? 1_600 : 820), spacing: cardSpacing, alignment: .top)]
    }

    private var observatoryTileWidth: Double {
        switch density {
        case .editorial:
            900
        case .balanced:
            540
        case .tiled:
            360
        }
    }

    private var observatoryHeight: Double {
        switch density {
        case .editorial:
            420 * uiScale
        case .balanced:
            360 * uiScale
        case .tiled:
            320 * uiScale
        }
    }

    private var observatoryCornerRadius: Double {
        32 * uiScale
    }

    @ViewBuilder
    private func heroPillLayout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if density == .tiled {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: max(180, 220 * uiScale), maximum: 360), spacing: 12, alignment: .leading)],
                alignment: .leading,
                spacing: 12
            ) {
                content()
            }
        } else {
            HStack(spacing: 12, content: content)
        }
    }
}
