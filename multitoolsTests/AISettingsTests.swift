import Foundation
import Testing
@testable import multitools

struct AISettingsTests {

    @Test func modelFallsBackToDefault() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            #expect(settings.model == AISettings.defaultModel)
            #expect(settings.model == "gemma4:e2b-it-qat")
        }
    }

    @Test func modelIsPersisted() {
        withDefaults { defaults in
            AISettings(defaults: defaults).model = "gemma3:4b"

            #expect(AISettings(defaults: defaults).model == "gemma3:4b")
        }
    }

    @Test func emptyModelFallsBackToDefault() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            settings.model = "   "

            #expect(settings.model == AISettings.defaultModel)
        }
    }

    @Test func modelIsTrimmed() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            settings.model = "  gemma3:4b  "

            #expect(settings.model == "gemma3:4b")
        }
    }

    @Test func generationDefaultsKeepMemorySmall() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            #expect(settings.contextSize == AISettings.defaultContextSize)
            #expect(settings.maxTokens == AISettings.defaultMaxTokens)
            #expect(settings.temperature == AISettings.defaultTemperature)
            #expect(settings.keepAlive == .oneMinute)
            #expect(settings.contextSize < 4096)
        }
    }

    @Test func contextAndResponseLengthAreClamped() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            settings.contextSize = 1_000_000
            settings.maxTokens = 0

            #expect(settings.contextSize == AISettings.contextSizeRange.upperBound)
            #expect(settings.maxTokens == AISettings.maxTokensRange.lowerBound)
        }
    }

    @Test func generationSettingsArePersisted() {
        withDefaults { defaults in
            let settings = AISettings(defaults: defaults)

            settings.contextSize = 4096
            settings.maxTokens = 256
            settings.temperature = 0
            settings.keepAlive = .immediately

            let reloaded = AISettings(defaults: defaults)
            #expect(reloaded.contextSize == 4096)
            #expect(reloaded.maxTokens == 256)
            #expect(reloaded.temperature == 0)
            #expect(reloaded.keepAlive == .immediately)
            #expect(reloaded.keepAlive.rawValue == "0")
        }
    }

    private func withDefaults(_ body: (UserDefaults) -> Void) {
        let suiteName = "AISettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        body(defaults)
    }
}
