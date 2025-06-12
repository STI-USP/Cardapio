//
//  USPMenuFacade.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

@objc public final class USPMenuFacade: NSObject {
  
  /// Cardápio de hoje para uso em Objective-C
  /// - Parameters:
  ///   - restaurantId: ID no backend
  ///   - completion: Executado sempre no *MainActor* (thread principal)
  @MainActor                                     // ← chamada parte do Main
  @objc public static func today(
    for restaurantId: String,
    completion: @escaping @Sendable ([String: Any]?, Error?) -> Void
  ) {
    // Captura o serviço fora do MainActor para não travar a UI
    let service = MenuServiceImpl()
    
    Task.detached(priority: .userInitiated) { // executor neutro
      do {
        let menu = try await service.fetchToday(for: restaurantId)
        
        // Volta ao MainActor antes de tocar o completion ObjC
        await MainActor.run {
          completion([
            "items":  menu.items,
            "period": menu.period.rawValue,
            "date":   menu.date
          ], nil)
        }
      } catch {
        await MainActor.run { completion(nil, error) }
      }
    }
  }
}
