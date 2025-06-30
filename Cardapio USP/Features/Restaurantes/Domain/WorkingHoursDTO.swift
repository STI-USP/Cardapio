//
//  WorkingHoursDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct WorkingHoursDTO: Decodable {
  let weekdays, saturday, sunday: MealHoursDTO
  func toDomain() -> WorkingHours {
    .init(weekdays: weekdays.toDomain(),
          saturday: saturday.toDomain(),
          sunday:  sunday.toDomain())
  }
}

