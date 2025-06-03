//
//  HomeState.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct HomeState: Sendable, Equatable {
    let restaurantName: String
    let balanceText: String
    let dateText: String
    let mealPeriod: String
    let items: [String]
}
