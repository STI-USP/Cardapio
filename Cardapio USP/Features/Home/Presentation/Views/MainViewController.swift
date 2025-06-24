//
//  MainViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
  
  // MARK: – ViewModel
  var viewModel: HomeViewModel!
  
  private var cancellables = Set<AnyCancellable>()
  private var lastRestaurantID: String?
  
  // MARK: – Sub-views
  private let cardapioView = CardapioSectionView()
  private let saldoView = SaldoSectionView()
  private let bannerVC = BannerCarouselViewController()
  private let actionButtons = VerticalButtonGridSection()
  // private let actionButtons = VerticalButtonListSection()
  private let mainStack = UIStackView()
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    precondition(viewModel != nil, "MainViewController deve receber viewModel antes de usar")
    
    title = "Cardápio +"
    view.backgroundColor = UIColor(named: "MainBackground")

    setupStack()
    embedSections()
    applyGoldenRatioHeights()
    bind()
    observeAppLifecycle()
  }
  
  // MARK: – Bind ViewModel → UI
  private func bind() {
    // Estado de sucesso
    viewModel.$state
      .compactMap { $0 }
      .sink { [weak self] state in
        guard let self else { return }
        cardapioView.update(
          restaurant: state.restaurantName,
          dateText: state.dateText,
          periodText: state.mealPeriod,
          items: state.items
        )
        saldoView.update(balanceText: state.balanceText)
      }
      .store(in: &cancellables)
    
    // Estado de loading
    viewModel.$isLoading
      .sink { [weak self] loading in
        guard let self else { return }
        if loading {
          cardapioView.showLoading()
          // saldoView.showLoading()
        }
      }
      .store(in: &cancellables)
    
    // Estado de erro
    viewModel.$error
      .compactMap { $0 }
      .sink { [weak self] msg in
        guard let self else { return }
        cardapioView.showError("Erro ao carregar cardápio")
        // saldoView.showError("Erro ao carregar saldo")
        showAlert(msg)
      }
      .store(in: &cancellables)
  }

  // MARK: - Refresh ao voltar p/ foreground
  private func observeAppLifecycle() {
    NotificationCenter.default
      .publisher(for: UIApplication.willEnterForegroundNotification)
      .sink { [weak self] _ in
        guard let self else { return }
        Task { await self.viewModel.load() }
      }
      .store(in: &cancellables)
  }
  
  private func showAlert(_ msg: String) {
    let ac = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
}

// MARK: – Setup helpers
private extension MainViewController {
  
  /// Stack vertical sem espaçamento — cada “pedaço” recebe altura proporcional
  func setupStack() {
    mainStack.axis = .vertical
    mainStack.spacing = 12
    mainStack.alignment = .fill
    mainStack.distribution = .fill // as alturas virão por constraints
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mainStack)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
    ])
  }
  
  /// Adiciona cada seção como child-view-controller (ou view simples)
  func embedSections() {
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
  }
  
  /// Calcula pesos  e cria heightAnchors relativos
  func applyGoldenRatioHeights() {
    
    let weights: [CGFloat] = [
      1.5,  // Cardápio
      0.7,  // Banners
      0.7,  // Botões
      0.3   // Saldo
    ]
    let total = weights.reduce(0, +)
    
    let views: [UIView] = [
      cardapioView,
      bannerVC.view,
      actionButtons,
      saldoView
    ]
    
    for (view, weight) in zip(views, weights) {
      let c = view.heightAnchor.constraint(
        equalTo: mainStack.heightAnchor,
        multiplier: weight / total
      )
      c.priority = .defaultHigh
      c.isActive = true
    }
  }
  
  /// Pequeno helper p/ embed clássico de child-VC
  func add(_ child: UIViewController) {
    addChild(child)
    mainStack.addArrangedSubview(child.view)
    child.didMove(toParent: self)
  }
}
