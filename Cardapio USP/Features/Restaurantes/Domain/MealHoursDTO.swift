//
//  MealHoursDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct MealHoursDTO: Decodable {
    let breakfast, lunch, dinner: String?
    func toDomain() -> MealHours {
        .init(breakfast: breakfast ?? "",
              lunch:     lunch     ?? "",
              dinner:    dinner    ?? "")
    }
}

