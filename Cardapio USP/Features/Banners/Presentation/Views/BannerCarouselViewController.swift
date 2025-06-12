//
//  BannerCarouselViewController.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
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
  
  private func bindViewModel() {
    viewModel.onUpdate = { [weak self] in
      DispatchQueue.main.async {
        self?.pageControl.numberOfPages = self?.viewModel.banners.count ?? 0
        self?.collectionView.reloadData()
      }
    }
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
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                 targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
    let banner = viewModel.banners[indexPath.item]
    UIApplication.shared.open(banner.url, options: [:])
  }
}
