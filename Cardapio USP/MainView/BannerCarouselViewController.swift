//
//  BannerCarouselViewController.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

struct Banner {
  let title: String
  let subtitle: String
  let backgroundColor: UIColor
  let textColor: UIColor
}

final class BannerCarouselViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // MARK: – Constants
  private let sideInset: CGFloat = 20 // tamanho do “peek”
  private let itemSpacing: CGFloat = 8 // espaço entre cards
  private let autoScrollInterval: TimeInterval = 5 // segundos
  
  // MARK: – Data
  private let banners: [Banner] = [
    Banner(title: "Favoritos disponíveis!",
           subtitle: "Agora você pode favoritar seus bandejões.",
           backgroundColor: .uspLightBlue,
           textColor: .black),
    
    Banner(title: "Destaque vegetariano",
           subtitle: "Pratos vegetarianos agora aparecem primeiro no cardápio!",
           backgroundColor: .uspDarkBlue,
           textColor: .white),
    
    Banner(title: "Recarga fácil",
           subtitle: "Recarregue seu RUCard direto no app.",
           backgroundColor: .uspLightYellow,
           textColor: .black)
  ]
  
  // MARK: – UI
  private var collectionView: UICollectionView!
  private var pageControl = UIPageControl()
  
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
    //        startAutoScroll()
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
    collectionView.register(BannerCell.self, forCellWithReuseIdentifier: "BannerCell")
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.decelerationRate = .fast
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.contentInset = UIEdgeInsets(top: 0,
                                               left: sideInset,
                                               bottom: 0,
                                               right: sideInset)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 140)
    ])
  }
  
  private func setupPageControl() {
    pageControl.numberOfPages = banners.count
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = .lightGray
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    //        view.addSubview(pageControl)
    //        NSLayoutConstraint.activate([
    //            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
    //            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    //        ])
  }
  
  // MARK: – Auto‑scroll
  private func startAutoScroll() {
    autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { [weak self] _ in
      // Garantindo que o método seja executado na main thread
      DispatchQueue.main.async {
        self?.scrollToNextBanner()
      }
    }
  }
  
  private func scrollToNextBanner() {
    let nextIndex = (pageControl.currentPage + 1) % banners.count
    let offsetX = CGFloat(nextIndex) * (cellWidth + itemSpacing) - sideInset
    collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    pageControl.currentPage = nextIndex
  }
  
  // MARK: – UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    banners.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell",
                                                  for: indexPath) as! BannerCell
    cell.configure(with: banners[indexPath.item])
    return cell
  }
  
  // MARK: – UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: cellWidth, height: collectionView.bounds.height)
  }
  
  // MARK: – UIScrollViewDelegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // Calcula a página baseada na largura real do card + espaçamento
    let rawPage = (scrollView.contentOffset.x + sideInset) / (cellWidth + itemSpacing)
    pageControl.currentPage = Int(round(rawPage))
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let pageWidth = cellWidth + itemSpacing
    let proposedX = targetContentOffset.pointee.x
    let index = round((proposedX + sideInset) / pageWidth)
    let snapX = index * pageWidth - sideInset
    
    targetContentOffset.pointee = CGPoint(x: snapX, y: 0)
  }
  
}

// MARK: – BannerCell
final class BannerCell: UICollectionViewCell {
  
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
  
  func configure(with banner: Banner) {
    contentView.backgroundColor = banner.backgroundColor
    titleLabel.textColor = banner.textColor
    subtitleLabel.textColor = banner.textColor
    titleLabel.text = banner.title
    subtitleLabel.text = banner.subtitle
    titleLabel.accessibilityLabel = banner.title
    subtitleLabel.accessibilityLabel = banner.subtitle
  }
}
