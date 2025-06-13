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
    pratosStack.clipsToBounds = true
    
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
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
    addGestureRecognizer(tapGesture)
    isUserInteractionEnabled = true
    
  }
  
  @objc private func cardTapped() {
    guard let vc = findViewController() else { return }

    let storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
    let menuVC = storyboard.instantiateViewController(withIdentifier: "menuViewController")
    vc.navigationController?.pushViewController(menuVC, animated: true)
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
  
  func update(restaurant: String, dateText: String, periodText: String, items: [String]) {
    restauranteLabel.text = restaurant
    dataLabel.text = dateText
    refeicaoLabel.text = periodText.capitalized
    statusLabel.isHidden = true
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    layoutIfNeeded() // garante que o layout esteja atualizado
    
    // Altura máxima disponível para a stack de pratos
    let availableHeight = pratosStack.bounds.height > 0
    ? pratosStack.bounds.height
    : bounds.height - 120 // fallback caso ainda não tenha layout
    
    var usedHeight: CGFloat = 0
    var labels: [UILabel] = []
    
    for dish in items {
      let label = UILabel()
      label.font = .uspRegular(ofSize: 15)
      label.numberOfLines = 1
      label.lineBreakMode = .byTruncatingTail
      label.text = dish
      
      let fittingSize = label.systemLayoutSizeFitting(
        CGSize(width: bounds.width - 24, height: .greatestFiniteMagnitude),
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel
      )
      
      let height = fittingSize.height + pratosStack.spacing
      if usedHeight + height > availableHeight {
        // último item visível
        if let last = labels.last {
          last.text = (last.text ?? "") + " […]"
        }
        break
      }
      
      usedHeight += height
      labels.append(label)
    }
    
    labels.forEach { pratosStack.addArrangedSubview($0) }
  }
}
