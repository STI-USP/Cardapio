//
//  MealPeriod.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

enum MealPeriod: String, Codable, CaseIterable {
    case lunch, dinner

    var localized: String {
        switch self {
        case .lunch:  return "Almoço"
        case .dinner: return "Jantar"
        }
    }
}
