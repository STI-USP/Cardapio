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
  
  deinit { print("[VM] deinit") }
  
  // MARK: – Public API
  func load() async {
    await MainActor.run {
      isLoading = true
      error = nil
    }
    
    do {
          let loaded = try await service.loadState()
          await MainActor.run {
            self.state     = self.enrichWithFallbackName(loaded)
            self.isLoading = false
          }

        } catch {
          // se for não‑logado, tenta buscar apenas cardápio público
          if case HomeServiceError.unauthorized = error {
            await fetchMenuOnly()
          } else {
            await MainActor.run {
              // MenuServiceError já fornece mensagens amigáveis através de LocalizedError
              let errorMessage = error.localizedDescription
              print("🔴 [HomeViewModel] Erro capturado: \(errorMessage)")
              self.error = errorMessage
              self.isLoading = false
              if self.state == nil, let cached = HomeCache.shared.load() {
                self.state = self.enrichWithFallbackName(cached)
              }
            }
          }
        }
      }

  // MARK: – Menu público (sem saldo)
  private func fetchMenuOnly() async {
    do {
      let menu = try await service.loadMenuOnly()
      await MainActor.run {
        self.state = self.enrichWithFallbackName(menu)
        self.isLoading = false
      }
    } catch {
      await MainActor.run {
        // Exibe mensagem amigável em caso de erro (ex: cardápio não disponível)
        let errorMessage = error.localizedDescription
        print("🔴 [HomeViewModel.fetchMenuOnly] Erro capturado: \(errorMessage)")
        self.error = errorMessage
        self.isLoading = false
        if self.state == nil, let cached = HomeCache.shared.load() {
          self.state = self.enrichWithFallbackName(cached)
        }
      }
    }
  }
  
  // MARK: – Observers
  private func observeRestaurantChanges() {
    restaurantService.currentPublisher
      .compactMap { $0 }
      .removeDuplicates(by: { $0.id == $1.id })
      .dropFirst()
      .receive(on: RunLoop.main)
      .sink { [weak self] restaurant in
        guard let self else { return }
        
        // 1) Atualiza imediatamente o restaurante na UI
        if let cur = state {
          state = cur.withRestaurantName(restaurant.name.uppercased())
        }
        
        // 2) Faz refresh completo (cardápio, saldo etc.)
        Task { await load() }
      }
      .store(in: &cancellables)
  }
  
  // MARK: – Helper
  private func enrichWithFallbackName(_ state: HomeState) -> HomeState {
    guard state.restaurantName.isEmpty,
          let pref = restaurantService.preferredRestaurant() else { return state }
    return state.withRestaurantName(pref.name.uppercased())
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
