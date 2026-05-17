import SwiftUI

struct AppShellView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let snapshot = MoonMath.snapshot(for: context.date)

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    hero(snapshot: snapshot)
                    observatory(snapshot: snapshot)
                    analysis(snapshot: snapshot)
                }
                .padding(40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .heuraiBackdrop()
        }
    }

    private func hero(snapshot: LunarSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("∆:∴")
                .font(HeuraiBrand.mono(24, weight: .medium))
                .tracking(6)
                .foregroundStyle(HeuraiBrand.textSecondary)

            Text("heurai moons")
                .font(HeuraiBrand.mono(58, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)

            Text("a symbolic lunar HUD for macOS, shaped by the same monochrome atmosphere, editorial spacing, and signal-first typography found on heurai.com.")
                .font(HeuraiBrand.mono(22))
                .foregroundStyle(HeuraiBrand.textSecondary)
                .frame(maxWidth: 760, alignment: .leading)

            HStack(spacing: 12) {
                pill(label: snapshot.phaseName)
                pill(label: "illumination \(snapshot.illuminationPercentText)")
                pill(label: "next \(snapshot.nextPhaseDisplayText)")
            }
        }
    }

    private func observatory(snapshot: LunarSnapshot) -> some View {
        HStack(alignment: .top, spacing: 22) {
            LunarHUDView(snapshot: snapshot)
                .frame(maxWidth: .infinity, minHeight: 420)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

            VStack(alignment: .leading, spacing: 18) {
                observatoryCard(
                    eyebrow: "event horizon",
                    title: snapshot.nextPhaseName,
                    value: snapshot.nextPhaseCountdownText,
                    detail: snapshot.nextPhaseDate.formatted(date: .abbreviated, time: .shortened)
                )

                observatoryCard(
                    eyebrow: "lunar age",
                    title: snapshot.ageText,
                    value: snapshot.progressText,
                    detail: "tracked against a \(String(format: "%.2f", MoonMath.synodicMonthDays)) day synodic cycle"
                )

                observatoryCard(
                    eyebrow: "trajectory",
                    title: snapshot.trajectoryLabel,
                    value: snapshot.phaseName,
                    detail: "lunation \(snapshot.lunation)"
                )
            }
            .frame(width: 320)
        }
    }

    private func analysis(snapshot: LunarSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader(eyebrow: "analysis", title: "desktop observatory")

            HStack(alignment: .top, spacing: 18) {
                instructionCard(
                    index: "01",
                    title: "Current state",
                    detail: "The moon is in \(snapshot.phaseName), with \(snapshot.illuminationPercentText) illumination and a \(snapshot.trajectoryLabel) signal."
                )
                instructionCard(
                    index: "02",
                    title: "Cadence",
                    detail: "The dashboard refreshes every minute inside the app, so the orbital readout stays current without relying on WidgetKit."
                )
                instructionCard(
                    index: "03",
                    title: "Direction",
                    detail: "This is now a pure macOS app foundation. We can next add notifications, menubar mode, calendar overlays, or a richer moon render."
                )
            }
        }
    }

    private func instructionCard(index: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(index)
                .font(HeuraiBrand.mono(11, weight: .semibold))
                .foregroundStyle(HeuraiBrand.textMuted)
            Text(title)
                .font(HeuraiBrand.mono(20, weight: .semibold))
                .foregroundStyle(HeuraiBrand.textPrimary)
            Text(detail)
                .font(HeuraiBrand.mono(13))
                .foregroundStyle(HeuraiBrand.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(HeuraiBrand.panelStrong)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HeuraiBrand.hairline, lineWidth: 1)
        }
    }

    private func observatoryCard(eyebrow: String, title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(eyebrow)
                .font(HeuraiBrand.mono(10))
                .foregroundStyle(HeuraiBrand.textMuted)
            Text(title)
                .font(HeuraiBrand.mono(28, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)
            Text(value)
                .font(HeuraiBrand.mono(12, weight: .medium))
                .foregroundStyle(HeuraiBrand.textSecondary)
            Text(detail)
                .font(HeuraiBrand.mono(11))
                .foregroundStyle(HeuraiBrand.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(HeuraiBrand.panelStrong)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HeuraiBrand.hairline, lineWidth: 1)
        }
    }

    private func pill(label: String) -> some View {
        Text(label)
            .font(HeuraiBrand.mono(11, weight: .medium))
            .foregroundStyle(HeuraiBrand.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(HeuraiBrand.panelStrong))
            .overlay {
                Capsule().stroke(HeuraiBrand.hairline, lineWidth: 1)
            }
    }

    private func sectionHeader(eyebrow: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .font(HeuraiBrand.mono(11))
                .foregroundStyle(HeuraiBrand.textMuted)
            Text(title)
                .font(HeuraiBrand.mono(30, weight: .bold))
                .foregroundStyle(HeuraiBrand.textPrimary)
        }
    }
}
