//
//  Menu.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct Menu: Equatable, Codable {
    let date: Date
    let period: MealPeriod
    let items: [String]
    let calories: Int?
}
