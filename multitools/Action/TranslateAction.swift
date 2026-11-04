enum TranslateAction: String, CaseIterable, Identifiable {
    case text
    case selection
    case screenshot

    var id: Self { self }

    var title: String {
        switch self {
        case .text: "Text"
        case .selection: "Selection"
        case .screenshot: "Screenshot"
        }
    }

    var icon: String {
        switch self {
        case .text: "text.alignleft"
        case .selection: "text.cursor"
        case .screenshot: "camera"
        }
    }
}
