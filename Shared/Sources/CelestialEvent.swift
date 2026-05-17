import Foundation

struct CelestialEvent: Identifiable, Equatable {
    enum Kind: String {
        case enterHorizon
        case exitHorizon

        var localizedLabel: String {
            switch self {
            case .enterHorizon:
                L10n.eventEnterHorizon()
            case .exitHorizon:
                L10n.eventExitHorizon()
            }
        }
    }

    let bodyID: String
    let bodyName: String
    let kind: Kind
    let date: Date

    var id: String {
        "\(bodyID)-\(kind.rawValue)-\(Int(date.timeIntervalSince1970))"
    }
}
