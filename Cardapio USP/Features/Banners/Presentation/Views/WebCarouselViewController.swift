//
//  WebCarouselViewController.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 06/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import WebKit

struct WebPage {
  let title: String
  let url: URL
}

final class WebCarouselViewController: UIViewController {
  
  // MARK: – Constants
  private let sideInset: CGFloat = 20
  private let itemSpacing: CGFloat = 8
  private let autoScrollInterval: TimeInterval = 10   // segundos
  
  // MARK: – Data
  private let pages: [WebPage] = [
    .init(title: "PRIP",
          url: URL(string: "https://prip.usp.br/institucional/sistema-usp-de-acolhimento-sua/")!),
    .init(title: "Universidade de São Paulo",
          url: URL(string: "https://www.usp.br")!),
    .init(title: "Jornal da USP",
          url: URL(string: "https://jornal.usp.br")!)
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
    startAutoScroll()
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
    collectionView.register(WebViewCell.self,
                            forCellWithReuseIdentifier: WebViewCell.reuseId)
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
    pageControl.numberOfPages = pages.count
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = .lightGray
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    // view.addSubview(pageControl)
    // NSLayoutConstraint.activate([
    //     pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
    //     pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    // ])
  }
  
  // MARK: – Auto-scroll
  private func startAutoScroll() {
    autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval,
                                           repeats: true) { [weak self] _ in
      DispatchQueue.main.async {
        self?.scrollToNextPage()
      }
    }
  }
  
  private func scrollToNextPage() {
    let next = (pageControl.currentPage + 1) % pages.count
    let offsetX = CGFloat(next) * (cellWidth + itemSpacing) - sideInset
    collectionView.setContentOffset(.init(x: offsetX, y: 0), animated: true)
    pageControl.currentPage = next
  }
}

// MARK: – UICollectionViewDataSource & Delegate
extension WebCarouselViewController: UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout,
                                     UIScrollViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int { pages.count }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WebViewCell.reuseId,
                                                  for: indexPath) as! WebViewCell
    cell.configure(with: pages[indexPath.item])
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
}

// MARK: – Cell
final class WebViewCell: UICollectionViewCell {
  
  static let reuseId = "WebViewCell"
  
  private lazy var webView: WKWebView = {
    let prefs = WKWebpagePreferences()
    prefs.allowsContentJavaScript = true                          // se precisar de JS
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences = prefs
    let wv = WKWebView(frame: .zero, configuration: config)
    wv.scrollView.isScrollEnabled = true                         // evita rolagem dentro do card
    wv.translatesAutoresizingMaskIntoConstraints = false
    return wv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.layer.cornerRadius = 12
    contentView.clipsToBounds = true
    setupWebView()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  private func setupWebView() {
    contentView.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: contentView.topAnchor),
      webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  func configure(with page: WebPage) {
    webView.load(URLRequest(url: page.url))
    // A11y
    webView.accessibilityLabel = page.title
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
}
