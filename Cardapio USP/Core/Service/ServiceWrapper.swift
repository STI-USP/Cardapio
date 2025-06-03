////
////  ServiceWrapper.swift
////  Cardapio USP
////
////  Created by Vagner Machado on 30/04/25.
////  Copyright © 2025 USP. All rights reserved.
////
//
//protocol MenuService {
//  func fetchToday(for restaurantId: String, completion: @escaping (Result<MenuOfDay, Error>) -> Void)
//}
//
//struct MenuServiceImpl: MenuService {
//  func fetchToday(for restaurantId: String, completion: @escaping (Result<MenuOfDay, Error>) -> Void) {
//    // TODO: faça chamada REST ou Firebase
//    completion(.success(
//      .init(date: .init(), meal: .dinner,
//            items: ["Arroz", "Feijão", "Bife acebolado", "Salada", "Maçã", "Suco de uva"])
//    ))
//  }
//}
//
//// CreditService
//protocol CreditService {
//  func fetchBalance(completion: @escaping (Result<Decimal, Error>) -> Void)
//}
//
//struct CreditServiceImpl: CreditService {
//  private let auth: AuthService
//  init(auth: AuthService = OAuthAuthService()) { self.auth = auth }
//  
//  func fetchBalance(completion: @escaping (Result<Decimal, Error>) -> Void) {
//    guard auth.isLoggedIn, let token = auth.token else {
//      completion(.failure(NSError(domain: "notLogged", code: 0)))
//      return
//    }
//    // chamada HTTP POST kPathConsultarSaldo com token …
//    completion(.success(20.00))
//  }
//}
//
//// AuthService
//protocol AuthService {
//  var isLoggedIn: Bool { get }
//  var token: String? { get }
//}
//
//struct OAuthAuthService: AuthService {
//  var isLoggedIn: Bool { OAuthUSP.sharedInstance().isLoggedIn() }
//  var token: String?  { OAuthUSP.sharedInstance().userData["wsuserid"] as? String }
//}
