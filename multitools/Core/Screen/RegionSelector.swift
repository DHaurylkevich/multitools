import AppKit

@MainActor
final class RegionSelector {
    private var windows: [NSWindow] = []
    private var continuation: CheckedContinuation<NSRect?, Never>?

    func selectRegion() async -> NSRect? {
        guard continuation == nil else { return nil }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            presentOverlays()
        }
    }

    private func presentOverlays() {
        NSApp.activate(ignoringOtherApps: true)
        NSCursor.crosshair.push()

        for screen in NSScreen.screens {
            let window = SelectionWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            let view = SelectionView { [weak self] rect in
                self?.finish(with: rect)
            }
            window.contentView = view
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(view)

            windows.append(window)
        }
    }

    private func finish(with rect: NSRect?) {
        guard let continuation else { return }
        self.continuation = nil

        NSCursor.pop()
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()

        continuation.resume(returning: rect)
    }
}

private final class SelectionWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

private final class SelectionView: NSView {
    private let onFinish: (NSRect?) -> Void
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?

    init(onFinish: @escaping (NSRect?) -> Void) {
        self.onFinish = onFinish
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onFinish(nil)
        } else {
            super.keyDown(with: event)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        onFinish(nil)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        currentPoint = point
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)

        guard let selection, selection.width >= 4, selection.height >= 4, let window else {
            onFinish(nil)
            return
        }

        onFinish(window.convertToScreen(convert(selection, to: nil)))
    }

    private var selection: NSRect? {
        guard let startPoint, let currentPoint else { return nil }

        return NSRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.28).setFill()
        dirtyRect.fill()

        guard let selection, selection.width > 0, selection.height > 0 else { return }

        NSColor.clear.setFill()
        selection.fill(using: .copy)

        NSColor.white.setStroke()
        let border = NSBezierPath(rect: selection)
        border.lineWidth = 1
        border.stroke()
    }
}
