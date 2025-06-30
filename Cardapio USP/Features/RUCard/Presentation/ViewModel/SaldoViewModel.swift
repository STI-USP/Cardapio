//
//  SaldoViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Combine

@MainActor
final class SaldoViewModel: ObservableObject {
  
  @Published private(set) var balanceText: String? = "R$ --,--"
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?
  
  private let creditService: CreditService
  private var cancellables = Set<AnyCancellable>()
  
  init(creditService: CreditService = CreditServiceImpl()) {
    self.creditService = creditService
    load()
  }
  
  func load() {
    Task {
      do {
        let value = try await creditService.fetchBalance()
        balanceText = "R$ \(value.formatted(.number.precision(.fractionLength(2))))"
      } catch {
        self.error = error.localizedDescription
      }
    }
  }
}
