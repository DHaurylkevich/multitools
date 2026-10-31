import SwiftUI

enum RadialMenuAction: String, CaseIterable, Identifiable {
    case translate, askAI, grammar

    var id: Self { self }

    var title: String {
        switch self {
        case .translate: "Translate"
        case .askAI: "Ask AI"
        case .grammar: "Grammary"
        }
    }

    var icon: String {
        switch self {
        case .translate: "character.bubble"
        case .askAI: "sparkles"
        case .grammar: "pen"
        }
    }

    var color: Color {
        switch self {
        case .translate: .purple
        case .askAI: .blue
        case .grammar: .green
        }
    }
}
