//
//  CampusDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct CampusDTO: Decodable {
  let name: String
  let restaurants: [RestaurantDTO]
  
  func toDomain() -> Campus {
    Campus(name: name, restaurants: restaurants.map { $0.toDomain() })
  }
}
