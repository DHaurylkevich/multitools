import SwiftUI

enum AppAction: Hashable {
    case translate(TranslateAction)
    case askAI
    case grammar
}
