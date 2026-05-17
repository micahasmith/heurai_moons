import Foundation
import SwiftAA

struct ObservingLocation {
    let name: String
    let coordinates: GeographicCoordinates

    init(name: String, coordinates: GeographicCoordinates) {
        self.name = name
        self.coordinates = coordinates
    }

    init(name: String, latitude: Double, longitude: Double, altitudeMeters: Double) {
        self.name = name
        self.coordinates = GeographicCoordinates(
            positivelyWestwardLongitude: Degree(-longitude),
            latitude: Degree(latitude),
            altitude: Meter(altitudeMeters)
        )
    }

    var signature: String {
        let latitude = coordinates.latitude.value
        let longitude = -coordinates.longitude.value
        return String(format: "%.3f,%.3f", locale: Locale(identifier: "en_US_POSIX"), latitude, longitude)
    }

    static var assumedLocality: ObservingLocation {
        ObservingLocation(
            name: "New York City",
            latitude: 40.7128,
            longitude: -74.0060,
            altitudeMeters: 10
        )
    }
}
