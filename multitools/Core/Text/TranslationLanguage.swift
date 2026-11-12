enum TranslationLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case polish = "Polish"
    case russian = "Russian"
    case german = "German"

    /// Язык перевода по умолчанию — единый для всех сценариев.
    static let `default`: TranslationLanguage = .russian

    var id: String { rawValue }
    var title: String { rawValue }
}
