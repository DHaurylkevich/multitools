import Foundation

enum ScreenshotTextError: LocalizedError {
    case cancelled
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Захват экрана отменён."
        case .noTextFound:
            return "На снимке экрана не обнаружен читаемый текст."
        }
    }
}
