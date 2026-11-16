import SwiftUI

struct ToolWindow {
    let id: String
    let title: String
    let size: CGSize
    let content: AnyView
    var replaceExistingContent: Bool = true
}
