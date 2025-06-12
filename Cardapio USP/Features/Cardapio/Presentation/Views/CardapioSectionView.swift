//
//  CardapioSectionView.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

class CardapioSectionView: UIView {
  private let restauranteLabel = UILabel()
  private let dataLabel = UILabel()
  private let refeicaoLabel = UILabel()
  private let pratosStack = UIStackView()
  private let statusLabel = UILabel()
  
  private var maxDishesDisplayed: Int { 6 }

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.uspPrimary.cgColor
    backgroundColor = .systemBackground

    let mainStack = UIStackView()
    mainStack.axis = .vertical
    mainStack.spacing = 6
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(mainStack)

    let headerStack = UIStackView()
    headerStack.axis = .horizontal
    headerStack.distribution = .equalSpacing
    headerStack.spacing = 8

    restauranteLabel.font = .uspBold(ofSize: 18)
    restauranteLabel.textColor = .uspSecondary
    restauranteLabel.numberOfLines = 2
    restauranteLabel.lineBreakMode = .byWordWrapping
    restauranteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    dataLabel.font = .uspLight(ofSize: 14)
    dataLabel.textColor = .uspPrimary
    dataLabel.setContentHuggingPriority(.required, for: .horizontal)

    headerStack.addArrangedSubview(restauranteLabel)
    headerStack.addArrangedSubview(dataLabel)

    refeicaoLabel.font = .uspRegular(ofSize: 16)
    refeicaoLabel.textColor = .uspPrimary

    pratosStack.axis = .vertical
    pratosStack.spacing = 1

    statusLabel.font = .uspRegular(ofSize: 15)
    statusLabel.textColor = .secondaryLabel
    statusLabel.numberOfLines = 0
    statusLabel.textAlignment = .center

    mainStack.addArrangedSubview(headerStack)
    mainStack.addArrangedSubview(refeicaoLabel)
    mainStack.addArrangedSubview(statusLabel)
    mainStack.addArrangedSubview(pratosStack)

    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }

  func showLoading() {
    restauranteLabel.text = ""
    dataLabel.text = ""
    refeicaoLabel.text = ""
    statusLabel.isHidden = false
    statusLabel.text = "Carregando…"
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
  }

  func showError(_ message: String) {
    restauranteLabel.text = ""
    dataLabel.text = ""
    refeicaoLabel.text = ""
    statusLabel.isHidden = false
    statusLabel.text = message
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
  }

  func update(restaurant: String,
              dateText: String,
              periodText: String,
              items: [String]) {
    restauranteLabel.text = restaurant
    dataLabel.text = dateText
    refeicaoLabel.text = periodText.capitalized
    statusLabel.isHidden = true
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    for dish in items.prefix(maxDishesDisplayed) {
      let l = UILabel()
      l.font = .uspRegular(ofSize: 15)
      l.text = dish
      l.numberOfLines = 1
      l.lineBreakMode = .byTruncatingTail
      pratosStack.addArrangedSubview(l)
    }

    if items.count > maxDishesDisplayed {
      let more = UILabel()
      more.font = .uspRegular(ofSize: 15)
      more.text = "…"
      pratosStack.addArrangedSubview(more)
    }
  }
}
