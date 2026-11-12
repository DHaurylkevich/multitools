import SwiftUI

protocol MenuAction: Identifiable{
    var title: String { get }
    var icon: String { get }
    var color: Color { get }
    
    static var allActions: [any MenuAction] { get }
    var hasSubmenu: Bool { get }
}

extension MenuAction {
    var hasSubmenu: Bool { false }
}
