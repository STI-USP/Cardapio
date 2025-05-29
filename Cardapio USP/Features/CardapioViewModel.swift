//
//  CardapioViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Combine

final class CardapioViewModel: ObservableObject {
  @Published private(set) var restaurantName: String? = nil
  @Published private(set) var formattedDate: String? = nil
  @Published private(set) var mealPeriod: String? = nil
  @Published private(set) var items: [String] = []
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?
  
  private let menuService: MenuService
  private var cancellables = Set<AnyCancellable>()
  
  init(menuService: MenuService = MenuServiceImpl(),
       restaurantName: String,
       restaurantId: String) {
    self.menuService = menuService
    self.restaurantName = restaurantName
    load(restaurantId: restaurantId)
  }
  
  func load(restaurantId: String) {
    isLoading = true
    error = nil
    
    menuService.fetchToday(for: restaurantId) { [weak self] result in
      guard let self else { return }
      self.isLoading = false
      switch result {
      case .success(let menu):
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        formattedDate = df.string(from: menu.date)
        mealPeriod   = menu.meal.rawValue
        items        = menu.items
      case .failure(let err):
        error = err.localizedDescription
      }
    }
  }
}
