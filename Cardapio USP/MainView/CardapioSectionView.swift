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
    mainStack.spacing = 8
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(mainStack)
    
    let headerStack = UIStackView()
    headerStack.axis = .horizontal
    headerStack.distribution = .equalSpacing
    
    restauranteLabel.text = "Restaurante Central"
    restauranteLabel.font = .uspBold(ofSize: 20)
    
    dataLabel.text = "14/04/2025"
    dataLabel.font = .uspLight(ofSize: 14)
    dataLabel.textColor = .uspSecondary
    
    headerStack.addArrangedSubview(restauranteLabel)
    headerStack.addArrangedSubview(dataLabel)
    
    refeicaoLabel.text = "Almoço"
    refeicaoLabel.font = .uspRegular(ofSize: 16)
    refeicaoLabel.textColor = .uspSecondary
    
    pratosStack.axis = .vertical
    pratosStack.spacing = 2
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

