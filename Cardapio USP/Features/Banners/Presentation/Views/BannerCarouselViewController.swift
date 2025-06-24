//
//  BannerCarouselViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 15/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit

final class BannerCarouselViewController: UIViewController {
  private let viewModel = BannerViewModel()
  private var collectionView: UICollectionView!
  private let pageControl = UIPageControl()
  private let sideInset: CGFloat = 20
  private let itemSpacing: CGFloat = 8
  private let autoScrollInterval: TimeInterval = 6
  private var autoScrollTimer: Timer?
  private var cellWidth: CGFloat { collectionView.bounds.width - (sideInset * 2) }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    setupCollectionView()
    setupPageControl()
    bindViewModel()
    viewModel.loadBanners()
  }
  

  override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     scrollToRandomCard(animated: true)
   }

//  override func viewDidAppear(_ animated: Bool) {
//     super.viewDidAppear(animated)
//     scrollToRandomCard(animated: true)
//   }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    DispatchQueue.main.async {
      self.collectionView.collectionViewLayout.invalidateLayout()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    autoScrollTimer?.invalidate()
  }
  
  // MARK: - ViewModel binding
  private func bindViewModel() {
    viewModel.onUpdate = { [weak self] in
      guard let self else { return }
      DispatchQueue.main.async {
        self.pageControl.numberOfPages = self.viewModel.banners.count
        self.collectionView.reloadData()
        self.scrollToRandomCard(animated: false)
      }
    }
  }
  
  // MARK: - Random scroll helper
  private func scrollToRandomCard(animated: Bool) {
    guard viewModel.banners.count > 0 else { return }
    
    let randomIndex = Int.random(in: 0 ..< viewModel.banners.count)
    let indexPath   = IndexPath(item: randomIndex, section: 0)
    
    // Garante layout pronto para evitar “attempt to scroll to invalid index path”
    collectionView.layoutIfNeeded()
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    pageControl.currentPage = randomIndex
  }
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = itemSpacing
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseId)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.decelerationRate = .fast
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.contentInset = .init(top: 0, left: sideInset, bottom: 0, right: sideInset)
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
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = .lightGray
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
  }
}

extension BannerCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  
  // Snap-to-page
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let pageWidth = cellWidth + itemSpacing
    let index = round((targetContentOffset.pointee.x + sideInset) / pageWidth)
    targetContentOffset.pointee.x = index * pageWidth - sideInset
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.banners.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.reuseId, for: indexPath) as! BannerCell
    cell.configure(with: viewModel.banners[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: cellWidth, height: collectionView.bounds.height)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let rawPage = (scrollView.contentOffset.x + sideInset) / (cellWidth + itemSpacing)
    pageControl.currentPage = Int(round(rawPage))
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? BannerCell else { return }
    
    // Animação de toque visual
    UIView.animate(withDuration: 0.1, animations: {
      cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    },
                   completion: { _ in
      UIView.animate(withDuration: 0.1) {
        cell.transform = .identity
      }
      
      // Executa o push após a animação
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let banner = self.viewModel.banners[indexPath.item]
        let webVC = WebViewViewController()
        webVC.urlString = banner.url.absoluteString
        webVC.title = "PRIP"
        self.navigationController?.pushViewController(webVC, animated: true)
      }
    })
  }
}
