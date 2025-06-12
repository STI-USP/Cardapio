//
//  MenuDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//

import Foundation

// MARK: - DTOs vindos do backend
/// Raiz da resposta `menu/{restaurantId}`
struct MenuWeekDTO: Decodable {
    let meals: [MealDTO]
    let observation: ObservationDTO?
}

struct ObservationDTO: Decodable {
    let observation: String?
}

/// Cada dia da semana
struct MealDTO: Decodable {
    let date: String
    let lunch: PeriodDTO
    let dinner: PeriodDTO
}

/// Bloco “lunch” ou “dinner”
struct PeriodDTO: Decodable {
    let menu: String
    let calories: String
}

// MARK: - Mapeamento para domínio
private extension MealDTO {
  
  static let df: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    f.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    return f
  }()
}

extension MealDTO {

    /// Converte o dia em **dois** `Menu` (almoço + jantar)
    func toDomain() -> [Menu] {
        let day = Self.df.date(from: date) ?? Date()

        let lunchMenu = Menu(
            date: day,
            period: .lunch,
            items: lunch.menu
                    .split(separator: "\n")
                    .map(String.init),
            calories: Int(lunch.calories) ?? 0
        )

        let dinnerMenu = Menu(
            date: day,
            period: .dinner,
            items: dinner.menu
                    .split(separator: "\n")
                    .map(String.init),
            calories: Int(dinner.calories) ?? 0
        )

        return [lunchMenu, dinnerMenu]
    }
}

extension MenuWeekDTO {
    /// Converte a semana inteira em `[Menu]`
    func toDomain() -> [Menu] { meals.flatMap { $0.toDomain() } }
}
