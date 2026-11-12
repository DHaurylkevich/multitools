import Foundation

/// Собирает дерево радиального меню из реестра действий.
///
/// Действие без группы попадает в корень, действие с группой — в подменю,
/// которое создаётся при первом появлении этой группы. Порядок пунктов
/// повторяет `AppAction.allCases`.
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
