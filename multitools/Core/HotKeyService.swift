import Foundation
import HotKey

final class HotKeyService {
    private let hotKey: HotKey
    
    init(onHotKey: @escaping () -> Void ){
        hotKey = HotKey(key: .f, modifiers:[.option])
        
        hotKey.keyDownHandler = onHotKey
    }
}
