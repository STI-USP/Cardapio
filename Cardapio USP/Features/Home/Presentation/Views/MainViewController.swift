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
final class MainViewController: UIViewController {
  
  // MARK: – ViewModel
  private let homeVM = HomeViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: – Sub-views
  private let cardapioView  = CardapioSectionView()
  private let saldoView     = SaldoSectionView()
  private let bannerVC      = BannerCarouselViewController()
  private let actionButtons = VerticalButtonListSection()
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Cardápio +"
    view.backgroundColor = .secondarySystemBackground
    setupLayout()
    bind()
  }
  
  // MARK: – Layout igual ao seu código
  private func setupLayout() {
    let mainStack = UIStackView()
    mainStack.axis = .vertical
    mainStack.spacing = 12
    mainStack.isLayoutMarginsRelativeArrangement = true
    mainStack.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mainStack)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    // 1. Cardápio
    mainStack.addArrangedSubview(cardapioView)
    
    // 2. Saldo
    saldoView.onAddCreditTapped = { [weak self] in
      let vc = AddCreditsViewController()
      self?.navigationController?.pushViewController(vc, animated: true)
    }
    mainStack.addArrangedSubview(saldoView)
    
    // 3. Banners
    addChild(bannerVC)
    bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
    let bannerContainer = UIView()
    bannerContainer.addSubview(bannerVC.view)
    NSLayoutConstraint.activate([
      bannerVC.view.topAnchor .constraint(equalTo: bannerContainer.topAnchor),
      bannerVC.view.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor, constant: -16),
      bannerVC.view.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor, constant: 16),
      bannerVC.view.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor)
    ])
    bannerVC.didMove(toParent: self)
    mainStack.addArrangedSubview(bannerContainer)
    
    // 4. Botões de ação
    actionButtons.heightAnchor.constraint(equalToConstant: 240).isActive = true
    mainStack.addArrangedSubview(actionButtons)
    
    // Hugging priorities
    cardapioView.setContentHuggingPriority(.defaultLow, for: .vertical)
    saldoView   .setContentHuggingPriority(.defaultHigh, for: .vertical)
    bannerContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
    actionButtons .setContentHuggingPriority(.required,  for: .vertical)
    
    // O cardápio é o primeiro a encolher; banner e botões nunca se sobrepõem
    cardapioView   .setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    saldoView      .setContentCompressionResistancePriority(.required,   for: .vertical)
    bannerContainer.setContentCompressionResistancePriority(.required,   for: .vertical)
    actionButtons  .setContentCompressionResistancePriority(.required,   for: .vertical)
  }
  
  // MARK: – Bind ViewModel → UI
  private func bind() {
    homeVM.$state
      .compactMap { $0 }
      .sink { [weak self] state in
        guard let self else { return }
        // Cardápio
        cardapioView.update(
          restaurant: state.restaurantName,
          dateText:   state.dateText,
          periodText: state.mealPeriod,
          items:      state.items
        )
        // Saldo
        saldoView.update(balanceText: state.balanceText)
      }
      .store(in: &cancellables)
    
    homeVM.$error
      .compactMap { $0 }
      .sink { [weak self] msg in
        self?.showAlert(msg)
      }
      .store(in: &cancellables)
  }
  
  private func showAlert(_ msg: String) {
    let ac = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
}
