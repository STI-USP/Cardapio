//
//  PriceRowDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct PriceRowDTO: Decodable {
  let lunch: String?
  func toDomain() -> PriceRow { .init(lunch: lunch ?? "") }
}
