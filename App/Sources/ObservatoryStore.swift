import Combine
import Foundation
import AppKit

@MainActor
final class ObservatoryStore: ObservableObject {
    @Published private(set) var bundle: ObservatorySnapshotBundle
    @Published private(set) var notificationsEnabled = false
    @Published private(set) var notificationAuthorizationState: NotificationAuthorizationState = .notDetermined
    @Published private(set) var notificationsArmed = true
    @Published private(set) var upcomingEvents: [CelestialEvent] = []
    @Published private(set) var lastTestScheduledAt: Date?
    @Published private(set) var usesDeviceLocation = false

    private let locationManager: ObservatoryLocationManager
    private let notificationScheduler: NotificationScheduler
    private var cancellables: Set<AnyCancellable> = []
    private var refreshTask: Task<Void, Never>?
    private var lastScheduleSignature: String?
    private var hasStarted = false
    private let notificationsArmedKey = "notificationsArmed"

    init(
        locationManager: ObservatoryLocationManager = ObservatoryLocationManager(),
        notificationScheduler: NotificationScheduler = NotificationScheduler()
    ) {
        self.locationManager = locationManager
        self.notificationScheduler = notificationScheduler
        if UserDefaults.standard.object(forKey: notificationsArmedKey) == nil {
            UserDefaults.standard.set(true, forKey: notificationsArmedKey)
        }
        self.notificationsArmed = UserDefaults.standard.bool(forKey: notificationsArmedKey)
        self.bundle = CelestialCatalog.bundle(for: Date(), location: locationManager.currentLocation)
        self.upcomingEvents = Array(CelestialCatalog.upcomingEvents(for: Date(), location: locationManager.currentLocation).prefix(6))
        self.usesDeviceLocation = locationManager.usesDeviceLocation

        locationManager.$currentLocation
            .sink { [weak self] location in
                self?.refresh(now: Date(), location: location, forceSchedule: true)
            }
            .store(in: &cancellables)

        locationManager.$usesDeviceLocation
            .sink { [weak self] enabled in
                self?.usesDeviceLocation = enabled
            }
            .store(in: &cancellables)
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        locationManager.start()
        refresh(now: Date(), location: locationManager.currentLocation, forceSchedule: true)

        refreshTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self.tick()
            }
        }
    }

    private func tick() async {
        refresh(now: Date(), location: locationManager.currentLocation, forceSchedule: false)
    }

    private func refresh(now: Date, location: ObservingLocation, forceSchedule: Bool) {
        bundle = CelestialCatalog.bundle(for: now, location: location)
        upcomingEvents = Array(CelestialCatalog.upcomingEvents(for: now, location: location).prefix(6))

        Task { [weak self] in
            guard let self else { return }
            let state = await notificationScheduler.authorizationState()
            let enabled = state == .authorized
            await MainActor.run {
                self.notificationAuthorizationState = state
                self.notificationsEnabled = enabled
            }

            guard enabled, notificationsArmed else {
                await notificationScheduler.clearPending()
                return
            }

            let signature = scheduleSignature(for: now, location: location)
            let shouldSchedule = forceSchedule || signature != lastScheduleSignature
            guard shouldSchedule else { return }

            await notificationScheduler.scheduleEvents(referenceDate: now, location: location)
            await MainActor.run {
                self.lastScheduleSignature = signature
            }
        }
    }

    private func scheduleSignature(for date: Date, location: ObservingLocation) -> String {
        let bucket = Int(date.timeIntervalSince1970 / (60 * 60 * 6))
        return "\(location.signature)-\(bucket)-\(notificationsArmed)"
    }

    func setNotificationsArmed(_ armed: Bool) {
        notificationsArmed = armed
        UserDefaults.standard.set(armed, forKey: notificationsArmedKey)
        refresh(now: Date(), location: bundle.location, forceSchedule: true)
    }

    func requestNotificationAccess() {
        Task { [weak self] in
            guard let self else { return }
            let currentState = await notificationScheduler.authorizationState()
            if currentState == .denied {
                await MainActor.run {
                    self.notificationAuthorizationState = .denied
                    self.notificationsEnabled = false
                }
                self.openNotificationSystemSettings()
                return
            }
            let granted = await notificationScheduler.requestAuthorization()
            await MainActor.run {
                self.notificationAuthorizationState = granted ? .authorized : .denied
                self.notificationsEnabled = granted
            }
            refresh(now: Date(), location: bundle.location, forceSchedule: true)
        }
    }

    func scheduleTestNotification() {
        Task { [weak self] in
            guard let self else { return }
            guard notificationsEnabled else {
                requestNotificationAccess()
                return
            }
            await notificationScheduler.scheduleTestNotification()
            await MainActor.run {
                self.lastTestScheduledAt = Date()
            }
        }
    }

    func openNotificationSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    func setUsesDeviceLocation(_ enabled: Bool) {
        locationManager.setUsesDeviceLocation(enabled)
    }

    var locationAccessEnabled: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    var locationPermissionDenied: Bool {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return true
        default:
            return false
        }
    }

    func requestLocationAccess() {
        locationManager.requestAccess()
    }

    func openLocationSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    var showsLiveLocationSitePill: Bool {
        usesDeviceLocation && locationAccessEnabled
    }
}
