//
//  MenuService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

protocol MenuService : Sendable {
  /// Cardápio completo da semana
  func fetchWeek(for restaurantId: String) async throws -> [Menu]
  /// Apenas hoje
  func fetchToday(for restaurantId: String) async throws -> Menu
}

final class MenuServiceImpl: MenuService {
  private let client: HTTPClient
  private let base = URL(string: "https://uspdigital.usp.br/rucard/servicos/")!
  
  init(client: HTTPClient = URLSessionHTTPClient()) {
    self.client = client
  }
  
  func fetchWeek(for restaurantId: String) async throws -> [Menu] {
    let dto = try await post(MenuWeekDTO.self, path: "menu/\(restaurantId)")
    return dto.toDomain()
  }
  
  func fetchToday(for restaurantId: String) async throws -> Menu {
    let all = try await fetchWeek(for: restaurantId)
    guard let today = all.first(where: { Calendar.current.isDateInToday($0.date) }) else {
      throw NSError(domain: "MenuService", code: 404, userInfo: [NSLocalizedDescriptionKey:"Sem cardápio para hoje"])
    }
    return today
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
