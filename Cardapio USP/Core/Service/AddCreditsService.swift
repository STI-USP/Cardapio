//
//  AddCreditsService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 24/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

@MainActor
protocol AddCreditsService {
    func fetchBalance() async throws -> Double
    func fetchLastPix() -> Pix?
    func createPix(amount: String) async throws
}

/// Adapta o legado (`CreditServiceLegacyAdapter` + `CheckoutDataModel`)
@MainActor
final class AddCreditsLegacyService: AddCreditsService {

    private let creditService: CreditService
    private let checkout = CheckoutDataModel.sharedInstance()

    init(creditService: CreditService = CreditServiceLegacyAdapter()) {
        self.creditService = creditService
    }

    func fetchBalance() async throws -> Double {
        try await creditService.fetchBalance()
    }

    func fetchLastPix() -> Pix? {
        checkout?.getLastPix()
        guard let dict = checkout?.pix as? [String: Any] else { return nil }
        return Pix(bridging: VMPix.model(with: dict))
    }

    func createPix(amount: String) async throws {
        checkout?.valorRecarga = amount
        checkout?.createPix()
    }
}
