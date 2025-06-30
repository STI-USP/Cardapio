//
//  BannerService.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 12/06/25.
//  Copyright © 2025 USP. All rights reserved.
//


protocol BannerServiceProtocol {
  func fetchBanners(completion: @escaping ([Banner]) -> Void)
}

final class MockBannerService: BannerServiceProtocol {
  func fetchBanners(completion: @escaping ([Banner]) -> Void) {
    let mockData = [
      Banner(
        title: "Pró-Reitoria de Inclusão e Pertencimento",
        subtitle: "Notícias e informações sobre apoio estudantil, serviços, editais e outras ações da PRIP.",
        backgroundColor: .uspLightBlue,
        textColor: .black,
        url: URL(string: "https://prip.usp.br/?utm_source=appcardapio&utm_medium=carrossel")!
      ),
      Banner(
        title: "Sistema USP de Acolhimento (SUA)",
        subtitle: "Orientações para casos de assédio e outras violações de direitos humanos na USP.",
        backgroundColor: .uspDarkBlue,
        textColor: .white,
        url: URL(string: "https://prip.usp.br/institucional/sistema-usp-de-acolhimento-sua/?utm_source=appcardapio&utm_medium=carrossel")!
      ),
      Banner(
        title: "Programa ECOS",
        subtitle: "Espaço de acolhimento e orientação em saúde mental para a comunidade USP.",
        backgroundColor: .uspLightYellow,
        textColor: .black,
        url: URL(string: "https://prip.usp.br/areas/saude-mental/programa-ecos/?utm_source=appcardapio&utm_medium=carrossel")!
      )
    ]
    completion(mockData)
  }
}
