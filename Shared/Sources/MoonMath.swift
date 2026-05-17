import Foundation

enum MoonMath {
    static let synodicMonthDays = 29.530588853
    private static let referenceNewMoon = Date(timeIntervalSince1970: 947182440) // 2000-01-06 18:14:00 UTC

    static func snapshot(for date: Date = .now) -> LunarSnapshot {
        let daysSinceReference = date.timeIntervalSince(referenceNewMoon) / 86_400
        let rawLunations = daysSinceReference / synodicMonthDays
        let normalizedPhase = rawLunations - floor(rawLunations)
        let ageDays = normalizedPhase * synodicMonthDays
        let illumination = 0.5 * (1 - cos(2 * .pi * normalizedPhase))
        let lunationIndex = Int(floor(rawLunations))
        let phaseInfo = phaseDescriptor(for: normalizedPhase, ageDays: ageDays)
        let nextEvent = nextMajorPhase(after: date, currentPhase: normalizedPhase)

        return LunarSnapshot(
            date: date,
            phase: normalizedPhase,
            illumination: illumination,
            ageDays: ageDays,
            lunation: lunationIndex,
            phaseName: phaseInfo.name,
            phaseGlyph: phaseInfo.glyph,
            trajectoryLabel: phaseInfo.trajectory,
            nextPhaseName: nextEvent.name,
            nextPhaseDate: nextEvent.date
        )
    }

    private static func phaseDescriptor(for phase: Double, ageDays: Double) -> (name: String, glyph: String, trajectory: String) {
        switch phase {
        case 0.0..<0.03, 0.97...1.0:
            return ("new moon", "●", "signal reset")
        case 0.03..<0.22:
            return ("waxing crescent", "◔", "light increasing")
        case 0.22..<0.28:
            return ("first quarter", "◑", "half-lit ascent")
        case 0.28..<0.47:
            return ("waxing gibbous", "◕", "approaching full")
        case 0.47..<0.53:
            return ("full moon", "○", "maximum exposure")
        case 0.53..<0.72:
            return ("waning gibbous", "◕", "light receding")
        case 0.72..<0.78:
            return ("last quarter", "◐", "half-lit descent")
        default:
            return ("waning crescent", "◓", "returning dark")
        }
    }

    private static func nextMajorPhase(after date: Date, currentPhase: Double) -> (name: String, date: Date) {
        let milestones: [(String, Double)] = [
            ("new moon", 0.0),
            ("first quarter", 0.25),
            ("full moon", 0.5),
            ("last quarter", 0.75)
        ]

        for milestone in milestones where milestone.1 > currentPhase {
            return (milestone.0, advancedDate(from: date, currentPhase: currentPhase, targetPhase: milestone.1))
        }

        return ("new moon", advancedDate(from: date, currentPhase: currentPhase, targetPhase: 1.0))
    }

    private static func advancedDate(from date: Date, currentPhase: Double, targetPhase: Double) -> Date {
        let remainingPhase = targetPhase - currentPhase
        let days = remainingPhase * synodicMonthDays
        return date.addingTimeInterval(days * 86_400)
    }
}
