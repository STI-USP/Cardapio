//  HomeViewModel.swift
//  Cardapio USP
//
//  Criado em 29/05/25 — Atualizado em 17/06/25
//  Implementação completa com suporte a troca dinâmica de restaurante.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
  
  // MARK: – Published
  @Published private(set) var state: HomeState?
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?
  
  // MARK: – Dependências
  private let service: HomeService
  private let restaurantService: RestaurantService
  private let dataModel = DataModel.getInstance() // singleton Obj-C
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: – Init
  init(service: HomeService = HomeServiceImpl(),
       restaurantService: RestaurantService = RestaurantServiceImpl()) {
    self.service = service
    self.restaurantService = restaurantService
    
    setupObservers()
    Task { await load() }
  }
  
  // MARK: – Public API
  func load() async {
    await MainActor.run {
      isLoading = true
      error = nil
    }
    do {
      var loaded = try await service.loadState()
      // Fallback: se HomeService não conseguiu nome ainda
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
  private func setupObservers() {
    NotificationCenter.default.publisher(for: Notification.Name("DidChangeRestaurant"))
      .compactMap { [weak self] _ -> Restaurant? in
        guard let dict = self?.dataModel?.currentRestaurant as? [String: Any] else { return nil }
        return Restaurant(dict: dict)
      }
      .sink { [weak self] restaurant in
        guard let self else { return }
        
        // 1. Atualiza UI instantaneamente
        if let current = self.state {
          self.state = current.withRestaurantName(restaurant.name.uppercased())
        }
        
        // 2. Persiste para próximas sessões
        self.restaurantService.setPreferred(restaurant)
        
        // 3. Faz refresh completo (cardápio, saldo, etc.)
        Task { await self.load() }
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
