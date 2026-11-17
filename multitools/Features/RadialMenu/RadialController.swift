import SwiftUI

@MainActor
final class RadialController {
    private let router: any ActionRouting
    private let rootItems: [RadialMenuItem]
    private var panel: RadialPanel?

    init(
        router: any ActionRouting,
        rootItems: [RadialMenuItem] = RadialMenuBuilder.rootItems
    ) {
        self.router = router
        self.rootItems = rootItems
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

        panel.contentView = makeContentView(for: panel)

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

        let panelSide = RadialMenuTokens.panelSide
        let panel = RadialPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelSide, height: panelSide),
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

        self.panel = panel
        return panel
    }

    private func makeContentView(for panel: RadialPanel) -> NSView {
        let hostingView = NSHostingView(
            rootView: RadialMenuView(
                items: rootItems,
                onClose: { [weak self, weak panel] in
                    guard let self, let panel else { return }
                    self.close(panel)
                },
                onSelectAction: { [weak self, weak panel] action in
                    guard let self, let panel else { return }
                    self.close(panel)
                    self.router.open(action)
                }
            )
        )

        return hostingView
    }

    private func positionCenteredOnCursor() {
        guard let panel else { return }

        let cursor = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(cursor) } ?? NSScreen.main
        guard let screen else { return }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let margin = RadialMenuTokens.screenEdgeMargin

        let targetX = cursor.x - (panelSize.width / 2)
        let targetY = cursor.y - (panelSize.height / 2)

        let x = min(max(targetX, visibleFrame.minX + margin), visibleFrame.maxX - panelSize.width - margin)
        let y = min(max(targetY, visibleFrame.minY + margin), visibleFrame.maxY - panelSize.height - margin)

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
