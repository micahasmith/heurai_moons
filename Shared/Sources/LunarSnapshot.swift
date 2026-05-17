import Foundation

struct LunarSnapshot: Equatable {
    let date: Date
    let phase: Double
    let illumination: Double
    let ageDays: Double
    let lunation: Int
    let phaseName: String
    let phaseGlyph: String
    let trajectoryLabel: String
    let nextPhaseName: String
    let nextPhaseDate: Date

    var illuminationPercentText: String {
        "\(Int((illumination * 100).rounded()))%"
    }

    var ageText: String {
        String(format: "%.1f d", ageDays)
    }

    var progressText: String {
        "\(Int((phase * 100).rounded()))%"
    }

    var nextPhaseCountdownText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: nextPhaseDate, relativeTo: date)
    }

    var nextPhaseDisplayText: String {
        "\(nextPhaseName) \(nextPhaseCountdownText)"
    }
}
