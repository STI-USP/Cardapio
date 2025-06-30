//
//  Pix.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 23/06/25.
//  Copyright © 2025 USP. All rights reserved.
//


// MARK: - Models

struct Pix: Sendable, Decodable {
  let id: String
  let valor: Decimal
  let copiaCola: String
  let vencimento: Date
  let situacao: String
}

extension Pix {
  /// Constrói o domínio Swift a partir do modelo legado `VMPix`
  init?(_ vm: VMPix?) {
    guard let vm else { return nil }
    
    let valorDecimal = Decimal(string: vm.vlrpix?.stringValue ?? "") ?? 0
    
    self.init(id: vm.idfpix ?? "",
              valor: valorDecimal,
              copiaCola: vm.qrcpix ?? "",
              vencimento: vm.dtagrcpix ?? Date(),
              situacao: vm.sitpagpix ?? "")
  }
  
  /// Versão nomeada — útil para chamadas do tipo `Pix(legacy: vmPix)`
  init?(legacy vm: VMPix?) {
    self.init(vm)   // reaproveita o init já existente
  }

}

extension Pix {
    init?(bridging vm: VMPix?) {
        guard let vm else { return nil }

        // 1. Valor
        let valorDecimal = Decimal(string: vm.vlrpix?.stringValue ?? "") ?? 0

        // 2. Status “humanizado” – se `statusDescricao` vier vazio,
        //    usa o código cru como último fallback.
        let status = (vm.statusDescricao?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                   ? vm.statusDescricao!
                   : (vm.sitpagpix ?? "")

        self.init(id:        vm.idfpix ?? "",
                  valor:     valorDecimal,
                  copiaCola: vm.qrcpix  ?? "",
                  vencimento: vm.dtagrcpix ?? Date(),
                  situacao:  status)
    }
}
