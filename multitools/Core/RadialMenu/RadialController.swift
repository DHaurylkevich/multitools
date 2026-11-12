import SwiftUI

@MainActor
final class RadialController {
    private let router: WindowRouter
    private var panel: RadialPanel?

    init(router: WindowRouter) {
        self.router = router
    }

    func toggle() {
        if let panel, panel.isVisible {
            close(panel)
        } else {
            show()
        }
    }

    private func show() {
        let panel = makePanel()
        positionCenteredOnCursor()

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    private func close(_ panel: NSPanel) {
        panel.orderOut(nil)
    }

    private func makePanel() -> RadialPanel {
        if let panel {
            return panel
        }

        let panel = RadialPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        panel.contentView = NSHostingView(
            rootView: RadialMenuView(
                onClose: { [weak self, weak panel] in
                    guard let self, let panel else { return }
                    self.close(panel)
                },
                onSelectAction: { [weak self, weak panel] action in
                    guard let self, let panel else { return }
                    // Закрываем меню только при выборе действия
                    self.close(panel)
                    self.router.open(action)
                }
            )
        )

        self.panel = panel
        return panel
    }

    private func positionCenteredOnCursor() {
        guard let panel else { return }

        let cursor = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(cursor) } ?? NSScreen.main
        guard let screen else { return }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let margin: CGFloat = 8

        let targetX = cursor.x - (panelSize.width / 2)
        let targetY = cursor.y - (panelSize.height / 2)

        let x = min(max(targetX, visibleFrame.minX + margin), visibleFrame.maxX - panelSize.width - margin)
        let y = min(max(targetY, visibleFrame.minY + margin), visibleFrame.maxY - panelSize.height - margin)

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
