import Foundation
import HotKey

/// Глобальный хоткей открытия радиального меню: ⌥K.
/// Регистрация происходит в инициализации; если система не отдала
/// комбинацию (занята другим приложением), обработчик просто не вызывается.
final class HotKeyService {
    private let hotKey: HotKey

    init(onHotKey: @escaping () -> Void) {
        hotKey = HotKey(key: .k, modifiers: [.option])
        
        hotKey.keyDownHandler = onHotKey
    }
}
