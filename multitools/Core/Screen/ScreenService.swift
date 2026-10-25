//
//  ScreenService.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

protocol ScreenCapturing {
    func capture() -> String
}


struct ScreenService: ScreenCapturing {
    func capture()  -> String {
        return "Scrinshot"
    }
}
