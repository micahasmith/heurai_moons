import Foundation

struct CelestialMetric: Identifiable, Equatable {
    let label: String
    let value: String

    var id: String { label }
}

struct CelestialSnapshot: Identifiable, Equatable {
    let id: String
    let name: String
    let glyph: String
    let statusTitle: String
    let statusDetail: String
    let primaryValue: String
    let primaryLabel: String
    let visibleNow: Bool
    let ringFraction: Double
    let ringText: String
    let metrics: [CelestialMetric]
    let footer: String
}

struct ObservatorySnapshotBundle {
    let location: ObservingLocation
    let generatedAt: Date
    let visibleCount: Int
    let sections: [CelestialSnapshot]
}
