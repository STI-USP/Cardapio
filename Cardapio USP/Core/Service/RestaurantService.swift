//
//  RestaurantService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation
import Combine

// MARK: – Protocolo
protocol RestaurantService: Sendable {
  func fetchCampi() async throws -> [Campus]
  
  // Preferido (persistente)
  func preferredRestaurant() -> Restaurant?
  func setPreferred(_ restaurant: Restaurant)
  
  // Corrente (sessão)
  func currentRestaurant() -> Restaurant?
  func setCurrent(_ restaurant: Restaurant)
  
  // Publisher que emite sempre que `setCurrent` é chamado
  var currentPublisher: AnyPublisher<Restaurant?, Never> { get }
}

// MARK: – Implementação
final class RestaurantServiceImpl: RestaurantService, @unchecked Sendable {
  
  // Dependências
  private let client: any HTTPClient
  private let base = URL(string: "https://uspdigital.usp.br/rucard/servicos/")!
  
  // Persistência simples
  private let defaults = UserDefaults.standard
  private let prefKey = "preferredRestaurant"
  
  // Sessão ― reativa
  @Published private var current: Restaurant?
  var currentPublisher: AnyPublisher<Restaurant?, Never> { $current.eraseToAnyPublisher() }
  
  // MARK: Init
  init(client: any HTTPClient = URLSessionHTTPClient()) {
    self.client = client
    
    // se já existe preferido, começa a sessão com ele
    if current == nil, let pref = preferredRestaurant() {
      current = pref
    }
  }
  
  // MARK: – API pública
  func fetchCampi() async throws -> [Campus] {
    let dto = try await post([CampusDTO].self, path: "restaurants")
    return dto.map { $0.toDomain() }
  }
  
  // Preferido (persistente)
  func preferredRestaurant() -> Restaurant? {
    
    // (A) Novo formato – Data codificado
    if let data = defaults.data(forKey: prefKey),
       let restaurant = try? JSONDecoder().decode(Restaurant.self, from: data) {
      return restaurant
    }
    
    // (B) Formato legado – NSDictionary salvo pelo Obj-C
    if let legacy = defaults.dictionary(forKey: prefKey),
       let restaurant = Restaurant(dict: legacy) {
      
      // migra silenciosamente para o novo formato
      if let data = try? JSONEncoder().encode(restaurant) {
        defaults.set(data, forKey: prefKey)
      }
      return restaurant
    }
    return nil
  }
  
  func setPreferred(_ restaurant: Restaurant) {
    if let data = try? JSONEncoder().encode(restaurant) {
      defaults.set(data, forKey: prefKey)
    }
  }
  
  // Corrente (somente sessão)
  func currentRestaurant() -> Restaurant? {
    current
  }

  func setCurrent(_ restaurant: Restaurant) {
    Task { @MainActor in            
      print("[Service] setCurrent id =", restaurant.id)
      self.current = restaurant
    }
  }
  
  // MARK: – Helper HTTP
  private func post<T: Decodable>(_ type: T.Type, path: String) async throws -> T {
    var req = URLRequest(url: base.appendingPathComponent(path))
    req.httpMethod = "POST"
    req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    req.httpBody = "hash=596df9effde6f877717b4e81fdb2ca9f".data(using: .utf8)
    return try await client.send(req)
  }
}

extension RestaurantServiceImpl {
  // singleton somente para Swift
  static let shared = RestaurantServiceImpl()
}

@MainActor
@objcMembers
final class RestaurantBridge: NSObject {
  
  // Singleton para uso em Obj-C
  static let shared = RestaurantBridge()
  
  // Referência ao serviço real
  private let service = RestaurantServiceImpl.shared
  
  // Recebe NSDictionary vindo do código legado
  @objc(setCurrentRestaurantFrom:)
  func setCurrentRestaurant(_ dict: NSDictionary) {
    print("[Bridge] recebeu dict = \(dict)")
    guard
      let swiftDict = dict as? [String: Any],
      let restaurant = Restaurant(dict: swiftDict)
    else { return }
    
    service.setCurrent(restaurant)
    print("[Bridge] chamou service.setCurrent(\(restaurant.id))")
  }
}
