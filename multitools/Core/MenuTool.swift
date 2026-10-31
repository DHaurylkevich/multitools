import SwiftUI

struct MenuTool: Identifiable {
    let id: String
    let label: String
    let icon: String
    let color: Color
    let action: RadialMenuAction
}
