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

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupContainer()
    setupLabels()
  }

  required init?(coder: NSCoder) { fatalError() }

  private func setupContainer() {
    containerView.layer.cornerRadius = 12
    containerView.clipsToBounds = true
    containerView.translatesAutoresizingMaskIntoConstraints = false
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
      stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    ])
  }

  func configure(with banner: Banner) {
    containerView.backgroundColor = banner.backgroundColor
    titleLabel.textColor = banner.textColor
    subtitleLabel.textColor = banner.textColor
    titleLabel.text = banner.title
    subtitleLabel.text = banner.subtitle
    contentView.accessibilityLabel = "\(banner.title). \(banner.subtitle)"
  }
}
