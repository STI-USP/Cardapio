//
//  RestaurantService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

protocol RestaurantService: Sendable {
    func fetchCampi() async throws -> [Campus]
    func preferredRestaurant() -> Restaurant?
    func setPreferred(_ restaurant: Restaurant)
}

final class RestaurantServiceImpl: RestaurantService, @unchecked Sendable {

    private let client: any HTTPClient
    private let base = URL(string: "https://uspdigital.usp.br/rucard/servicos/")!
    private let defaults = UserDefaults.standard
    private let prefKey = "preferredRestaurant"

    init(client: any HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    // MARK: – API pública
    func fetchCampi() async throws -> [Campus] {
        let dto = try await post([CampusDTO].self, path: "restaurants")
        return dto.map { $0.toDomain() }
    }

    func preferredRestaurant() -> Restaurant? {
        guard let data = defaults.data(forKey: prefKey),
              let rest = try? JSONDecoder().decode(Restaurant.self, from: data)
        else { return nil }
        return rest
    }

    func setPreferred(_ restaurant: Restaurant) {
        guard let data = try? JSONEncoder().encode(restaurant) else { return }
        defaults.set(data, forKey: prefKey)
    }

    // MARK: – Private helper
    private func post<T: Decodable>(_ type: T.Type, path: String) async throws -> T {
        var req = URLRequest(url: base.appendingPathComponent(path))
        req.httpMethod = "POST"
        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = "hash=596df9effde6f877717b4e81fdb2ca9f".data(using: .utf8)
        return try await client.send(req)
    }
}
