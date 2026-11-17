import AppKit
import CoreGraphics

struct CaptureRegion: Equatable {
    let sourceRect: CGRect
    let pixelWidth: Int
    let pixelHeight: Int
}

struct CaptureSize: Equatable {
    let width: Int
    let height: Int
}

enum CaptureGeometry {
    static func screen(containing point: NSPoint, in screens: [NSScreen] = NSScreen.screens) -> NSScreen? {
        screens.first { $0.frame.contains(point) }
    }

    static func displayID(of screen: NSScreen) -> CGDirectDisplayID? {
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }

    static func pixelScale(screenWidth: CGFloat, displayPixelWidth: Int) -> CGFloat {
        guard screenWidth > 0 else { return 1 }
        return CGFloat(displayPixelWidth) / screenWidth
    }

    /// Размер выходного кадра: пропорции сохраняются, длинная сторона не превышает `maxDimension`.
    /// Небольшие области не апскейлятся.
    static func outputSize(pixelWidth: Int, pixelHeight: Int, maxDimension: CGFloat) -> CaptureSize {
        let longest = CGFloat(max(pixelWidth, pixelHeight))
        guard maxDimension > 0, longest > maxDimension else {
            return CaptureSize(width: pixelWidth, height: pixelHeight)
        }

        let scale = maxDimension / longest
        return CaptureSize(
            width: max(Int((CGFloat(pixelWidth) * scale).rounded()), 1),
            height: max(Int((CGFloat(pixelHeight) * scale).rounded()), 1)
        )
    }

    static func region(for selection: NSRect, screenFrame: NSRect, pixelScale: CGFloat) -> CaptureRegion? {
        let part = selection.intersection(screenFrame)
        guard part.width >= 1, part.height >= 1 else {
            return nil
        }

        return CaptureRegion(
            sourceRect: CGRect(
                x: part.minX - screenFrame.minX,
                y: screenFrame.maxY - part.maxY,
                width: part.width,
                height: part.height
            ),
            pixelWidth: max(Int((part.width * pixelScale).rounded()), 1),
            pixelHeight: max(Int((part.height * pixelScale).rounded()), 1)
        )
    }
}
