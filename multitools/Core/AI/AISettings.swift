import Foundation

struct AISettings {
    static let defaultModel = "gemma4:e2b-it-qat"
    static let defaultContextSize = 1024
    static let defaultMaxTokens = 256
    static let defaultTemperature = 0.1

    static let contextSizeRange = 512...8192
    static let maxTokensRange = 32...2048
    static let temperatureRange = 0.0...1.0


    enum KeepAlive: String, CaseIterable, Identifiable {
        case immediately = "0"
        case oneMinute = "1m"
        case fiveMinutes = "5m"
        case thirtyMinutes = "30m"
        case neverLoaded = "-1"

        static let defaultValue: KeepAlive = .oneMinute

        var id: Self { self }

        var title: String {
            switch self {
            case .immediately: return "Unload right after each request"
            case .oneMinute: return "Unload 1 minute after the last request"
            case .fiveMinutes: return "Unload 5 minutes after the last request"
            case .thirtyMinutes: return "Unload 30 minutes after the last request"
            case .neverLoaded: return "Keep loaded"
            }
        }
    }

    private enum Key {
        static let model = "ai.model"
        static let contextSize = "ai.contextSize"
        static let maxTokens = "ai.maxTokens"
        static let temperature = "ai.temperature"
        static let keepAlive = "ai.keepAlive"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var model: String {
        get {
            let stored = defaults.string(forKey: Key.model) ?? ""
            return stored.isEmpty ? Self.defaultModel : stored
        }
        nonmutating set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            defaults.set(trimmed, forKey: Key.model)
        }
    }

    var contextSize: Int {
        get {
            let stored = defaults.integer(forKey: Key.contextSize)
            return stored > 0 ? Self.clamp(stored, to: Self.contextSizeRange) : Self.defaultContextSize
        }
        nonmutating set {
            defaults.set(Self.clamp(newValue, to: Self.contextSizeRange), forKey: Key.contextSize)
        }
    }

    var maxTokens: Int {
        get {
            let stored = defaults.integer(forKey: Key.maxTokens)
            return stored > 0 ? Self.clamp(stored, to: Self.maxTokensRange) : Self.defaultMaxTokens
        }
        nonmutating set {
            defaults.set(Self.clamp(newValue, to: Self.maxTokensRange), forKey: Key.maxTokens)
        }
    }

    var temperature: Double {
        get {
            guard let stored = defaults.object(forKey: Key.temperature) as? Double else {
                return Self.defaultTemperature
            }
            return min(max(stored, Self.temperatureRange.lowerBound), Self.temperatureRange.upperBound)
        }
        nonmutating set {
            let clamped = min(max(newValue, Self.temperatureRange.lowerBound), Self.temperatureRange.upperBound)
            defaults.set(clamped, forKey: Key.temperature)
        }
    }

    var keepAlive: KeepAlive {
        get {
            defaults.string(forKey: Key.keepAlive).flatMap(KeepAlive.init(rawValue:)) ?? .defaultValue
        }
        nonmutating set {
            defaults.set(newValue.rawValue, forKey: Key.keepAlive)
        }
    }

    private static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
