////
////  CardapioViewModel.swift
////  Cardapio USP
////
////  Created by Vagner Machado on 30/04/25.
////  Copyright © 2025 USP. All rights reserved.
////
//
//import Combine
//import Foundation
//
//@MainActor
//final class CardapioViewModel: ObservableObject {
//  // Exposto à View
//  @Published private(set) var restaurantName: String?
//  @Published private(set) var formattedDate: String?
//  @Published private(set) var mealPeriod: String?
//  @Published private(set) var items: [String] = []
//  @Published private(set) var isLoading = false
//  @Published private(set) var error: String?
//  
//  // Dependências
//  private let menuService: MenuService
//  private let dateFormatter: DateFormatter
//  
//  init(menuService: MenuService = MenuServiceImpl(),
//       restaurantName: String,
//       restaurantId: String) {
//    self.menuService = menuService
//    self.restaurantName = restaurantName
//    
//    dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "dd/MM/yyyy"
//    dateFormatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
//    
//    Task {
//      await load(restaurantId: restaurantId)
//    }
//  }
//  
//  func load(restaurantId: String) async {
//    do {
//      isLoading = true; error = nil
//      let menu = try await menuService.fetchToday(for: restaurantId)
//      formattedDate = dateFormatter.string(from: menu.date)
//      mealPeriod = menu.period.localized
//      items = menu.items
//      isLoading = false
//    } catch {
//      self.error = error.localizedDescription
//      isLoading = false
//    }
//  }
//}
