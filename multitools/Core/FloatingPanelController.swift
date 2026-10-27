//
//  FloatingPanelController.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController {
    private let dispatcher: ActionDispatcher

    private var panel: NSPanel?
    private var hostingController: NSHostingController<AnyView>?

    init(dispatcher: ActionDispatcher) {
        self.dispatcher = dispatcher
    }

    func toggle() {
        if let panel, panel.isVisible {
            panel.orderOut(nil)
        } else {
            showMenu()
        }
    }

    private func showMenu() {
        let panel = makePanel()
        setSize(NSSize(width: 252, height: 150))
        updateContent(
            AnyView(
                RadialMenuView { [weak self] action in
                    self?.showTool(action)
                }
            )
        )

        positionNearCursor()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showTool(_ action: RadialMenuAction) {
        let content: AnyView

        switch action {
        case .translate:
            content = AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    backButton
                    TranslateView(dispatcher: dispatcher)
                }
            )

        case .askAI:
            content = AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    backButton
                    AskAIView(dispatcher: dispatcher)
                }
            )
        }

        updateContent(content)
        setSize(NSSize(width: 380, height: 500))
        positionNearCursor()
    }

    private var backButton: some View {
        Button {
            self.showMenu()
        } label: {
            Label("Back", systemImage: "chevron.left")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func makePanel() -> NSPanel {
        if let panel {
            return panel
        }

        let panel = NSPanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 252,
                height: 150
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        let hostingController = NSHostingController(
            rootView: AnyView(EmptyView())
        )

        panel.contentViewController = hostingController

        self.panel = panel
        self.hostingController = hostingController

        return panel
    }

    private func updateContent(_ content: AnyView) {
        _ = makePanel()
        hostingController?.rootView = content
    }

    private func setSize(_ size: NSSize) {
        guard let panel else { return }

        var frame = panel.frame
        frame.size = size
        panel.setFrame(frame, display: true)
    }

    private func positionNearCursor() {
        guard let panel else { return }

        let cursor = NSEvent.mouseLocation

        let screen = NSScreen.screens.first {
            $0.frame.contains(cursor)
        } ?? NSScreen.main

        guard let screen else { return }

        let visibleFrame = screen.visibleFrame
        let size = panel.frame.size
        let margin: CGFloat = 8

        let x = min(
            max(cursor.x + margin, visibleFrame.minX),
            visibleFrame.maxX - size.width
        )

        let y = min(
            max(cursor.y - size.height - margin, visibleFrame.minY),
            visibleFrame.maxY - size.height
        )

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
