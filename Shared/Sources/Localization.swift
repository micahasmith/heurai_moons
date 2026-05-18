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

    static func heroAlertsAttention() -> String {
        text("hero.alerts_attention")
    }

    static func heroLocationAttention() -> String {
        text("hero.location_attention")
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

    static func controlsTitle() -> String {
        text("controls.title")
    }

    static func controlsSubtitle() -> String {
        text("controls.subtitle")
    }

    static func controlsNotificationsLabel() -> String {
        text("controls.notifications.label")
    }

    static func settingsTitle() -> String {
        text("settings.title")
    }

    static func settingsSubtitle() -> String {
        text("settings.subtitle")
    }

    static func settingsNotificationsSection() -> String {
        text("settings.notifications.section")
    }

    static func settingsLocationSection() -> String {
        text("settings.location.section")
    }

    static func settingsLocationDescription() -> String {
        text("settings.location.description")
    }

    static func settingsLocationToggle() -> String {
        text("settings.location.toggle")
    }

    static func settingsLocationCurrent(_ locationName: String) -> String {
        format("settings.location.current", locationName)
    }

    static func settingsLocationSaved(_ locationName: String) -> String {
        format("settings.location.saved", locationName)
    }

    static func settingsLocationStatusLabel() -> String {
        text("settings.location.status")
    }

    static func settingsLocationHelper(usingDeviceLocation: Bool, accessEnabled: Bool) -> String {
        if usingDeviceLocation && accessEnabled {
            return text("settings.location.helper.live")
        }
        if usingDeviceLocation {
            return text("settings.location.helper.permission")
        }
        return text("settings.location.helper.saved")
    }

    static func settingsLocationGrantTitle() -> String {
        text("settings.location.grant.title")
    }

    static func settingsLocationGrantBody() -> String {
        text("settings.location.grant.body")
    }

    static func settingsLocationGrantButton() -> String {
        text("settings.location.grant.button")
    }

    static func settingsNotificationsDescription() -> String {
        text("settings.notifications.description")
    }

    static func settingsNotificationsToggle() -> String {
        text("settings.notifications.toggle")
    }

    static func settingsNotificationsHelper(enabled: Bool, armed: Bool) -> String {
        switch (enabled, armed) {
        case (true, true):
            return text("settings.notifications.helper.live")
        case (true, false):
            return text("settings.notifications.helper.paused")
        default:
            return text("settings.notifications.helper.permission")
        }
    }

    static func settingsGrantAccessTitle() -> String {
        text("settings.grant_access.title")
    }

    static func settingsGrantAccessBody() -> String {
        text("settings.grant_access.body")
    }

    static func settingsGrantAccessButton() -> String {
        text("settings.grant_access.button")
    }

    static func settingsTestSection() -> String {
        text("settings.test.section")
    }

    static func settingsTestBody() -> String {
        text("settings.test.body")
    }

    static func settingsSendTestButton() -> String {
        text("settings.test.button")
    }

    static func settingsTestQueued() -> String {
        text("settings.test.queued")
    }

    static func settingsUpcomingSection() -> String {
        text("settings.upcoming.section")
    }

    static func settingsUpcomingBody() -> String {
        text("settings.upcoming.body")
    }

    static func settingsOpenButton() -> String {
        text("settings.open_button")
    }

    static func controlsNotificationsOn() -> String {
        text("controls.notifications.on")
    }

    static func controlsNotificationsOff() -> String {
        text("controls.notifications.off")
    }

    static func controlsGrantAccess() -> String {
        text("controls.grant_access")
    }

    static func controlsSendTest() -> String {
        text("controls.send_test")
    }

    static func controlsTestQueued() -> String {
        text("controls.test_queued")
    }

    static func controlsNextAlertsTitle() -> String {
        text("controls.next_alerts.title")
    }

    static func controlsNoAlerts() -> String {
        text("controls.next_alerts.empty")
    }

    static func controlsNotificationStatus(enabled: Bool, armed: Bool) -> String {
        switch (enabled, armed) {
        case (true, true):
            return text("controls.status.live")
        case (true, false):
            return text("controls.status.paused")
        default:
            return text("controls.status.permission")
        }
    }

    static func controlsAlertRow(bodyName: String, eventLabel: String, relative: String) -> String {
        format("controls.next_alerts.row", bodyName, eventLabel, relative)
    }

    static func notificationTestTitle() -> String {
        text("notification.test.title")
    }

    static func notificationTestBody() -> String {
        text("notification.test.body")
    }

    private static func text(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = text(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}
