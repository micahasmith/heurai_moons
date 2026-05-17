import Foundation
import SwiftAA

enum CelestialCatalog {
    enum Body: String {
        case moon
        case mercury
        case venus
        case mars
        case jupiter
        case saturn

        var displayName: String {
            L10n.bodyName(rawValue)
        }

        var glyph: String {
            switch self {
            case .moon: "◐"
            case .mercury: "☿"
            case .venus: "♀"
            case .mars: "♂"
            case .jupiter: "♃"
            case .saturn: "♄"
            }
        }
    }

    static func bundle(for date: Date, location: ObservingLocation = .assumedLocality) -> ObservatorySnapshotBundle {
        let sections = snapshots(for: date, location: location)
        return ObservatorySnapshotBundle(
            location: location,
            generatedAt: date,
            visibleCount: sections.filter(\.visibleNow).count,
            sections: sections
        )
    }

    static func upcomingEvents(
        for date: Date,
        location: ObservingLocation = .assumedLocality,
        daysAhead: Int = 2
    ) -> [CelestialEvent] {
        let trackedBodies: [Body] = [.moon, .mercury, .venus, .mars, .jupiter, .saturn]
        var events: [CelestialEvent] = []
        var seenIDs: Set<String> = []

        for dayOffset in 0...daysAhead {
            guard let candidateDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: date) else { continue }
            let julianDay = JulianDay(candidateDate)

            for body in trackedBodies {
                let riseSet = riseSetTimes(for: body, julianDay: julianDay, location: location)
                let candidates: [(Date?, CelestialEvent.Kind)] = [
                    (riseSet.riseTime?.date, .enterHorizon),
                    (riseSet.setTime?.date, .exitHorizon)
                ]

                for (eventDate, kind) in candidates {
                    guard let eventDate, eventDate > date else { continue }
                    let event = CelestialEvent(
                        bodyID: body.rawValue,
                        bodyName: body.displayName,
                        kind: kind,
                        date: eventDate
                    )

                    guard seenIDs.insert(event.id).inserted else { continue }
                    events.append(event)
                }
            }
        }

        return events.sorted { $0.date < $1.date }
    }

    static func snapshots(for date: Date, location: ObservingLocation) -> [CelestialSnapshot] {
        let julianDay = JulianDay(date)
        let moonSection = moonSnapshot(julianDay: julianDay, location: location)
        let planets = [
            planetSnapshot(Mercury(julianDay: julianDay, highPrecision: true), body: .mercury, location: location),
            planetSnapshot(Venus(julianDay: julianDay, highPrecision: true), body: .venus, location: location),
            planetSnapshot(Mars(julianDay: julianDay, highPrecision: true), body: .mars, location: location),
            planetSnapshot(Jupiter(julianDay: julianDay, highPrecision: true), body: .jupiter, location: location),
            planetSnapshot(Saturn(julianDay: julianDay, highPrecision: true), body: .saturn, location: location)
        ]
        .sorted { lhs, rhs in
            if lhs.visibleNow != rhs.visibleNow {
                return lhs.visibleNow && !rhs.visibleNow
            }
            return lhs.ringFraction > rhs.ringFraction
        }

        return [moonSection] + planets
    }

    private static func moonSnapshot(julianDay: JulianDay, location: ObservingLocation) -> CelestialSnapshot {
        let body = Moon(julianDay: julianDay, highPrecision: true)
        let localMoon = MoonMath.snapshot(for: julianDay.date)
        let horizontal = body.makeHorizontalCoordinates(with: location.coordinates)
        let riseSet = body.riseTransitSetTimes(for: location.coordinates)
        let altitude = horizontal.altitude.value
        let azimuth = horizontal.northBasedAzimuth.value
        let illumination = Int((body.illuminatedFraction() * 100).rounded())

        return CelestialSnapshot(
            id: Body.moon.rawValue,
            name: Body.moon.displayName,
            glyph: localMoon.phaseGlyph,
            statusTitle: localMoon.phaseName,
            statusDetail: "\(localMoon.trajectoryLabel) • \(visibilityPhrase(for: altitude))",
            primaryValue: "\(illumination)%",
            primaryLabel: L10n.metricIllumination(),
            visibleNow: altitude > 0,
            ringFraction: ringFraction(for: altitude),
            ringText: altitudeText(altitude),
            metrics: [
                CelestialMetric(label: L10n.metricAltitude(), value: altitudeText(altitude)),
                CelestialMetric(label: L10n.metricAzimuth(), value: azimuthText(azimuth)),
                CelestialMetric(label: L10n.metricRise(), value: relativeEventText(for: riseSet.riseTime?.date, reference: julianDay.date)),
                CelestialMetric(label: L10n.metricSet(), value: relativeEventText(for: riseSet.setTime?.date, reference: julianDay.date))
            ],
            footer: L10n.localPhaseWindow(locationName: location.name)
        )
    }

    private static func planetSnapshot(_ planet: Planet, body: Body, location: ObservingLocation) -> CelestialSnapshot {
        let horizontal = planet.makeHorizontalCoordinates(with: location.coordinates)
        let riseSet = planet.riseTransitSetTimes(for: location.coordinates)
        let referenceDate = planet.julianDay.date
        let altitude = horizontal.altitude.value
        let azimuth = horizontal.northBasedAzimuth.value
        let illumination = Int((planet.illuminatedFraction * 100).rounded())

        return CelestialSnapshot(
            id: body.rawValue,
            name: body.displayName,
            glyph: body.glyph,
            statusTitle: visibilityPhrase(for: altitude),
            statusDetail: "\(compassPoint(for: azimuth)) sky • \(altitudeText(altitude))",
            primaryValue: String(format: "%.1f", planet.magnitude.value),
            primaryLabel: L10n.metricMagnitude(),
            visibleNow: altitude > 0,
            ringFraction: ringFraction(for: altitude),
            ringText: altitudeText(altitude),
            metrics: [
                CelestialMetric(label: L10n.metricAzimuth(), value: azimuthText(azimuth)),
                CelestialMetric(label: L10n.metricIllumination(), value: "\(illumination)%"),
                CelestialMetric(label: L10n.metricRise(), value: relativeEventText(for: riseSet.riseTime?.date, reference: referenceDate)),
                CelestialMetric(label: L10n.metricSet(), value: relativeEventText(for: riseSet.setTime?.date, reference: referenceDate))
            ],
            footer: L10n.orbitalWindow(locationName: location.name)
        )
    }

    private static func ringFraction(for altitude: Double) -> Double {
        min(max(altitude / 90.0, 0), 1)
    }

    private static func visibilityPhrase(for altitude: Double) -> String {
        switch altitude {
        case 45...:
            return L10n.visibilityHighInSky()
        case 15..<45:
            return L10n.visibilityWellPlaced()
        case 0..<15:
            return L10n.visibilityNearHorizon()
        default:
            return L10n.visibilityBelowHorizon()
        }
    }

    private static func altitudeText(_ altitude: Double) -> String {
        String(format: "%.0f°", altitude)
    }

    private static func azimuthText(_ azimuth: Double) -> String {
        "\(compassPoint(for: azimuth)) \(Int(azimuth.rounded()))°"
    }

    private static func compassPoint(for azimuth: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((azimuth + 22.5) / 45.0) % directions.count
        return directions[index]
    }

    private static func relativeEventText(for date: Date?, reference: Date) -> String {
        guard let date else { return "none" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale.current
        return formatter.localizedString(for: date, relativeTo: reference)
    }

    private static func riseSetTimes(for body: Body, julianDay: JulianDay, location: ObservingLocation) -> RiseTransitSetTimes {
        switch body {
        case .moon:
            Moon(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        case .mercury:
            Mercury(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        case .venus:
            Venus(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        case .mars:
            Mars(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        case .jupiter:
            Jupiter(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        case .saturn:
            Saturn(julianDay: julianDay, highPrecision: true).riseTransitSetTimes(for: location.coordinates)
        }
    }
}
