import AppKit
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
        positionNearCursor()

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
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 190,
                height: 190
            ),
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

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        panel.contentView = NSHostingView(
            rootView: RadialMenuView { [weak self] action in
                guard let self else {
                    return
                }

                self.close(panel)
                self.router.open(action)
            }
        )

        self.panel = panel
        return panel
    }

    private func positionNearCursor() {
        guard let panel else {
            return
        }

        let cursor = NSEvent.mouseLocation

        let screen = NSScreen.screens.first {
            $0.frame.contains(cursor)
        } ?? NSScreen.main

        guard let screen else {
            return
        }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let margin: CGFloat = 8

        let x = min(
            max(cursor.x + margin, visibleFrame.minX),
            visibleFrame.maxX - panelSize.width
        )

        let y = min(
            max(cursor.y - panelSize.height - margin, visibleFrame.minY),
            visibleFrame.maxY - panelSize.height
        )

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
