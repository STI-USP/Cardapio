//
//  PricesDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct PricesDTO: Decodable {
    let students, special, visiting: PriceRowDTO
    func toDomain() -> Prices {
        .init(students: students.toDomain(),
              special:  special .toDomain(),
              visiting: visiting.toDomain())
    }
}

