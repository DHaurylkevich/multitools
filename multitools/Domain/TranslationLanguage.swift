enum TranslationLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case polish = "Polish"
    case russian = "Russian"

    static let `default`: TranslationLanguage = .russian

    var id: String { rawValue }
    var title: String { rawValue }
}
