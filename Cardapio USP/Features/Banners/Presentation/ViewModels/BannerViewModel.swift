//
//  BannerViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 12/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

final class BannerViewModel {
  private let service: BannerServiceProtocol
  private(set) var banners: [Banner] = []
  var onUpdate: (() -> Void)?
  
  init(service: BannerServiceProtocol = MockBannerService()) {
    self.service = service
  }
  
  func loadBanners() {
    service.fetchBanners { [weak self] banners in
      self?.banners = banners
      self?.onUpdate?()
    }
  }
}
