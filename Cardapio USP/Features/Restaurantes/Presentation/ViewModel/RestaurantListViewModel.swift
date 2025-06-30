//
//  RestaurantListViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class RestaurantListViewModel: ObservableObject {
    @Published private(set) var campi: [Campus] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let service: RestaurantService

    init(service: RestaurantService = RestaurantServiceImpl()) {
        self.service = service
        Task { await load() }
    }

    func load() async {
        isLoading = true; error = nil
        do {
            campi = try await service.fetchCampi()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    // Convenience para a UI
    func restaurants(in section: Int) -> [Restaurant] {
        campi[safe: section]?.restaurants ?? []
    }

    func select(_ restaurant: Restaurant) {
        service.setPreferred(restaurant)
    }

    func isPreferred(_ restaurant: Restaurant) -> Bool {
        restaurant == service.preferredRestaurant()
    }
}
