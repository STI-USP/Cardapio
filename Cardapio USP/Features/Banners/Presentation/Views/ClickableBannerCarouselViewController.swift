//
//  ClickableBannerCarouselViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 06/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit

struct ClickableBanner {
  let title: String
  let subtitle: String
  let backgroundColor: UIColor
  let textColor: UIColor
  let url: URL
}

final class ClickableBannerCarouselViewController: UIViewController {
  
  // MARK: – Constants
  private let sideInset: CGFloat = 20
  private let itemSpacing: CGFloat = 8
  private let autoScrollInterval: TimeInterval = 6
  
  // MARK: – Data
  private let banners: [ClickableBanner] = [
    .init(title: "Pró-Reitoria de Inclusão e Pertencimento",
          subtitle: "Notícias e informações sobre apoio estudantil, serviços, editais e outras ações da PRIP.",
          backgroundColor: .uspLightBlue,
          textColor: .black,
          url: URL(string: "https://prip.usp.br/?utm_source=appcardapio&utm_medium=carrossel")!),
    
      .init(title: "Sistema USP de Acolhimento (SUA)",
            subtitle: "Orientações para casos de assédio e outras violações de direitos humanos na USP.",
            backgroundColor: .uspDarkBlue,
            textColor: .white,
            url: URL(string: "https://prip.usp.br/institucional/sistema-usp-de-acolhimento-sua/?utm_source=appcardapio&utm_medium=carrossel")!),
    
      .init(title: "Programa ECOS",
            subtitle: "Espaço de acolhimento e orientação em saúde mental para a comunidade USP.",
            backgroundColor: .uspLightYellow,
            textColor: .black,
            url: URL(string: "https://prip.usp.br/areas/saude-mental/programa-ecos/?utm_source=appcardapio&utm_medium=carrossel")!)
  ]
  
  // MARK: – UI
  private var collectionView: UICollectionView!
  private let pageControl = UIPageControl()
  
  // MARK: – Helpers
  private var autoScrollTimer: Timer?
  private var cellWidth: CGFloat {
    collectionView.bounds.width - (sideInset * 2)
  }
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    setupCollectionView()
    setupPageControl()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // startAutoScroll()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    autoScrollTimer?.invalidate()
  }
  
  // MARK: – Setup
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = itemSpacing
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(ClickableBannerCell.self,
                            forCellWithReuseIdentifier: ClickableBannerCell.reuseId)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.decelerationRate = .fast
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.contentInset = .init(top: 0,
                                        left: sideInset,
                                        bottom: 0,
                                        right: sideInset)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupPageControl() {
    pageControl.numberOfPages = banners.count
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = .lightGray
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
  }
  
  // MARK: – Auto-scroll (opcional)
  private func startAutoScroll() {
    autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval,
                                           repeats: true) { [weak self] _ in
      DispatchQueue.main.async { self?.scrollToNext() }
    }
  }
  
  private func scrollToNext() {
    let next = (pageControl.currentPage + 1) % banners.count
    let offsetX = CGFloat(next) * (cellWidth + itemSpacing) - sideInset
    collectionView.setContentOffset(.init(x: offsetX, y: 0), animated: true)
    pageControl.currentPage = next
  }
}

// MARK: – UICollectionViewDataSource & Delegate
extension ClickableBannerCarouselViewController: UICollectionViewDataSource,
                                                 UICollectionViewDelegateFlowLayout,
                                                 UIScrollViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int { banners.count }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClickableBannerCell.reuseId,
                                                  for: indexPath) as! ClickableBannerCell
    cell.configure(with: banners[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: cellWidth, height: collectionView.bounds.height)
  }
  
  // Snap-to-page
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let pageWidth = cellWidth + itemSpacing
    let index = round((targetContentOffset.pointee.x + sideInset) / pageWidth)
    targetContentOffset.pointee.x = index * pageWidth - sideInset
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let rawPage = (scrollView.contentOffset.x + sideInset) / (cellWidth + itemSpacing)
    pageControl.currentPage = Int(round(rawPage))
  }
  
  // 👉🏼 Abertura da URL
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) {
    let banner = banners[indexPath.item]
    UIApplication.shared.open(banner.url, options: [:])
  }
}

// MARK: – Cell
final class ClickableBannerCell: UICollectionViewCell {
  
  static let reuseId = "ClickableBannerCell"
  
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.layer.cornerRadius = 12
    contentView.clipsToBounds = true
    setupLabels()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupLabels() {
    titleLabel.font = .boldSystemFont(ofSize: 18)
    subtitleLabel.font = .systemFont(ofSize: 14)
    subtitleLabel.numberOfLines = 2
    
    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stack.axis = .vertical
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stack)
    
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func configure(with banner: ClickableBanner) {
    contentView.backgroundColor = banner.backgroundColor
    titleLabel.textColor = banner.textColor
    subtitleLabel.textColor = banner.textColor
    titleLabel.text = banner.title
    subtitleLabel.text = banner.subtitle
    // A11y
    contentView.accessibilityLabel = "\(banner.title). \(banner.subtitle)"
  }
}
