//
//  VerticalButtonListSection.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

class VerticalButtonListSection: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  private var collectionView: UICollectionView!
  private let pageControl = UIPageControl()
  private let items = [
    (title: "Apoio estudantil", image: UIImage(systemName: "graduationcap"), url: "https://apoio.usp.br"),
    (title: "Transporte", image: UIImage(systemName: "bus"), url: "https://transporte.usp.br"),
    (title: "Avisos", image: UIImage(systemName: "megaphone"), url: "https://avisos.usp.br"),
    (title: "Saúde mental", image: UIImage(systemName: "brain.head.profile"), url: "https://saudemental.usp.br"),
    (title: "Moradia", image: UIImage(systemName: "house"), url: "https://moradia.usp.br"),
    (title: "Creche", image: UIImage(systemName: "figure.2.and.child.holdinghands"), url: "https://creche.usp.br"),
    (title: "Serviço social", image: UIImage(systemName: "person.2.crop.square.stack"), url: "https://servicosocial.usp.br"),
    (title: "Programa ECOS", image: UIImage(systemName: "leaf"), url: "https://ecos.usp.br")
  ]

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 16
    let width = UIScreen.main.bounds.width - 40
    layout.itemSize = CGSize(width: width, height: 200)

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(ButtonListPageCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .clear
    collectionView.layer.cornerRadius = 12
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    pageControl.numberOfPages = Int(ceil(Double(items.count) / 4.0))
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = .systemGray4
    pageControl.currentPageIndicatorTintColor = .uspPrimary
    pageControl.translatesAutoresizingMaskIntoConstraints = false

    addSubview(collectionView)
    addSubview(pageControl)

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 200),

      pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
      pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
      pageControl.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Int(ceil(Double(items.count) / 4.0))
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ButtonListPageCell
    let start = indexPath.item * 4
    let end = min(start + 4, items.count)
    cell.configure(items: Array(items[start..<end]), handler: { title, url in
      if let viewController = self.findViewController() {
        let webVC = WebViewViewController()
        webVC.urlString = url
        viewController.navigationController?.pushViewController(webVC, animated: true)
      }
    })
    return cell
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = page
  }
}

class ButtonListPageCell: UICollectionViewCell {
  private let stack = UIStackView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    stack.axis = .vertical
    stack.spacing = 0.5
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .fillEqually
    contentView.addSubview(stack)
    contentView.backgroundColor = .secondarySystemGroupedBackground
    contentView.layer.cornerRadius = 12

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
    ])
  }

  func configure(items: [(title: String, image: UIImage?, url: String)], handler: @escaping (String, String) -> Void) {
    stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    for item in items {
      let container = UIView()
      container.layer.cornerRadius = 8
      container.backgroundColor = .secondarySystemGroupedBackground
      container.translatesAutoresizingMaskIntoConstraints = false
      container.clipsToBounds = true

      let row = UIStackView()
      row.axis = .horizontal
      row.alignment = .center
      row.spacing = 12
      row.translatesAutoresizingMaskIntoConstraints = false

      let icon = UIImageView(image: item.image)
      icon.tintColor = .label
      icon.contentMode = .scaleAspectFit
      icon.translatesAutoresizingMaskIntoConstraints = false
      icon.widthAnchor.constraint(equalToConstant: 28).isActive = true
      icon.heightAnchor.constraint(equalToConstant: 28).isActive = true

      let label = UILabel()
      label.text = item.title
      label.font = .uspRegular(ofSize: 16)
      label.textColor = .label

      let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
      arrow.tintColor = .secondaryLabel
      arrow.contentMode = .scaleAspectFit
      arrow.translatesAutoresizingMaskIntoConstraints = false
      arrow.widthAnchor.constraint(equalToConstant: 16).isActive = true

      let filler = UIView()
      filler.setContentHuggingPriority(.defaultLow, for: .horizontal)

      row.addArrangedSubview(icon)
      row.addArrangedSubview(label)
      row.addArrangedSubview(filler)
      row.addArrangedSubview(arrow)

      container.addSubview(row)
      NSLayoutConstraint.activate([
        row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
        row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
        row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
        row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
      ])

      let tapButton = UIButton(type: .system)
      tapButton.translatesAutoresizingMaskIntoConstraints = false
      tapButton.backgroundColor = .clear
      tapButton.addTargetClosure { sender in
        container.backgroundColor = UIColor.systemGray5

        UIView.animate(withDuration: 0.1, animations: {
          container.alpha = 0.7
          container.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
          UIView.animate(withDuration: 0.1, animations: {
            container.alpha = 1.0
            container.transform = .identity
            container.backgroundColor = .secondarySystemGroupedBackground
          })
          handler(item.title, item.url)
        }
      }

      container.addSubview(tapButton)
      NSLayoutConstraint.activate([
        tapButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        tapButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        tapButton.topAnchor.constraint(equalTo: container.topAnchor),
        tapButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
      ])

      stack.addArrangedSubview(container)

    }
  }
}

@MainActor private var controlHandlers = [UInt: (UIControl) -> Void]()

private class ClosureSleeve {
  let closure: (UIControl) -> Void
  init(_ closure: @escaping (UIControl) -> Void) { self.closure = closure }
  @objc func invoke(_ sender: UIControl) { closure(sender) }
}

private extension UIControl {
  func addTargetClosure(_ closure: @escaping (UIControl) -> Void) {
    let sleeve = ClosureSleeve(closure)
    addTarget(sleeve, action: #selector(ClosureSleeve.invoke(_:)), for: .touchUpInside)
    objc_setAssociatedObject(self, String(ObjectIdentifier(self).hashValue), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
  }
}

extension UIView {
  func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while responder != nil {
      if let vc = responder as? UIViewController {
        return vc
      }
      responder = responder?.next
    }
    return nil
  }
}
