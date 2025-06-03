//
//  Campus.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct Campus: Identifiable, Codable, Equatable, Sendable {
    let id: UUID = .init()
    let name: String
    let restaurants: [Restaurant]
}
