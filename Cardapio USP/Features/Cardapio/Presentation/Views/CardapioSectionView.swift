//
//  CardapioSectionView.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit
import Combine

class CardapioSectionView: UIView {
  private let restauranteLabel = UILabel()
  private let dataLabel = UILabel()
  private let refeicaoLabel = UILabel()
  private let pratosStack = UIStackView()
  private var cancellables = Set<AnyCancellable>()
  
  private var maxDishesDisplayed: Int {
    return 6
//    // altura real da view depois do layout
//    let h = bounds.height
//    
//    switch h {
//    case ...667:  return 4    // SE de 1ª geração
//    case ...736:  return 6    // iPhone 8 / SE 3
//    case ...812:  return 8    // 11-14-15 não-Pro
//    case ...852:  return 8    // 14-15 Pro
//    case ...926:  return 9    // 14-15 Pro Max
//    default:      return 10   // iPads e afins
//    }
  }
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func bind(to vm: CardapioViewModel) {
    vm.$restaurantName.assign(to: \.text, on: restauranteLabel).store(in: &cancellables)
    vm.$formattedDate.assign(to: \.text, on: dataLabel).store(in: &cancellables)
    vm.$mealPeriod.assign(to: \.text, on: refeicaoLabel).store(in: &cancellables)
    
    vm.$items.sink { [weak self] itens in
      guard let self else { return }
      pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
      itens.forEach {
        let l = UILabel(); l.font = .uspRegular(ofSize: 15); l.text = $0
        pratosStack.addArrangedSubview(l)
      }
    }.store(in: &cancellables)
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
    
    restauranteLabel.text = "Restaurante Central"
    restauranteLabel.font = .uspBold(ofSize: 18)
    restauranteLabel.textColor = .uspSecondary
    
    dataLabel.text = "14/04/2025"
    dataLabel.font = .uspLight(ofSize: 14)
    dataLabel.textColor = .uspPrimary
    
    restauranteLabel.numberOfLines = 2
    restauranteLabel.lineBreakMode = .byWordWrapping
    dataLabel.setContentHuggingPriority(.required, for: .horizontal)
    restauranteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    headerStack.addArrangedSubview(restauranteLabel)
    headerStack.addArrangedSubview(dataLabel)
    
    refeicaoLabel.text = "Almoço"
    refeicaoLabel.font = .uspRegular(ofSize: 16)
    refeicaoLabel.textColor = .uspPrimary
    
    pratosStack.axis = .vertical
    pratosStack.spacing = 1
    let itens = ["Arroz", "Feijão", "Bife acebolado", "Salada", "Maçã", "Suco"]
    for item in itens {
      let label = UILabel()
      label.text = item
      label.font = .uspRegular(ofSize: 15)
      pratosStack.addArrangedSubview(label)
    }
    
    mainStack.addArrangedSubview(headerStack)
    mainStack.addArrangedSubview(refeicaoLabel)
    mainStack.addArrangedSubview(pratosStack)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }
}

extension CardapioSectionView {
  func update(restaurant: String,
              dateText: String,
              periodText: String,
              items: [String]) {
    restauranteLabel.text = restaurant
    dataLabel.text        = dateText
    refeicaoLabel.text    = periodText.capitalized
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    // remove antigos
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    // adiciona até o limite
    for dish in items.prefix(maxDishesDisplayed) {
      let l = UILabel()
      l.font = .uspRegular(ofSize: 15)
      l.text = dish
      l.numberOfLines = 1
      l.lineBreakMode = .byTruncatingTail
      pratosStack.addArrangedSubview(l)
    }
    
    // se vierem mais pratos, mostra reticências
    //    if items.count > maxDishesDisplayed {
    //      let more = UILabel()
    //      more.font = .uspRegular(ofSize: 15)
    //      more.text = "…"
    //      pratosStack.addArrangedSubview(more)
    //    }
  }
}
