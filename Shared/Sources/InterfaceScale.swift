import Foundation

enum InterfaceScale {
    static let storageKey = "uiScale"
    static let minimum = 0.72
    static let maximum = 1.18
    static let step = 0.08
    static let `default` = 1.0

    enum Density {
        case editorial
        case balanced
        case tiled
    }

    static func clamped(_ value: Double) -> Double {
        min(max(value, minimum), maximum)
    }

    static func increased(from value: Double) -> Double {
        clamped(value + step)
    }

    static func decreased(from value: Double) -> Double {
        clamped(value - step)
    }

    static func density(for value: Double) -> Density {
        switch value {
        case ..<0.86:
            .tiled
        case ..<1.02:
            .balanced
        default:
            .editorial
        }
    }
}
