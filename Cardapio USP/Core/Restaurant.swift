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


// MARK: - Bridge Obj-C → Swift
extension Restaurant {

    /// Constrói a partir do dicionário legado (`NSMutableDictionary`).
    /// Não dá `nil` por detalhe de tipo: converte e preenche com default
    /// sempre que possível.
    init?(dict: [String: Any]) {

        // ───────────── id ─────────────
        let id: String
        switch dict["id"] {
        case let int as Int:  id = String(int)
        case let str as String where !str.isEmpty: id = str
        default: return nil                    // id é obrigatório
        }

        // ──────────── nome ────────────
        guard let name = (dict["alias"] as? String) ??
                         (dict["name"]  as? String) else { return nil }

        // ────────── endereço ──────────
        let address = dict["address"] as? String ?? ""

        // ───── latitude / longitude ───
        func toDouble(_ any: Any?) -> Double? {
            switch any {
            case let d as Double: return d
            case let s as String:
                return Double(s.replacingOccurrences(of: ",", with: "."))
            default: return nil
            }
        }
        let latitude  = toDouble(dict["latitude"])  ?? 0
        let longitude = toDouble(dict["longitude"]) ?? 0

        // ─────────── telefones ─────────
        let phones: [String]
        if let arr = dict["phones"] as? [String] {
            phones = arr
        } else if let str = dict["phones"] as? String {
            // “(11) 3091-0495, (11) 3091-3318” → dois itens
            phones = str.components(separatedBy: CharacterSet(charactersIn: ",;|"))
                         .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                         .filter { !$0.isEmpty }
        } else {
            phones = []
        }

        // ────── working hours / caixa ───
        let whDict   = dict["workinghours"] as? [String: Any] ?? [:]
        let cashArr  = dict["cashiers"]     as? [[String: Any]] ?? []

        let workingHours = WorkingHours(dict: whDict) ?? .empty
        let cashiers     = cashArr.compactMap(Cashier.init(dict:))

        // ─────────── foto ──────────────
        let photoStr = (dict["photourl"] as? String) ??
                       (dict["photoURL"] as? String) ?? ""
        let photoURL = URL(string: photoStr)

        // ─────────── init final ────────
        self.init(id:           id,
                  name:         name,
                  address:      address,
                  phones:       phones,
                  latitude:     latitude,
                  longitude:    longitude,
                  workingHours: workingHours,
                  cashiers:     cashiers,
                  photoURL:     photoURL)
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


extension WorkingHours {
    static let empty = WorkingHours(weekdays: .empty, saturday: .empty, sunday: .empty)
}

extension MealHours {
    static let empty = MealHours(breakfast: "", lunch: "", dinner: "")
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
