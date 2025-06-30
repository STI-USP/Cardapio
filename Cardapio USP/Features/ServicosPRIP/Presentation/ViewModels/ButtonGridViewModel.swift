//
//  VerticalButtonGridViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 13/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation
import Combine
import UIKit

struct GridItem {
    let title: String
    let image: UIImage?
    let url: String
}

final class ButtonGridViewModel: ObservableObject {
    @Published var items: [GridItem] = []

    func loadItems() {
        items = [
          GridItem(title: "Avisos", image: UIImage(systemName: "megaphone"), url: "https://prip.usp.br/categoria/comunicados/?utm_source=appcardapio&utm_medium=secao1"),
          GridItem(title: "PAPFE", image: UIImage(systemName: "graduationcap"), url: "https://prip.usp.br/apoio-estudantil/papfe/?utm_source=appcardapio&utm_medium=secao1"),
          GridItem(title: "Sistema USP de Acolhimento (SUA)", image: UIImage(systemName: "person.2.crop.square.stack"), url: "https://prip.usp.br/institucional/sistema-usp-de-acolhimento-sua/?utm_source=appcardapio&utm_medium=secao1"),
          GridItem(title: "Ajuda em Saúde Mental", image: UIImage(systemName: "brain.head.profile"), url: "https://prip.usp.br/areas/saude-mental/precisa-de-ajuda-em-saude-mental/?utm_source=appcardapio&utm_medium=secao1"),
          GridItem(title: "Restaurante Universitário", image: UIImage(systemName: "fork.knife"), url: "https://prip.usp.br/servicos/alimentacao/?utm_source=appcardapio&utm_medium=secao2"),
          GridItem(title: "Moradia Estudantil", image: UIImage(systemName: "house"), url: "https://prip.usp.br/apoio-estudantil/moradia-estudantil/?utm_source=appcardapio&utm_medium=secao2"),
          GridItem(title: "Serviço Social", image: UIImage(systemName: "figure.2.and.child.holdinghands"), url: "https://prip.usp.br/institucional/servico-social/?utm_source=appcardapio&utm_medium=secao2"),
          GridItem(title: "Fale Conosco", image: UIImage(systemName: "message"), url: "https://prip.usp.br/fale-conosco/?utm_source=appcardapio&utm_medium=secao2")
        ]
    }
}
