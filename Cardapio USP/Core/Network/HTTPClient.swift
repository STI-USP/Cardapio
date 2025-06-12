//
//  HTTPClient.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

protocol HTTPClient : Sendable {
  func send<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {
  func send<T: Decodable>(_ request: URLRequest) async throws -> T {
    
    // 1) Requisição
    print("➡️ \(request.httpMethod ?? "") \(request.url!.absoluteString)")
    if let body = request.httpBody {
      print("➡️ Body:", String(data: body, encoding: .utf8) ?? "<bin>")
    }
    
    // 2) Resposta
    let (data, response) = try await URLSession.shared.data(for: request)
    if let http = response as? HTTPURLResponse {
      print("⬅️ Status:", http.statusCode)
      print("⬅️ Headers:", http.allHeaderFields)
    }
    print("⬅️ Raw JSON:", String(data: data, encoding: .utf8) ?? "<bin>")
    
    // 3) Decodificar — se der erro você já tem o JSON impresso
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      print("❌ Decoding error:", error)
      throw error
    }
  }
}
