//
//  AIProvider.swift
//  multitools
//
//  Created by Mac on 25/10/2026.
//

import Foundation

protocol AIProvider{
    func generate(
        systemPromt: String,
        userPromp: String
    ) async throws -> Stringž
}
