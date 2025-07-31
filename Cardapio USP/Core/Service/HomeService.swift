//
//  HomeService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

enum HomeServiceError: Error {
  case unauthorized
  case other(Error)
}

protocol HomeService: Sendable {
  func loadState() async throws -> HomeState
  func loadMenuOnly() async throws -> HomeState
}

struct HomeServiceImpl: HomeService, @unchecked Sendable {
  
  private let restaurantSvc: RestaurantService
  private let menuSvc: MenuService
  private let creditSvc: CreditService
  
  init(restaurant: RestaurantService = RestaurantServiceImpl.shared,
       menu: MenuService = MenuServiceImpl(),
       credit: CreditService = CreditServiceLegacyAdapter()) {
    self.restaurantSvc = restaurant
    self.menuSvc = menu
    self.creditSvc = credit
  }
  
  // MARK: Estado completo (saldo + cardápio)
  func loadState() async throws -> HomeState {
    do {
      let menuOnly = try await loadMenuOnly() // cardápio + placeholders
      let balance  = try await creditSvc.fetchBalance()
      let balanceStr = balance.formatted(
          .currency(code: "BRL").precision(.fractionLength(2)))

      return HomeState(
        restaurantName: menuOnly.restaurantName,
        balanceText: balanceStr,
        dateText: menuOnly.dateText,
        mealPeriod: menuOnly.mealPeriod,
        items: menuOnly.items
      )

    } catch {
      if case CreditServiceError.unauthorized = error {
        throw HomeServiceError.unauthorized
      }
      throw HomeServiceError.other(error)
    }
  }
  
  // MARK: Apenas cardápio (sem saldo)
   func loadMenuOnly() async throws -> HomeState {
     
     // MARK: – 1. Restaurante atual, preferido ou primeiro disponível
     let restaurant: Restaurant
     if let current = restaurantSvc.currentRestaurant() {              // sessão
       restaurant = current
     } else if let preferred = restaurantSvc.preferredRestaurant() {   // favorito
       restaurant = preferred
       restaurantSvc.setCurrent(preferred)
     } else {                                                          // fallback
       let campi = try await restaurantSvc.fetchCampi()
       guard let first = campi.first?.restaurants.first else {
         throw NSError(domain: "HomeService",
                       code: 1,
                       userInfo: [NSLocalizedDescriptionKey: "Sem restaurantes disponíveis"])
       }
       restaurant = first
       restaurantSvc.setCurrent(first)
     }
     
     await MainActor.run {
       DataModel.getInstance().currentRestaurant = restaurant.toObjCDictionary()
     }
     
     // MARK: – 2. Cardápio do dia e período atual
     print(restaurant.id)
     let todayMenu = try await menuSvc.fetchToday(for: restaurant.id)
     let targetPeriod: MealPeriod = {
       switch MealPeriodCalculator.now() {
       case .lunch:  return .lunch
       case .dinner: return .dinner
       }
     }()
     
     // MARK: – 3. Formata data
     let formatter = DateFormatter()
     formatter.dateFormat = "dd/MM/yyyy"
     formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
     
     return HomeState(
       restaurantName: restaurant.name.uppercased(),
       balanceText: "R$ --,--",          // placeholder (não-logado)
       dateText: formatter.string(from: todayMenu.date),
       mealPeriod: targetPeriod.localized,
       items: todayMenu.items
     )
     
   }
}
