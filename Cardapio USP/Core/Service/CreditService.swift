//
//  CreditService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

enum CreditServiceError: LocalizedError {
    case unauthorized
    case server(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
          return "Você precisa estar logado para consultar o saldo."
        case .server(let message):
          return message
        }
    }
}

// MARK: – Contrato
protocol CreditService : Sendable {
  func fetchBalance() async throws -> Double
}

struct CreditServiceImpl: CreditService {
  func fetchBalance() async throws -> Double {
    try await Task.sleep(nanoseconds: 200_000_000)
    return 12.34
  }
}

/// Adaptador que escuta a notificação Obj-C e resolve via async/await
struct CreditServiceLegacyAdapter: CreditService, @unchecked Sendable {
  
  private let dataAccess = DataAccess.sharedInstance()
  private let dataModel = DataModel.getInstance()
  private let notifName = Notification.Name("DidReceiveCredits")
  
  func fetchBalance() async throws -> Double {
    
    // 1. Garante que há token
    guard (OAuthUSP.sharedInstance().userData?["wsuserid"] as? String) != nil
    else { throw CreditServiceError.unauthorized }
    
    // 2. Fire-and-forget no serviço legado
    dataAccess?.consultarSaldo()
    
    // 3. Converte a notificação em async/await
    return try await withCheckedThrowingContinuation { cont in
      var obs: NSObjectProtocol?
      var finished = false
      
      let finish: (Result<Double,Error>) -> Void = { result in
        guard !finished else { return }
        finished = true
        if let obs { NotificationCenter.default.removeObserver(obs) }
        cont.resume(with: result)
      }
      
      obs = NotificationCenter.default.addObserver(
        forName: notifName,
        object: nil,
        queue: .main
      ) { _ in
        if let txt = self.dataModel?.ruCardCredit?
          .replacingOccurrences(of: ",", with: "."),
           let dec  = Decimal(string: txt) {
          finish(.success((dec as NSDecimalNumber).doubleValue))
        } else {
          finish(.failure(CreditServiceError
            .server("Saldo indisponível")))
        }
      }
      
      // 4. Timeout (30 s) — só se ainda não concluiu
      Task {
        try await Task.sleep(for: .seconds(30))
        finish(.failure(CreditServiceError
          .server("Tempo esgotado")))
      }
    }
  }
}
