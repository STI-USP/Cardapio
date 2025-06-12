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
    contentView.accessibilityLabel = "\(banner.title). \(banner.subtitle)"
  }
}
