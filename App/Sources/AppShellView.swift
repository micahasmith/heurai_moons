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
                alertsCard
                observatorySections(bundle: store.bundle)
            }
            .padding(shellPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .heuraiBackdrop()
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
                if shouldShowAlertSettingsPill {
                    SettingsLink {
                        attentionPill(label: L10n.heroAlertsAttention())
                    }
                    .buttonStyle(.plain)
                }
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

    private var alertsCard: some View {
        VStack(alignment: .leading, spacing: 14 * uiScale) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.controlsNextAlertsTitle())
                    .font(HeuraiBrand.mono(20 * uiScale, weight: .semibold))
                    .foregroundStyle(HeuraiBrand.textPrimary)

                Spacer(minLength: 12)

                if shouldShowAlertSettingsPill {
                    SettingsLink {
                        pill(label: L10n.settingsOpenButton())
                    }
                    .buttonStyle(.plain)
                }
            }

            if store.upcomingEvents.isEmpty {
                Text(L10n.controlsNoAlerts())
                    .font(HeuraiBrand.mono(12 * uiScale))
                    .foregroundStyle(HeuraiBrand.textMuted)
            } else {
                LazyVGrid(columns: alertColumns, alignment: .leading, spacing: 12 * uiScale) {
                    ForEach(store.upcomingEvents.prefix(6)) { event in
                        alertRow(event)
                    }
                }
            }
        }
        .padding(20 * uiScale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24 * uiScale, style: .continuous)
                .fill(HeuraiBrand.panelStrong)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24 * uiScale, style: .continuous)
                .stroke(HeuraiBrand.hairline, lineWidth: 1)
        }
    }

    private func alertRow(_ event: CelestialEvent) -> some View {
        VStack(alignment: .leading, spacing: 4 * uiScale) {
            Text(
                L10n.controlsAlertRow(
                    bodyName: event.bodyName,
                    eventLabel: event.kind.localizedLabel,
                    relative: relativeText(for: event.date)
                )
            )
            .font(HeuraiBrand.mono(12 * uiScale, weight: .medium))
            .foregroundStyle(HeuraiBrand.textPrimary)

            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                .font(HeuraiBrand.mono(10 * uiScale))
                .foregroundStyle(HeuraiBrand.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2 * uiScale)
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

    private func attentionPill(label: String) -> some View {
        Text(label)
            .font(HeuraiBrand.mono(11 * uiScale, weight: .semibold))
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 14 * uiScale)
            .padding(.vertical, 8 * uiScale)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                HeuraiBrand.warning.opacity(0.96),
                                HeuraiBrand.warning.opacity(0.78)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: HeuraiBrand.warning.opacity(0.28), radius: 18, x: 0, y: 8)
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

    private var alertColumns: [GridItem] {
        [GridItem(.adaptive(minimum: density == .tiled ? 220 : 260, maximum: 420), spacing: 12 * uiScale, alignment: .top)]
    }

    private var shouldShowAlertSettingsPill: Bool {
        !store.notificationsEnabled || !store.notificationsArmed
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

    private func relativeText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale.current
        return formatter.localizedString(for: date, relativeTo: store.bundle.generatedAt)
    }
}
