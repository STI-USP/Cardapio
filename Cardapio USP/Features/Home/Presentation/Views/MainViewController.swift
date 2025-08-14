//
//  MainViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 30/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import Combine
import Network
#if canImport(SVProgressHUD)
import SVProgressHUD
#endif

@MainActor
final class NetworkMonitor: @unchecked Sendable {
  static let shared = NetworkMonitor()
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "net.monitor")
  private(set) var isConnected: Bool = true

  private init() {
    monitor.pathUpdateHandler = { [weak self] path in
      let ok = (path.status == .satisfied)
      // hop de volta para o MainActor antes de tocar no estado
      Task { @MainActor in
        self?.isConnected = ok
      }
    }
    monitor.start(queue: queue)
  }
}

final class MainViewController: UIViewController, UIScrollViewDelegate {
  
  // MARK: – ViewModel
  var viewModel: HomeViewModel!
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: – Sub‑views
  private let scrollView = UIScrollView()
  private let refreshCtrl = UIRefreshControl()
  private let mainStack = UIStackView()
  
  private let cardapioView = CardapioSectionView()
  private let saldoView = SaldoSectionView()
  private let bannerVC = BannerCarouselViewController()
  private let actionButtons = VerticalButtonGridSection()
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    precondition(viewModel != nil, "MainViewController deve receber viewModel antes de usar")
    
    title = "Cardápio +"
    view.backgroundColor = UIColor(named: "MainBackground")
    
    setupScrollView()
    setupStack()
    embedSections()
    applyGoldenRatioHeights()
    bind()
    observeAppLifecycle()
  }
  
  // MARK: - UIScrollViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Impede rolagem para baixo ou para os lados
    if scrollView.contentOffset.y > 0 { scrollView.contentOffset.y = 0 }
    if scrollView.contentOffset.x != 0 { scrollView.contentOffset.x = 0 }
  }
  
}

// MARK: – Setup
private extension MainViewController {
  
  func setupScrollView() {
    scrollView.delegate = self
    
    scrollView.alwaysBounceVertical = true
    scrollView.alwaysBounceHorizontal = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isDirectionalLockEnabled = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    refreshCtrl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
    scrollView.refreshControl = refreshCtrl
  }
  
  /// Stack vertical dentro do scrollView
  func setupStack() {
    mainStack.axis = .vertical
    mainStack.spacing = 12
    mainStack.alignment = .fill
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(mainStack)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      mainStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      mainStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
      mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      mainStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
      mainStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -20)
    ])
  }
  
  func embedSections() {
    // Cardápio
    mainStack.addArrangedSubview(cardapioView)
    
    // Saldo
    saldoView.onAddCreditTapped = { [weak self] in
      self?.navigationController?.pushViewController(AddCreditsViewController(), animated: true)
    }
    mainStack.addArrangedSubview(saldoView)
    
    // Banners
    addChild(bannerVC)
    bannerVC.view.translatesAutoresizingMaskIntoConstraints = false
    let bannerContainer = UIView()
    bannerContainer.addSubview(bannerVC.view)
    NSLayoutConstraint.activate([
      bannerVC.view.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
      bannerVC.view.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor, constant: -16),
      bannerVC.view.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor, constant: 16),
      bannerVC.view.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor)
    ])
    bannerVC.didMove(toParent: self)
    mainStack.addArrangedSubview(bannerContainer)
    
    // Botões
    if UIScreen.main.bounds.height <= 667 { // iPhone SE 3rd e 8
      actionButtons.heightAnchor.constraint(equalToConstant: 200).isActive = true
    } else {
      actionButtons.heightAnchor.constraint(equalToConstant: 240).isActive = true
    }
    mainStack.addArrangedSubview(actionButtons)
  }
  
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
}

// MARK: – Pull‑to‑refresh
private extension MainViewController {
  @objc func refreshPulled() {
    runIfOnline { [weak self] in
      guard let self else { return }
      await self.viewModel.load()
      self.refreshCtrl.endRefreshing()
    }
  }
}

// MARK: – Binding ViewModel → UI
private extension MainViewController {
  func bind() {
    viewModel.$state.compactMap { $0 }.sink { [weak self] state in
      guard let self else { return }
      cardapioView.update(restaurant: state.restaurantName,
                          dateText: state.dateText,
                          periodText: state.mealPeriod,
                          items: state.items)
      saldoView.update(balanceText: state.balanceText)
    }.store(in: &cancellables)
    
    viewModel.$isLoading.sink { [weak self] loading in
      if loading { self?.cardapioView.showLoading() }
    }.store(in: &cancellables)
    
    viewModel.$error.compactMap { $0 }.sink { [weak self] msg in
      self?.cardapioView.showError("Erro ao carregar cardápio")
      self?.showAlert(msg)
    }.store(in: &cancellables)
  }
}

// MARK: – App‑lifecycle refresh
private extension MainViewController {
  func observeAppLifecycle() {
    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .sink { [weak self] _ in
        self?.runIfOnline { [weak self] in
          await self?.viewModel.load()
        }
      }
      .store(in: &cancellables)
  }
}

// MARK: – Alert helper
private extension MainViewController {
  func showAlert(_ msg: String) {
    let ac = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
}

// MARK: – Connectivity guard & HUD
private extension MainViewController {
  func runIfOnline(_ action: @escaping () async -> Void) {
    if NetworkMonitor.shared.isConnected {
      Task { await action() }
    } else {
      showNoNetworkHUD()
      refreshCtrl.endRefreshing()
    }
  }

  func showNoNetworkHUD() {
    #if canImport(SVProgressHUD)
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.showInfo(withStatus: "Sem conexão. Verifique sua rede.")
    SVProgressHUD.dismiss(withDelay: 1.5)
    #else
    let ac = UIAlertController(title: "Sem conexão",
                               message: "Verifique sua rede.",
                               preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    #endif
  }
}
