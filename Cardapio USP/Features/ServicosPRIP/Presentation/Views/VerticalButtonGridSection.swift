//
//  VerticalButtonGridSection.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 06/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import Combine

// MARK: – Seção
final class VerticalButtonGridSection: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  private var collectionView: UICollectionView!
  private let pageControl = UIPageControl()
  private var viewModel = ButtonGridViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var items: [GridItem] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupPageControl()
    setupCollectionView()
    bind()
    viewModel.loadItems()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = .zero
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 0
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(ButtonGridPageCell.self, forCellWithReuseIdentifier: "pageCell")
    collectionView.backgroundColor = .clear
    collectionView.layer.cornerRadius = 12
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -8),
    ])
  }
  
  private func setupPageControl() {
    pageControl.numberOfPages = 2
    pageControl.pageIndicatorTintColor = .systemGray4
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(pageControl)
    
    NSLayoutConstraint.activate([
      pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
      pageControl.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  private func bind() {
    viewModel.$items
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newItems in
        guard let self else { return }
        self.items = newItems
        self.pageControl.numberOfPages = Int(ceil(Double(newItems.count) / 4.0))
        self.collectionView.reloadData()
      }
      .store(in: &cancellables)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.bounds.width,
           height: collectionView.bounds.height)
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 2 }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell", for: indexPath) as! ButtonGridPageCell
    let start = indexPath.item * 4
    let end = min(start + 4, items.count)
    cell.configure(items: Array(items[start..<end])) { title, url in
      if let vc = self.findViewController() {
        let webVC = WebViewViewController()
        webVC.urlString = url
        vc.navigationController?.pushViewController(webVC, animated: true)
      }
    }
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = page
  }
}

// MARK: – Página (grade 2 × 2)
final class ButtonGridPageCell: UICollectionViewCell {
  
  private let gridStack = UIStackView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setup() {
    contentView.backgroundColor = .clear
    contentView.layer.cornerRadius = 12
    
    gridStack.axis = .vertical
    gridStack.distribution = .fillEqually
    gridStack.spacing = 8
    gridStack.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(gridStack)
    NSLayoutConstraint.activate([
      gridStack.topAnchor.constraint(equalTo: contentView.topAnchor),
      gridStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      gridStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      gridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  func configure(items: [GridItem], handler: @escaping (String, String) -> Void) {
    gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    stride(from: 0, to: items.count, by: 2).forEach { index in
      let hStack = UIStackView()
      hStack.axis = .horizontal
      hStack.distribution = .fillEqually
      hStack.spacing = 8
      
      for i in 0..<2 {
        guard index + i < items.count else { continue }
        let item = items[index + i]
        let button = SquareGridButton(title: item.title,
                                      image: item.image,
                                      url: item.url,
                                      action: handler)
        hStack.addArrangedSubview(button)
      }
      
      gridStack.addArrangedSubview(hStack)
    }
  }
}

// MARK: – Botão quadrado com UIButton
private final class SquareGridButton: UIView {
  
  private let url: String
  private let action: (String, String) -> Void
  private let button = UIButton(type: .system)
  private let title: String

  init(title: String, image: UIImage?, url: String,
       action: @escaping (String, String) -> Void) {
    
    self.url = url
    self.action = action
    self.title = title
    super.init(frame: .zero)
    
    backgroundColor = UIColor(named: "CardBackground")
    layer.cornerRadius = 12
    layer.borderWidth = 0.5
     layer.borderColor = UIColor.separator.cgColor
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalTo: widthAnchor).isActive = true // quadrado

    // Conteúdo visual
    let icon = UIImageView(image: image)
    icon.tintColor = .uspPrimary
    icon.contentMode = .scaleAspectFit
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.heightAnchor.constraint(equalToConstant: 32).isActive = true

    let label = UILabel()
    label.text = title
    label.font = .uspRegular(ofSize: 14)
    label.textAlignment = .center
    label.numberOfLines = 2

    let stack = UIStackView(arrangedSubviews: [icon, label])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false

    // Botão cobre tudo e recebe o toque
    button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stack)
    addSubview(button)

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
      
      button.topAnchor.constraint(equalTo: topAnchor),
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  required init?(coder: NSCoder) { fatalError() }

  @objc private func tapped() {
    animateTap {
      self.action(self.title, self.url)
    }
  }

  private func animateTap(_ completion: @escaping () -> Void) {
    UIView.animate(withDuration: 0.1, animations: {
      self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      self.alpha = 0.7
    }) { _ in
      UIView.animate(withDuration: 0.1, animations: {
        self.transform = .identity
        self.alpha = 1.0
      }) { _ in completion() }
    }
  }
}
