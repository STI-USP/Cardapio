//
//  VerticalButtonGridSection.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 06/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit

// MARK: – Seção
final class VerticalButtonGridSection: UIView,
                                       UICollectionViewDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {
  
  // MARK: Dados (8 itens → 2 páginas × 4 botões)
  private let items = [
    (title: "Apoio estudantil", image: UIImage(systemName: "graduationcap"), url: "https://apoio.usp.br"),
    (title: "Transporte",       image: UIImage(systemName: "bus"),           url: "https://transporte.usp.br"),
    (title: "Avisos",           image: UIImage(systemName: "megaphone"),     url: "https://avisos.usp.br"),
    (title: "Saúde mental",     image: UIImage(systemName: "brain.head.profile"), url: "https://saudemental.usp.br"),
    (title: "Moradia",          image: UIImage(systemName: "house"),         url: "https://moradia.usp.br"),
    (title: "Creche",           image: UIImage(systemName: "figure.2.and.child.holdinghands"), url: "https://creche.usp.br"),
    (title: "Serviço social",   image: UIImage(systemName: "person.2.crop.square.stack"),      url: "https://servicosocial.usp.br"),
    (title: "Programa ECOS",    image: UIImage(systemName: "leaf"),          url: "https://ecos.usp.br")
  ]
  
  // MARK: UI
  private var collectionView: UICollectionView!
  private let pageControl = UIPageControl()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: – Setup
  private func setup() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 16          // “folga” entre páginas
    // 🔹 NÃO defina itemSize aqui – vamos calcular no delegate
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(ButtonGridPageCell.self,
                            forCellWithReuseIdentifier: "pageCell")
    collectionView.backgroundColor = .clear
    collectionView.layer.cornerRadius = 12
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    pageControl.numberOfPages = 2
    pageControl.pageIndicatorTintColor = .systemGray4
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(collectionView)
    addSubview(pageControl)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -8),
      
      pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
      pageControl.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  // MARK: – Delegate para dar size dinâmico
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width - 40 // 20 pt de “peek” cada lado
    let height = collectionView.bounds.height // usa tudo que receber
    return CGSize(width: width, height: height)
  }
  
  // MARK: UICollectionViewDataSource
  func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 2 }
  
  func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageCell",
                                                  for: indexPath) as! ButtonGridPageCell
    let start = indexPath.item * 4
    let end = start + 4
    cell.configure(items: Array(items[start..<end])) { title, url in
      if let vc = self.findViewController() {
        let webVC = WebViewViewController()
        webVC.urlString = url
        vc.navigationController?.pushViewController(webVC, animated: true)
      }
    }
    return cell
  }
  
  // MARK: Scroll → PageControl
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
    contentView.backgroundColor = .secondarySystemGroupedBackground
    contentView.layer.cornerRadius = 12
    
    gridStack.axis = .vertical
    gridStack.distribution = .fillEqually
    gridStack.spacing = 12
    gridStack.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(gridStack)
    NSLayoutConstraint.activate([
      gridStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      gridStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      gridStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      gridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
  func configure(items: [(title: String, image: UIImage?, url: String)],
                 handler: @escaping (String, String) -> Void) {
    
    gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    // cria 2 linhas, cada uma com 2 botões
    stride(from: 0, to: items.count, by: 2).forEach { index in
      let hStack = UIStackView()
      hStack.axis = .horizontal
      hStack.distribution = .fillEqually
      hStack.spacing = 12
      
      for i in 0..<2 {
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

// MARK: – Botão quadrado
private final class SquareGridButton: UIControl {
  
  private let url: String
  private let action: (String, String) -> Void
  
  init(title: String, image: UIImage?, url: String,
       action: @escaping (String, String) -> Void) {
    
    self.url = url
    self.action = action
    super.init(frame: .zero)
    
    backgroundColor = .tertiarySystemGroupedBackground
    layer.cornerRadius = 12
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.systemGray4.cgColor
    translatesAutoresizingMaskIntoConstraints = false
    heightAnchor.constraint(equalTo: widthAnchor).isActive = true   // quadrado
    
    let icon = UIImageView(image: image)
    icon.tintColor = .uspPrimary
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.contentMode = .scaleAspectFit
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
    
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
    ])
    
    addTarget(self, action: #selector(tapped), for: .touchUpInside)
  }
  required init?(coder: NSCoder) { fatalError() }
  
  @objc private func tapped() {
    animateTap {
      self.action((self.subviews.first as? UIStackView)?
        .arrangedSubviews
        .compactMap { ($0 as? UILabel)?.text }
        .first ?? "",
                  self.url)
    }
  }
  
  // toque com animação sutil
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

//// MARK: – Helpers
//extension UIView {
//    /// Sobe pela hierarquia de responder até achar o view-controller
//    func findViewController() -> UIViewController? {
//        sequence(first: self as UIResponder?) { $0?.next }
//            .first { $0 is UIViewController } as? UIViewController
//    }
//}
