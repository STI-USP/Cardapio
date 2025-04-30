//
//  MainViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import Combine

@objcMembers
class MainViewController: UIViewController {
  
  // MARK: – ViewModels
  private let cardapioVM = CardapioViewModel(
    restaurantName: "Restaurante Central",
    restaurantId: "central"
  )
  private let saldoVM   = SaldoViewModel()
  
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Cardápio +"
    view.backgroundColor = .secondarySystemBackground
    setupLayout()
  }
  
  /// Monta toda a hierarquia de views
  private func setupLayout() {
    // Root stack
    let mainStack = UIStackView()
    mainStack.axis = .vertical
    mainStack.spacing = 16
    mainStack.distribution = .fill
    mainStack.isLayoutMarginsRelativeArrangement = true
    mainStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mainStack)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    // 1. Cardápio
    let cardapioView = CardapioSectionView()
    cardapioView.bind(to: cardapioVM)
    mainStack.addArrangedSubview(cardapioView)
    
    // 2. Saldo
    let saldoView = SaldoSectionView()
    saldoView.bind(to: saldoVM)
    saldoView.onAddCreditTapped = { [weak self] in
      let vc = AddCreditsViewController()
      self?.navigationController?.pushViewController(vc, animated: true)
    }
    mainStack.addArrangedSubview(saldoView)
    
    // 3. Carrossel de banners (wrapper para eliminar a margem lateral)
    let bannerVC = BannerCarouselViewController()
    addChild(bannerVC)
    
    let bannerContainer = UIView()
    bannerContainer.addSubview(bannerVC.view)
    bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
    bannerContainer.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      bannerVC.view.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
      bannerVC.view.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor, constant: -16),
      bannerVC.view.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor, constant: 16),
      bannerVC.view.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor)
    ])
    
    bannerVC.didMove(toParent: self)
    mainStack.addArrangedSubview(bannerContainer)
    
    // 4. Botões de ação
    let actionButtonsView = VerticalButtonListSection()
    actionButtonsView.heightAnchor.constraint(equalToConstant: 240).isActive = true
    mainStack.addArrangedSubview(actionButtonsView)
    
    // Hugging & Compression — para o stack distribuir melhor o espaço
    cardapioView.setContentHuggingPriority(.defaultLow, for: .vertical)
    saldoView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    bannerContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
    actionButtonsView.setContentHuggingPriority(.required, for: .vertical)
  }
}
