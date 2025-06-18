//
//  HomeViewModel.swift
//  Cardapio USP
//
//  Criado em 29/05/25 — Atualizado em 18/06/25
//  Versão reativa assinando o `currentPublisher` do RestaurantService.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
  
  // MARK: – Published
  @Published private(set) var state: HomeState?
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?
  
  // Convenience para comparação em `viewWillAppear`
  var currentRestaurantID: String? {
    restaurantService.currentRestaurant()?.id
  }
  
  // MARK: – Dependências
  private let service: HomeService
  private let restaurantService: RestaurantService
  private let dataModel = DataModel.getInstance() // bridge Obj-C (legado)
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: – Init
  init(
    service: HomeService = HomeServiceImpl(restaurant: RestaurantServiceImpl.shared),
    restaurantService: RestaurantService = RestaurantServiceImpl.shared
  ) {
    self.service = service
    self.restaurantService = restaurantService
    
    observeRestaurantChanges()
    Task { await load() }
  }

  deinit {
    print("[VM] deinit")
  }
  
  // MARK: – Public API
  func load() async {
    await MainActor.run {
      isLoading = true
      error = nil
    }
    
    do {
      var loaded = try await service.loadState()
      print("[VM] load() concluído para \(loaded.restaurantName)")
      
      // Fallback: se HomeService não trouxe nome
      if loaded.restaurantName.isEmpty,
         let pref = restaurantService.preferredRestaurant() {
        loaded = loaded.withRestaurantName(pref.name.uppercased())
      }
      
      await MainActor.run {
        state = loaded
        isLoading = false
      }
    } catch {
      await MainActor.run {
        self.error = error.localizedDescription
        self.isLoading = false
      }
    }
  }
  
  // MARK: – Observers
  private func observeRestaurantChanges() {
    restaurantService
      .currentPublisher
      .compactMap { $0 }
      .receive(on: RunLoop.main)
      .sink { [weak self] restaurant in
        guard let self else { return }

        print("[VM] change recebido id = \(restaurant.id)")

        // 1) Atualiza imediatamente o restaurante na UI
        if let cur = state {
          state = cur.withRestaurantName(restaurant.name.uppercased())
        }
        
        // 2) Faz refresh completo (cardápio, saldo etc.)
        Task { await load() }
      }
      .store(in: &cancellables)
  }
}

// MARK: – Helper
private extension HomeState {
  func withRestaurantName(_ name: String) -> HomeState {
    HomeState(
      restaurantName: name,
      balanceText: balanceText,
      dateText: dateText,
      mealPeriod: mealPeriod,
      items: items
    )
  }
}
