//
//  MenuService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

// MARK: - Erros customizados
enum MenuServiceError: LocalizedError {
  case noMenuAvailable     // Sem cardápio para data/período atual (ex: data antiga)
  case networkError(Error) // Problemas de conexão
  case parsingError(Error) // Erro ao decodificar resposta
  case unknown(Error)      // Outros erros
  
  var errorDescription: String? {
    switch self {
    case .noMenuAvailable:
      return "O cardápio solicitado não está disponível no momento. Por favor, verifique mais tarde."
    case .networkError:
      return "Não foi possível conectar ao servidor. Verifique sua conexão com a internet e tente novamente."
    case .parsingError:
      return "Ocorreu um erro ao processar os dados do cardápio. Por favor, tente novamente mais tarde."
    case .unknown(let error):
      return "Erro inesperado: \(error.localizedDescription)"
    }
  }
}

protocol MenuService : Sendable {
  // Cardápio completo da semana
  func fetchWeek(for restaurantId: String) async throws -> [Menu]
  // Apenas hoje
  func fetchToday(for restaurantId: String) async throws -> Menu
}

final class MenuServiceImpl: MenuService {
  private let client: HTTPClient
  private let base = URL(string: "https://uspdigital.usp.br/rucard/servicos/")!
  
  init(client: HTTPClient = URLSessionHTTPClient()) {
    self.client = client
  }
  
  func fetchWeek(for restaurantId: String) async throws -> [Menu] {
    do {
      let dto = try await post(MenuWeekDTO.self, path: "menu/\(restaurantId)")
      return dto.toDomain()
    } catch let error as DecodingError {
      throw MenuServiceError.parsingError(error)
    } catch let error as URLError {
      throw MenuServiceError.networkError(error)
    } catch {
      throw MenuServiceError.unknown(error)
    }
  }
  
  func fetchToday(for restaurantId: String) async throws -> Menu {
    let all = try await fetchWeek(for: restaurantId)

    let calendar = Calendar(identifier: .gregorian)
    let saoPauloTimeZone = TimeZone(identifier: "America/Sao_Paulo")!
    var calendarSP = calendar
    calendarSP.timeZone = saoPauloTimeZone

    let now = Date()
    let targetPeriod: MealPeriod = {
      switch MealPeriodCalculator.now(in: calendarSP, reference: now) {
      case .lunch:  return .lunch
      case .dinner: return .dinner
      }
    }()

    guard let menu = all.first(where: {
      calendarSP.isDate($0.date, inSameDayAs: now) && $0.period == targetPeriod
    }) else {
      // Lança erro customizado quando não há cardápio disponível (ex: data antiga)
      print("⚠️ [MenuService] Cardápio não encontrado para hoje/período atual")
      print("⚠️ [MenuService] Menus disponíveis: \(all.map { "[\($0.date)] \($0.period)" }.joined(separator: ", "))")
      throw MenuServiceError.noMenuAvailable
    }

    return menu
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
