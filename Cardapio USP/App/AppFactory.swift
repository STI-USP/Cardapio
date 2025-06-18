//
//  AppFactory.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 18/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit

@MainActor
@objcMembers
final class AppFactory: NSObject {

    // View-model único para a sessão inteira
    private static let restaurantSvc = RestaurantServiceImpl.shared
    private static let homeSvc = HomeServiceImpl(restaurant: restaurantSvc)
    private static let homeVM = HomeViewModel(
      service: homeSvc,
      restaurantService: restaurantSvc
    )

    // Cria o MainViewController já injetando o mesmo HomeViewModel
    static func makeMainViewController() -> MainViewController {
        let vc = MainViewController()
        vc.viewModel = homeVM
        return vc
    }
}
