import Foundation

enum RadialMenuBuilder {
    static var rootItems: [RadialMenuItem] {
        var items: [RadialMenuItem] = []
        var placedGroups: Set<AppActionGroup> = []

        for action in AppAction.allCases {
            guard let group = action.group else {
                items.append(RadialMenuItem(action: action))
                continue
            }

            if placedGroups.insert(group).inserted {
                items.append(RadialMenuItem(group: group))
            }
        }

        return items
    }
}
