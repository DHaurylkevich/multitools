import AppKit
import SwiftUI

@MainActor
final class WindowRouter {
    private let dispatcher: ActionDispatcher

    init(dispatcher: ActionDispatcher) {
        self.dispatcher = dispatcher
    }

    func open(_ action: RadialMenuAction) {
        let window = makeWindow(for: action)

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    private func makeWindow(for action: RadialMenuAction) -> NSWindow {
        let window = NSWindow(
            contentViewController: NSHostingController(
                rootView: view(for: action)
            )
        )

        window.title = action.title
        window.styleMask = [
            .titled,
            .closable,
            .miniaturizable,
            .resizable
        ]

        window.isReleasedWhenClosed = false
        window.setContentSize(
            NSSize(width: 480, height: 520)
        )

        window.center()

        return window
    }

    @ViewBuilder
    private func view(for action: RadialMenuAction) -> some View {
        switch action {
        case .translate:
            TranslateView(dispatcher: dispatcher)

        case .askAI:
            AskAIView(dispatcher: dispatcher)
        
        case .grammar:
            Text("Grammar")
        }
    }
}
