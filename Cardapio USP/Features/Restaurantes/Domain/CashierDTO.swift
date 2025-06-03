//
//  CashierDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct CashierDTO: Decodable {
    let address: String
    let workinghours: String
    let prices: PricesDTO
    func toDomain() -> Cashier {
        .init(address: address,
              workingHours: workinghours,
              prices: prices.toDomain())
    }
}

