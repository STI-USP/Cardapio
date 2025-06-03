//
//  SaldoSectionView.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit
import Combine

class SaldoSectionView: UIView {
  private let saldoTitleLabel = UILabel()
  private let saldoValueLabel = UILabel()
  private let addCreditButton = UIButton(type: .system)

  private var cancellables = Set<AnyCancellable>()

  var onAddCreditTapped: (() -> Void)?
  
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func bind(to vm: SaldoViewModel) {
      vm.$balanceText.assign(to: \.text, on: saldoValueLabel).store(in: &cancellables)
  }

  private func setup() {
    backgroundColor = UIColor.uspPrimary.withAlphaComponent(0.1)
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.uspPrimary.cgColor
    
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 12
    stack.alignment = .center
    stack.distribution = .equalSpacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    let textStack = UIStackView()
    textStack.axis = .vertical
    textStack.spacing = 4
    
    saldoTitleLabel.text = "Saldo disponível"
    saldoTitleLabel.font = .uspLight(ofSize: 14)
    //saldoTitleLabel.textColor = .uspAccent
    
    saldoValueLabel.text = "R$ 15,00"
    saldoValueLabel.font = .uspBold(ofSize: 24)
    //saldoValueLabel.textColor = .uspAccent
    
    textStack.addArrangedSubview(saldoTitleLabel)
    textStack.addArrangedSubview(saldoValueLabel)
    
    addCreditButton.setTitle("Adicionar Créditos", for: .normal)
    addCreditButton.setTitleColor(.white, for: .normal)
    addCreditButton.backgroundColor = .uspPrimary
    addCreditButton.layer.cornerRadius = 8
    addCreditButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    addCreditButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
    addCreditButton.addTarget(self, action: #selector(handleAddCredit), for: .touchUpInside)
    
    stack.addArrangedSubview(textStack)
    stack.addArrangedSubview(addCreditButton)
    addSubview(stack)
    
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }
  
  @objc private func handleAddCredit() {
    onAddCreditTapped?()
  }
  
  
}

extension SaldoSectionView {
    func update(balanceText: String) {
      saldoValueLabel.text = balanceText
    }
}
