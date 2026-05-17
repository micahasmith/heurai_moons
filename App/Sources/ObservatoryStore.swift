import Combine
import Foundation

@MainActor
final class ObservatoryStore: ObservableObject {
    @Published private(set) var bundle: ObservatorySnapshotBundle
    @Published private(set) var notificationsEnabled = false

    private let locationManager: ObservatoryLocationManager
    private let notificationScheduler: NotificationScheduler
    private var cancellables: Set<AnyCancellable> = []
    private var refreshTask: Task<Void, Never>?
    private var lastScheduleSignature: String?
    private var hasStarted = false

    init(
        locationManager: ObservatoryLocationManager = ObservatoryLocationManager(),
        notificationScheduler: NotificationScheduler = NotificationScheduler()
    ) {
        self.locationManager = locationManager
        self.notificationScheduler = notificationScheduler
        self.bundle = CelestialCatalog.bundle(for: Date(), location: locationManager.currentLocation)

        locationManager.$currentLocation
            .sink { [weak self] location in
                self?.refresh(now: Date(), location: location, forceSchedule: true)
            }
            .store(in: &cancellables)
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        locationManager.requestAccess()
        refresh(now: Date(), location: locationManager.currentLocation, forceSchedule: true)

        refreshTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self.tick()
            }
        }

        Task { [weak self] in
            guard let self else { return }
            let granted = await notificationScheduler.requestAuthorization()
            await MainActor.run {
                self.notificationsEnabled = granted
            }
            if granted {
                await notificationScheduler.scheduleEvents(referenceDate: Date(), location: bundle.location)
                await MainActor.run {
                    self.lastScheduleSignature = self.scheduleSignature(for: Date(), location: self.bundle.location)
                }
            }
        }
    }

    private func tick() async {
        refresh(now: Date(), location: locationManager.currentLocation, forceSchedule: false)
    }

    private func refresh(now: Date, location: ObservingLocation, forceSchedule: Bool) {
        bundle = CelestialCatalog.bundle(for: now, location: location)

        Task { [weak self] in
            guard let self else { return }
            let enabled = await notificationScheduler.pendingAuthorization()
            await MainActor.run {
                self.notificationsEnabled = enabled
            }

            guard enabled else { return }

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
        return "\(location.signature)-\(bucket)"
    }
}
