//
//  HomeCache.swift
//  Cardapio USP
//
//  Created by GitHub Copilot on 14/08/25.
//
//  Cache simples do último HomeState para uso offline.
//

import Foundation

struct CachedHomeState: Codable, Equatable {
  let restaurantName: String
  let balanceText: String
  let dateText: String
  let mealPeriod: String
  let items: [String]
  let timestamp: Date
  
  var toHomeState: HomeState { HomeState(restaurantName: restaurantName, balanceText: balanceText, dateText: dateText, mealPeriod: mealPeriod, items: items) }
  
  static func from(_ state: HomeState) -> CachedHomeState {
    .init(restaurantName: state.restaurantName,
          balanceText: state.balanceText,
          dateText: state.dateText,
          mealPeriod: state.mealPeriod,
          items: state.items,
          timestamp: Date())
  }
}

final class HomeCache: @unchecked Sendable {
  static let shared = HomeCache()
  private init() {}

  // Serial queue garante acesso exclusivo ao arquivo
  private let queue = DispatchQueue(label: "home.cache.queue", qos: .utility)
  private let fileName = "home_state_cache.json"

  private var fileURL: URL? {
    FileManager.default
      .urls(for: .cachesDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent(fileName)
  }

  func save(_ state: HomeState) {
    queue.async { [weak self] in
      guard let self, let url = self.fileURL else { return }
      let cached = CachedHomeState.from(state)
      do {
        let data = try JSONEncoder().encode(cached)
        try data.write(to: url, options: .atomic)
      } catch {
        print("[HomeCache] Save error: \(error)")
      }
    }
  }

  func load() -> HomeState? {
    queue.sync { [weak self] in
      guard let self, let url = self.fileURL, FileManager.default.fileExists(atPath: url.path) else { return nil }
      do {
        let data = try Data(contentsOf: url)
        let cached = try JSONDecoder().decode(CachedHomeState.self, from: data)
        return cached.toHomeState
      } catch {
        print("[HomeCache] Load error: \(error)")
        return nil
      }
    }
  }
}
