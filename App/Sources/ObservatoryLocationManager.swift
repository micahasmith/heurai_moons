@preconcurrency import CoreLocation
import Foundation

@MainActor
final class ObservatoryLocationManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published private(set) var currentLocation: ObservingLocation
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var usesDeviceLocation: Bool

    private let manager = CLLocationManager()
    private let defaults = UserDefaults.standard
    private static let usesDeviceLocationKey = "usesDeviceLocation"
    private static let savedLocationKey = "savedObservingLocation"

    override init() {
        let storedUsesDeviceLocation = UserDefaults.standard.object(forKey: Self.usesDeviceLocationKey) as? Bool ?? false
        let storedLocation = Self.loadSavedLocation(from: UserDefaults.standard, key: Self.savedLocationKey) ?? .assumedLocality
        currentLocation = storedLocation
        authorizationStatus = manager.authorizationStatus
        usesDeviceLocation = storedUsesDeviceLocation
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 5_000
    }

    func start() {
        authorizationStatus = manager.authorizationStatus
        applyLocationMode()
    }

    func setUsesDeviceLocation(_ enabled: Bool) {
        usesDeviceLocation = enabled
        defaults.set(enabled, forKey: Self.usesDeviceLocationKey)
        applyLocationMode()
    }

    func requestAccess() {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
        @unknown default:
            currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if usesDeviceLocation {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
        case .notDetermined:
            break
        @unknown default:
            currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentLocation = ObservingLocation(
            name: L10n.coordinatesLabel(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitudeMeters: location.altitude
        )
        save(location: currentLocation)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
    }

    private func applyLocationMode() {
        if usesDeviceLocation {
            requestAccess()
        } else {
            manager.stopUpdatingLocation()
            currentLocation = Self.loadSavedLocation(from: defaults, key: Self.savedLocationKey) ?? .assumedLocality
        }
    }

    private func save(location: ObservingLocation) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(location.persisted) {
            defaults.set(data, forKey: Self.savedLocationKey)
        }
    }

    private static func loadSavedLocation(from defaults: UserDefaults, key: String) -> ObservingLocation? {
        guard let data = defaults.data(forKey: key),
              let persisted = try? JSONDecoder().decode(ObservingLocation.Persisted.self, from: data) else {
            return nil
        }
        return ObservingLocation(persisted: persisted)
    }
}
