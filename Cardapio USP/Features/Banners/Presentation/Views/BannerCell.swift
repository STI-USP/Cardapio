//
//  BannerCell.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 12/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit

final class BannerCell: UICollectionViewCell {
  static let reuseId = "BannerCell"

  private let containerView = UIView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let actionIcon = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupContainer()
    setupLabels()
    setupActionIcon()
  }

  required init?(coder: NSCoder) { fatalError() }

  private func setupContainer() {
    containerView.layer.cornerRadius = 12
    containerView.clipsToBounds = true
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .systemGray6
    contentView.addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }

  private func setupLabels() {
    titleLabel.font = .boldSystemFont(ofSize: 18)
    titleLabel.numberOfLines = 2

    subtitleLabel.font = .systemFont(ofSize: 14)
    subtitleLabel.numberOfLines = 4

    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stack.axis = .vertical
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
      stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    ])
  }

  private func setupActionIcon() {
    actionIcon.translatesAutoresizingMaskIntoConstraints = false
    actionIcon.image = UIImage(systemName: "chevron.right")
    actionIcon.tintColor = .white
    actionIcon.contentMode = .scaleAspectFit

    containerView.addSubview(actionIcon)

    NSLayoutConstraint.activate([
      actionIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      actionIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
      actionIcon.widthAnchor.constraint(equalToConstant: 16),
      actionIcon.heightAnchor.constraint(equalToConstant: 16)
    ])
  }

  func configure(with banner: Banner) {
    containerView.backgroundColor = banner.backgroundColor
    titleLabel.textColor = banner.textColor
    subtitleLabel.textColor = banner.textColor
    actionIcon.tintColor = banner.textColor
    titleLabel.text = banner.title
    subtitleLabel.text = banner.subtitle
    contentView.accessibilityLabel = "\(banner.title). \(banner.subtitle). Toque para saber mais."
  }

  override var isHighlighted: Bool {
    didSet {
      UIView.animate(withDuration: 0.2) {
        self.containerView.alpha = self.isHighlighted ? 0.85 : 1.0
        self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
      }
    }
  }
}
