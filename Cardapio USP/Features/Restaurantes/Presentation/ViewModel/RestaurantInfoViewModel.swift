//
//  RestaurantInfoViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class RestaurantInfoViewModel: ObservableObject {
    @Published private(set) var restaurant: Restaurant
    @Published private(set) var isPreferred: Bool

    private let service: RestaurantService

    init(restaurant: Restaurant,
         service: RestaurantService = RestaurantServiceImpl()) {
        self.restaurant   = restaurant
        self.service      = service
        self.isPreferred  = service.preferredRestaurant() == restaurant
    }

    func toggleFavorite() {
        if isPreferred {
            service.setPreferred(restaurant)      // já favorito? mantém
        } else {
            service.setPreferred(restaurant)
        }
        isPreferred = service.preferredRestaurant() == restaurant
    }
}
