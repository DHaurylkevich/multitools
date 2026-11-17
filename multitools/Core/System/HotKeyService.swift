import AppKit
import HotKey

struct HotKeyShortcut {
    let key: Key
    let modifiers: NSEvent.ModifierFlags

    static let `default` = HotKeyShortcut(key: .k, modifiers: .option)
}

final class HotKeyService {
    private let hotKey: HotKey

    init(shortcut: HotKeyShortcut = .default, onHotKey: @escaping () -> Void) {
        hotKey = HotKey(
            key: shortcut.key,
            modifiers: shortcut.modifiers,
            keyDownHandler: onHotKey
        )
    }
}
