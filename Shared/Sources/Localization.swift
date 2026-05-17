import Foundation

enum L10n {
    static func bodyName(_ bodyID: String) -> String {
        switch bodyID {
        case "moon": text("body.moon")
        case "mercury": text("body.mercury")
        case "venus": text("body.venus")
        case "mars": text("body.mars")
        case "jupiter": text("body.jupiter")
        case "saturn": text("body.saturn")
        default: bodyID
        }
    }

    static func heroTrackedBodies(_ count: Int) -> String {
        format("hero.tracked_bodies", count)
    }

    static func heroAboveHorizon(_ count: Int) -> String {
        format("hero.above_horizon", count)
    }

    static func heroSite(_ locationName: String) -> String {
        format("hero.site", locationName)
    }

    static func heroTime(_ timeText: String) -> String {
        format("hero.time", timeText)
    }

    static func heroAlertsArmed() -> String {
        text("hero.alerts_armed")
    }

    static func heroAlertsOff() -> String {
        text("hero.alerts_off")
    }

    static func analysisEyebrow() -> String {
        text("analysis.eyebrow")
    }

    static func analysisTitle() -> String {
        text("analysis.title")
    }

    static func generalizedPanelTitle() -> String {
        text("analysis.generalized.title")
    }

    static func generalizedPanelDetail() -> String {
        text("analysis.generalized.detail")
    }

    static func trackedBodiesTitle() -> String {
        text("analysis.tracked.title")
    }

    static func trackedBodiesDetail(sectionCount: Int, visibleCount: Int, locationName: String) -> String {
        format("analysis.tracked.detail", sectionCount, visibleCount, locationName)
    }

    static func localityTitle() -> String {
        text("analysis.locality.title")
    }

    static func localityDetail(locationName: String, notificationsEnabled: Bool) -> String {
        format(
            "analysis.locality.detail",
            locationName,
            notificationsEnabled ? text("analysis.locality.alerts_on") : text("analysis.locality.alerts_off")
        )
    }

    static func planetaryObservatory() -> String {
        text("observatory.title")
    }

    static func visibleInCurrentSky() -> String {
        text("observatory.visible")
    }

    static func belowLocalHorizon() -> String {
        text("observatory.hidden")
    }

    static func metricAltitude() -> String {
        text("metric.altitude")
    }

    static func metricAzimuth() -> String {
        text("metric.azimuth")
    }

    static func metricRise() -> String {
        text("metric.rise")
    }

    static func metricSet() -> String {
        text("metric.set")
    }

    static func metricIllumination() -> String {
        text("metric.illumination")
    }

    static func metricMagnitude() -> String {
        text("metric.magnitude")
    }

    static func visibilityHighInSky() -> String {
        text("visibility.high")
    }

    static func visibilityWellPlaced() -> String {
        text("visibility.well_placed")
    }

    static func visibilityNearHorizon() -> String {
        text("visibility.near_horizon")
    }

    static func visibilityBelowHorizon() -> String {
        text("visibility.below_horizon")
    }

    static func localPhaseWindow(locationName: String) -> String {
        format("footer.phase_window", locationName)
    }

    static func orbitalWindow(locationName: String) -> String {
        format("footer.orbital_window", locationName)
    }

    static func coordinatesLabel(latitude: Double, longitude: Double) -> String {
        format("location.coordinates", latitude, longitude)
    }

    static func currentLocationFallback() -> String {
        text("location.current")
    }

    static func eventEnterHorizon() -> String {
        text("event.enter")
    }

    static func eventExitHorizon() -> String {
        text("event.exit")
    }

    static func notificationTitleEnter(bodyName: String) -> String {
        format("notification.title.enter", bodyName)
    }

    static func notificationTitleExit(bodyName: String) -> String {
        format("notification.title.exit", bodyName)
    }

    static func notificationBody(locationName: String, dateText: String) -> String {
        format("notification.body.generic", locationName, dateText)
    }

    private static func text(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = text(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}
