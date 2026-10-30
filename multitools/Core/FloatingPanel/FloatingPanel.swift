//
//  FloatingPanel.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import AppKit

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }

}
