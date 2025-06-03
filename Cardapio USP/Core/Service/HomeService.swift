//
//  HomeService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

protocol HomeService: Sendable {
  func loadState() async throws -> HomeState
}

struct HomeServiceImpl: HomeService, @unchecked Sendable {
  
  private let restaurantSvc: RestaurantService
  private let menuSvc:       MenuService
  private let creditSvc:     CreditService
  
  init(restaurant: RestaurantService = RestaurantServiceImpl(),
       menu:       MenuService       = MenuServiceImpl(),
       credit:     CreditService     = CreditServiceImpl()) {
    self.restaurantSvc = restaurant
    self.menuSvc       = menu
    self.creditSvc     = credit
  }
  
  func loadState() async throws -> HomeState {
    // 1. Restaurante favorito ou primeiro da lista remota
    let restaurant: Restaurant
    if let pref = restaurantSvc.preferredRestaurant() {
      restaurant = pref
    } else {
      let campi = try await restaurantSvc.fetchCampi()
      guard let firstRest = campi.first?.restaurants.first else {
        throw NSError(domain: "HomeService", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Sem restaurantes disponíveis"])
      }
      restaurant = firstRest
    }
    
    // 2. Cardápio da semana → filtramos hoje + período atual
    let weekMenus = try await menuSvc.fetchWeek(for: restaurant.id)
    
    // converte CurrentMealPeriod → MealPeriod
    let targetPeriod: MealPeriod = {
      switch MealPeriodCalculator.now() {
      case .lunch:  return .lunch
      case .dinner: return .dinner
      }
    }()
    
    guard let todayMenu = weekMenus.first(where: {
      Calendar.current.isDateInToday($0.date) && $0.period == targetPeriod
    }) else {
      throw NSError(domain: "HomeService", code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Sem cardápio para o horário atual"])
    }
    
    // 3. Saldo
    let balance     = try await creditSvc.fetchBalance()
    let balanceText = balance.formatted(.currency(code: "BRL")
      .precision(.fractionLength(2)))
    
    // 4. Data
       let df = DateFormatter(); df.dateFormat = "dd/MM/yyyy"

       return HomeState(
           restaurantName: restaurant.name.uppercased(),
           balanceText:    balanceText,
           dateText:       df.string(from: todayMenu.date),
           mealPeriod:     targetPeriod.localized,
           items:          todayMenu.items
       )
  }}
