//
//  AddCreditsViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 24/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class AddCreditsViewModel: ObservableObject {
  
  // Saída p/ a View
  @Published private(set) var balanceText: String = "R$ --,--"
  @Published private(set) var lastPix: Pix?
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?
  
  private let service: AddCreditsService
  private var cancellables = Set<AnyCancellable>()
  
  private let brlFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.locale = Locale(identifier: "pt_BR")
    f.numberStyle = .currency
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return f
  }()
  
  init(service: AddCreditsService = AddCreditsLegacyService()) {
    self.service = service
    Task { await load() }
    listenPixNotifications()
  }
  
  // MARK: – API pública
  func load() async {
    isLoading = true
    defer { isLoading = false }
    do {
      let value = try await service.fetchBalance()
      balanceText = brlFormatter.string(from: value as NSNumber) ?? "R$ --,--"
      lastPix = service.fetchLastPix()
    } catch {
      self.error = error.localizedDescription
    }
  }
  
  func generatePix(amountText: String) async {
    isLoading = true
    do {
      try await service.createPix(amount: amountText)  // HUD fecha via notificação
    } catch {
      self.error = error.localizedDescription
      isLoading = false
    }
  }
  
  // MARK: – Notificações
  private func listenPixNotifications() {
    NotificationCenter.default.publisher(for: .init("DidCreatePix"))
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        guard let self else { return }
        Task {
          self.isLoading = false
          self.lastPix = self.service.fetchLastPix()
        }
      }
      .store(in: &cancellables)
  }
}
