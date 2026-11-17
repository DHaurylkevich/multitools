struct RadialMenuItem: Identifiable {
    let id: String
    let icon: String
    let destination: Destination

    enum Destination {
        case action(AppAction)
        case submenu([RadialMenuItem])
    }

    init(action: AppAction) {
        self.id = action.id
        self.icon = action.icon
        self.destination = .action(action)
    }

    init(group: AppActionGroup) {
        self.id = group.id
        self.icon = group.icon
        self.destination = .submenu(group.actions.map(RadialMenuItem.init(action:)))
    }
}
