//
//  HTTPClient.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

protocol HTTPClient: Sendable {
  func send<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {
  
  func send<T: Decodable>(_ request: URLRequest) async throws -> T {
    
    // MARK: 1) Log de saída (console)
        print("➡️ \(request.httpMethod ?? "") \(request.url!.absoluteString)")
        if let body = request.httpBody {
          print("➡️ Body:", String(data: body, encoding: .utf8) ?? "<bin>")
        }
    
    // MARK: 2) Chamada de rede
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // MARK: 3) Log de entrada (console)
    guard let http = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
        print("⬅️ Status:", http.statusCode)
        print("⬅️ Headers:", http.allHeaderFields)
        print("⬅️ Raw JSON:", String(data: data, encoding: .utf8) ?? "<bin>")
    
    // MARK: 4) Crashlytics trace
    logToCrashlytics(request: request, response: http, data: data, error: nil)
    
    // MARK: 5) Validar status-code
    guard (200...299).contains(http.statusCode) else {
      let err = NSError(domain: "HTTPClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
      
      logToCrashlytics(request: request, response: http, data: data, error: err)
      throw err
    }
    
    // MARK: 6) Decodificar
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
            print("❌ Decoding error:", error)
      
      logToCrashlytics(request: request, response: http, data: data, error: error)
      throw error
    }
  }
}

// MARK: – Crashlytics helper
private extension URLSessionHTTPClient {
  
  func logToCrashlytics(request: URLRequest, response: HTTPURLResponse, data: Data?, error: Error?) {
    
    let crashlytics = Crashlytics.crashlytics()
    let endpoint = request.url?.lastPathComponent ?? "unknown"
    let prefix = endpoint.replacingOccurrences(of: " ", with: "_").lowercased()
    
    crashlytics.log("HTTP event \(endpoint)")
    crashlytics.setCustomValue(request.url?.absoluteString ?? "", forKey: "\(prefix)_url")
    crashlytics.setCustomValue(request.httpMethod ?? "", forKey: "\(prefix)_method")
    crashlytics.setCustomValue(response.statusCode, forKey: "\(prefix)_status")
    
    if let error {
      crashlytics.setCustomValue(error.localizedDescription, forKey: "\(prefix)_error")
    }
    
    if let d = data, !d.isEmpty {
      let slice = d.prefix(1024)
      if let snippet = String(data: slice, encoding: .utf8) {
        crashlytics.setCustomValue(snippet, forKey: "\(prefix)_resp_snippet")
      }
    }
  }
}
