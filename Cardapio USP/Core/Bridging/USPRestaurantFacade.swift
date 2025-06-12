//
//  USPRestaurantFacade.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

@objc public final class USPRestaurantFacade: NSObject {
  
  /// Lista de campi + restaurantes (callback no MainActor)
  @objc public static func fetchCampi(
    _ completion: @escaping @Sendable (NSArray?, NSError?) -> Void
  ) {
    Task.detached {
      do {
        let campi = try await RestaurantServiceImpl().fetchCampi()
        let nsArr = campi.map { try! JSONEncoder().encode($0) } as NSArray
        await MainActor.run { completion(nsArr, nil) }
      } catch {
        await MainActor.run { completion(nil, error as NSError) }
      }
    }
  }
  
  /// Marca favorito
  @objc public static func setPreferredRestaurant(_ data: Data) {
    if let rest = try? JSONDecoder().decode(Restaurant.self, from: data) {
      RestaurantServiceImpl().setPreferred(rest)
    }
  }
}
