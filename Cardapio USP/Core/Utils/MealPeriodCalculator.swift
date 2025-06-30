//
//  MealPeriodCalculator.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

enum CurrentMealPeriod: String, Sendable {
  case lunch  = "almoço"
  case dinner = "jantar"
}

struct MealPeriodCalculator: Sendable {
  /// Retorna .lunch até 15h; depois .dinner
  static func now(in calendar: Calendar = .current,
                  reference: Date = .init()) -> CurrentMealPeriod {
    let hour = calendar.component(.hour, from: reference)
    return (hour < 15) ? .lunch : .dinner
  }
}
