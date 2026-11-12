import SwiftUI

/// Презентационная модель сегмента радиального меню.
/// Ничего не знает ни о действиях приложения, ни об окнах.
struct RadialMenuItem: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let destination: Destination

    enum Destination {
        case action(AppAction)
        case submenu([RadialMenuItem])
    }

    init(action: AppAction) {
        self.id = action.id
        self.title = action.title
        self.icon = action.icon
        self.color = action.color
        self.destination = .action(action)
    }

    init(group: AppActionGroup) {
        self.id = group.id
        self.title = group.title
        self.icon = group.icon
        self.color = group.color
        self.destination = .submenu(group.actions.map(RadialMenuItem.init(action:)))
    }
}
