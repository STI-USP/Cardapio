//
//  ServiceWrapper.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

protocol MenuService {
  func fetchToday(for restaurantId: String, completion: @escaping (Result<MenuOfDay, Error>) -> Void)
}

struct MenuServiceImpl: MenuService {
  func fetchToday(for restaurantId: String, completion: @escaping (Result<MenuOfDay, Error>) -> Void) {
    // TODO: faça chamada REST ou Firebase
    completion(.success(
      .init(date: .init(), meal: .dinner,
            items: ["Arroz", "Feijão", "Bife acebolado", "Salada", "Maçã", "Suco de uva"])
    ))
  }
}

// CreditService.swift
protocol CreditService {
  func fetchBalance(completion: @escaping (Result<Decimal, Error>) -> Void)
}

struct CreditServiceImpl: CreditService {
  func fetchBalance(completion: @escaping (Result<Decimal, Error>) -> Void) {
    // TODO: chamada ao seu backend
    completion(.success(20.00))
  }
}
