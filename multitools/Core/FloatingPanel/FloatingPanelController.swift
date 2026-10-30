//
//  FloatingPanelController.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController: NSObject, NSWindowDelegate {
    private var panel: NSPanel?
    
    func toggle(){
        if let panel, panel.isVisible {
            close(panel)
        }else{
            show()
        }
    }
    
    func show() {
        let panel = makePanel()

        positionNearCursor(panel)
        NSApp.activate(ignoringOtherApps: true)

        panel.makeKeyAndOrderFront(nil)
    }
    
    func close(_ panel: NSPanel) {
        panel.orderOut(nil)
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else {
            return
        }

        close(panel)
    }
    
    private func makePanel() -> NSPanel {
        if let panel {
            return panel
        }

        let panel = FloatingPanel(
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

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        panel.delegate = self

        panel.contentView = NSHostingView(
            rootView: RadialMenuView { action in
                print("Selected action: \(action)")
            }
        )

        self.panel = panel
        return panel
    }
    
    private func positionNearCursor(_ panel: NSPanel) {
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

        panel.setFrameOrigin(
            NSPoint(x: x, y: y)
        )
    }
}
