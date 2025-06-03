//
//  CreditService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

// MARK: – Contrato
protocol CreditService : Sendable {
    func fetchBalance() async throws -> Double
}

struct CreditServiceImpl: CreditService {
    func fetchBalance() async throws -> Double {
        try await Task.sleep(nanoseconds: 200_000_000)
        return 12.34
    }
}
