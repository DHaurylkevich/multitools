import Foundation

enum ScreenCaptureError: LocalizedError {
    case permissionDenied
    case cancelled
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Приложению нужен доступ к записи экрана. Включите multitools в «Системные настройки» → «Конфиденциальность и безопасность» → «Запись экрана» и попробуйте снова."
        case .cancelled:
            return "Захват экрана отменён."
        case .failed(let reason):
            return "Не удалось сделать снимок экрана: \(reason)"
        }
    }
}
