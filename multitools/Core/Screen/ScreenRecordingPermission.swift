import CoreGraphics

enum ScreenRecordingPermission {
    static func requestIfNeeded() -> Bool {
        if CGPreflightScreenCaptureAccess() {
            return true
        }

        return CGRequestScreenCaptureAccess()
    }
}
