@preconcurrency import CoreLocation
import Foundation

@MainActor
final class ObservatoryLocationManager: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    @Published private(set) var currentLocation: ObservingLocation = .assumedLocality
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 5_000
    }

    func requestAccess() {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            currentLocation = .assumedLocality
        @unknown default:
            currentLocation = .assumedLocality
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            currentLocation = .assumedLocality
        case .notDetermined:
            break
        @unknown default:
            currentLocation = .assumedLocality
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
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        currentLocation = .assumedLocality
    }
}
