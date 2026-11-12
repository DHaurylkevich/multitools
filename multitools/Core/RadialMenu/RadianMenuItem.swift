import SwiftUI

struct RadialMenuItem: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let destination: Destination

    enum Destination {
        case action(AppAction)
        case submenu(items: [RadialMenuItem])
    }

    init(title: String, icon: String, color: Color, action: AppAction) {
        self.id = title
        self.title = title
        self.icon = icon
        self.color = color
        self.destination = .action(action)
    }

    init(title: String, icon: String, color: Color, submenu: [RadialMenuItem]) {
        self.id = title
        self.title = title
        self.icon = icon
        self.color = color
        self.destination = .submenu(items: submenu)
    }

    static let defaultMenu: [RadialMenuItem] = [
        RadialMenuItem(
            title: "Translate",
            icon: "character.bubble",
            color: .purple,
            submenu: TranslateAction.allCases.map { sub in
                RadialMenuItem(
                    title: sub.title,
                    icon: sub.icon,
                    color: sub.color,
                    action: .translate(sub)
                )
            }
        ),
        RadialMenuItem(title: "Ask AI", icon: "sparkles", color: .blue, action: .askAI),
        RadialMenuItem(title: "Grammar", icon: "sparkles", color: .green, action: .grammar)
    ]
}

