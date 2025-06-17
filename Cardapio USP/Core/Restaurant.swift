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


// MARK: - Bridges p/ Obj-C
extension Restaurant {
  /// Constrói a partir do dicionário legado (`NSMutableDictionary`)
  init?(dict: [String: Any]) {
    // id pode vir como Int ou String
    let idValue: String
    if let idInt = dict["id"] as? Int {
      idValue = String(idInt)
    } else if let idStr = dict["id"] as? String {
      idValue = idStr
    } else {
      return nil
    }
    
    guard
      let name        = dict["name"]        as? String,
      let address     = dict["address"]     as? String,
      let lat         = dict["latitude"]    as? Double,
      let lng         = dict["longitude"]   as? Double,
      let whDict      = dict["workinghours"] as? [String: Any],
      let cashArr     = dict["cashiers"]    as? [[String: Any]]
    else { return nil }
    
    // Fallbacks simples para campos faltantes
    let phones = dict["phones"] as? [String] ?? []
    
    // Converte sub-estruturas (bem direta; ajuste se precisar de validação extra)
    guard
      let workingHours = WorkingHours(dict: whDict)
    else { return nil }
    
    let cashiers = cashArr.compactMap(Cashier.init(dict:))
    
    self.init(
      id:         idValue,
      name:       name,
      address:    address,
      phones:     phones,
      latitude:   lat,
      longitude:  lng,
      workingHours: workingHours,
      cashiers:   cashiers,
      photoURL:   URL(string: dict["photoURL"] as? String ?? "")
    )
  }
}

extension WorkingHours {
  init?(dict: [String: Any]) {
    func meal(from d: [String: Any]?) -> MealHours {
      MealHours(
        breakfast: d?["breakfast"] as? String ?? "",
        lunch:     d?["lunch"]     as? String ?? "",
        dinner:    d?["dinner"]    as? String ?? ""
      )
    }
    self.init(
      weekdays: meal(from: dict["weekdays"] as? [String: Any]),
      saturday: meal(from: dict["saturday"] as? [String: Any]),
      sunday:   meal(from: dict["sunday"]   as? [String: Any])
    )
  }
}

extension Prices {
  init?(dict: [String: Any]) {
    func row(_ key: String) -> PriceRow? {
      guard let m = dict[key] as? [String: String],
            let lunch = m["lunch"] else { return nil }
      return PriceRow(lunch: lunch)
    }
    guard let students = row("students"),
          let special  = row("special"),
          let visiting = row("visiting")
    else { return nil }
    self.init(students: students, special: special, visiting: visiting)
  }
}

extension Cashier {
  init?(dict: [String: Any]) {
    guard let addr   = dict["address"]      as? String,
          let wh     = dict["workingHours"] as? String,
          let prices = Prices(dict: dict["prices"] as? [String: Any] ?? [:])
    else { return nil }
    self.init(address: addr, workingHours: wh, prices: prices)
  }
}
