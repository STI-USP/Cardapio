//
//  CardapioSectionView.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

class CardapioSectionView: UIView {
  
  // MARK: ­UI
  private let restauranteLabel = UILabel()
  private let dataLabel = UILabel()
  private let refeicaoLabel = UILabel()
  private let pratosStack = UIStackView()
  private let statusLabel = UILabel()
  private let bottomSpacer = UIView()
  
  // MARK: Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: Setup
  private func setup() {
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.uspPrimary.cgColor
    backgroundColor = .secondarySystemBackground
    
    let mainStack = UIStackView()
    mainStack.axis = .vertical
    mainStack.alignment = .fill
    mainStack.spacing = 0
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
    
    statusLabel.font = .uspRegular(ofSize: 15)
    statusLabel.textColor = .secondaryLabel
    statusLabel.numberOfLines = 0
    statusLabel.textAlignment = .center
    
    pratosStack.axis = .vertical
    pratosStack.spacing = 0
    pratosStack.clipsToBounds = true
    
    bottomSpacer.setContentHuggingPriority(.defaultLow,  for: .vertical)
    bottomSpacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
    mainStack.addArrangedSubview(headerStack)
    mainStack.addArrangedSubview(refeicaoLabel)
    mainStack.addArrangedSubview(statusLabel)
    mainStack.addArrangedSubview(pratosStack)
    mainStack.addArrangedSubview(bottomSpacer)
    
    // Espaçamentos customizados
    mainStack.setCustomSpacing(8, after: headerStack)   // entre header e refeição
    mainStack.setCustomSpacing(8, after: refeicaoLabel) // entre refeição e itens
    mainStack.setCustomSpacing(8, after: statusLabel)
    
    NSLayoutConstraint.activate([
      mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
    addGestureRecognizer(tap)
  }
  
  // MARK: Navegação
  @objc private func cardTapped() {
    guard let hostVC = findViewController() else { return }
    let storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
    let menuVC = storyboard.instantiateViewController(withIdentifier: "menuViewController")
    hostVC.navigationController?.pushViewController(menuVC, animated: true)
  }
  
  // MARK: Estados
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
  
  // MARK: Update conteúdo
  func update(restaurant: String, dateText: String, periodText: String, items: [String]) {
    
    // 1. Cabeçalho
    restauranteLabel.text = restaurant
    dataLabel.text = dateText
    refeicaoLabel.text = periodText.capitalized
    statusLabel.isHidden = true
    
    // 2. Limpa a lista anterior
    pratosStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    // 3. Deixa o Auto Layout terminar para sabermos as medidas corretas
    layoutIfNeeded()
    
    // 4. Altura disponível dinamica
    // posição Y (local) onde começa a stack dos pratos
    let topOfStack = pratosStack.convert(.zero, to: self).y
    let bottomInset: CGFloat = 12
    // espaço útil que sobrou
    let maxHeight = bounds.height - topOfStack - bottomInset
    
    // 5. Preenche respeitando o espaço
    var currentHeight: CGFloat = 0
    for dish in items {
      let label = UILabel()
      label.font = .uspRegular(ofSize: 15)
      label.lineBreakMode = .byTruncatingTail
      label.text = dish
      
      let labelHeight = label.systemLayoutSizeFitting(
        CGSize(width: bounds.width - 24, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel
      ).height
      
      // inclui spacing apenas se já existe algo na stack
      let spacer = pratosStack.arrangedSubviews.isEmpty ? 0 : pratosStack.spacing
      if currentHeight + spacer + labelHeight > maxHeight {
        // adiciona reticências ao último visível
        (pratosStack.arrangedSubviews.last as? UILabel)?
          .text?.append(" […]")
        break
      }
      
      if spacer > 0 { currentHeight += spacer }
      currentHeight += labelHeight
      pratosStack.addArrangedSubview(label)
    }
  }
}
