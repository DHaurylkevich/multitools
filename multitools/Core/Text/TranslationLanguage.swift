//
//  TranslationLanguage.swift
//  multitools
//
//  Created by Mac on 26/10/2026.
//

import Foundation

enum TranslationLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case polish = "Polish"
    case russian = "Russian"
    case german = "German"

    var id: String { rawValue }

    var title: String { rawValue }
}
