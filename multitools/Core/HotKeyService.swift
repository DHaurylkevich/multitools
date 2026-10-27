//
//  HotKeyService.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import Foundation
import HotKey

final class HotKeyService {
    private let hotKey = HotKey(key: .space, modifiers:[.control, .command])
    
    init(){
        hotKey.keyDownHandler = {
            print("It's work")
        }
    }
}

 
