//
//  Model.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

//enum MealPeriod: String { case lunch = "Almoço", dinner = "Jantar" }

struct MenuOfDay {
    let date: Date
    let meal: MealPeriod
    let items: [String]
}
