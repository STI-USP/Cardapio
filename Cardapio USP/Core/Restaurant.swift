//
//  RestaurantRepository.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable, Equatable, Sendable {
  let id: String
  let name: String
  let address: String
  let phones: [String]
  let latitude: Double
  let longitude: Double
  let workingHours: WorkingHours
  let cashiers: [Cashier]
  let photoURL: URL?
}

// MARK: – Auxiliares

struct WorkingHours: Codable, Equatable, Sendable {
  let weekdays, saturday, sunday: MealHours
}

struct MealHours: Codable, Equatable, Sendable {
  let breakfast, lunch, dinner: String
}

struct Cashier: Codable, Equatable, Sendable {
  let address: String
  let workingHours: String
  let prices: Prices
}

struct Prices: Codable, Equatable, Sendable {
  let students: PriceRow
  let special: PriceRow
  let visiting: PriceRow
}

struct PriceRow: Codable, Equatable, Sendable {
  let lunch: String // String para compatibilidade
}
