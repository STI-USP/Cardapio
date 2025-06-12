//
//  HomeService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

protocol HomeService: Sendable {
  func loadState() async throws -> HomeState
}

struct HomeServiceImpl: HomeService, @unchecked Sendable {
  
  private let restaurantSvc: RestaurantService
  private let menuSvc: MenuService
  private let creditSvc: CreditService
  
  init(restaurant: RestaurantService = RestaurantServiceImpl(),
       menu: MenuService = MenuServiceImpl(),
       credit: CreditService = CreditServiceImpl()) {
    self.restaurantSvc = restaurant
    self.menuSvc = menu
    self.creditSvc = credit
  }
  
  func loadState() async throws -> HomeState {
    
    // MARK: – 1. Restaurante preferido ou primeiro disponível
    let restaurant: Restaurant
    if let preferred = restaurantSvc.preferredRestaurant() {
      restaurant = preferred
    } else {
      let campi = try await restaurantSvc.fetchCampi()
      guard let first = campi.first?.restaurants.first else {
        throw NSError(domain: "HomeService",
                      code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Sem restaurantes disponíveis"])
      }
      restaurant = first
    }
    
    // MARK: – 2. Cardápio do dia e período atual
    let weekMenus = try await menuSvc.fetchWeek(for: restaurant.id)
    
    let targetPeriod: MealPeriod = {
      switch MealPeriodCalculator.now() {
      case .lunch:  return .lunch
      case .dinner: return .dinner
      }
    }()
    
    let saoPauloTimeZone = TimeZone(identifier: "America/Sao_Paulo")!
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = saoPauloTimeZone
    
    let todayInSP = Date()
    
    guard let todayMenu = weekMenus.first(where: { menu in
      return calendar.isDate(menu.date, inSameDayAs: todayInSP)
      && menu.period == targetPeriod
    }) else {
      throw NSError(domain: "HomeService",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Sem cardápio disponível para o horário atual"])
    }
    
    // MARK: – 3. Saldo formatado em BRL
    let balance = try await creditSvc.fetchBalance()
    let balanceText = balance.formatted(.currency(code: "BRL")
      .precision(.fractionLength(2)))
    
    // MARK: – 4. Formata data
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
    
    
    print(">>> Restaurante:", restaurant.name)
    print(">>> Período alvo:", targetPeriod)
    print(">>> Hoje (Sao Paulo):", DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
    print(">>> Menus disponíveis:", weekMenus.map { "\($0.date) - \($0.period)" })
    
    
    return HomeState(
      restaurantName: restaurant.name.uppercased(),
      balanceText: balanceText,
      dateText: formatter.string(from: todayMenu.date),
      mealPeriod: targetPeriod.localized,
      items: todayMenu.items
    )
  }
}
