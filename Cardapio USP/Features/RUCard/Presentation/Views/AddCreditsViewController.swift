//
//  AddCreditsViewController.swift
//  banner
//
//  Created by Vagner Machado on 16/04/25.
//

import UIKit

class AddCreditsViewController: UIViewController {
  
  private let userNameLabel = UILabel()
  private let saldoContainer = USPCardView()
  private let saldoTitleLabel = UILabel()
  private let saldoValueLabel = UILabel()
  private let formContainer = USPCardView()
  private let formHeader = UILabel()
  private let instructionsLabel = UILabel()
  private let valueTextField = UITextField()
  private let generatePixButton = UIButton(type: .system)
  private let lastPixHeader = UILabel()
  private let lastPixLabel = UILabel()
  private let lastPixStatusLabel = UILabel()
  private let copyPixButton = UIButton(type: .system)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "RUCard"
    view.backgroundColor = .secondarySystemBackground
    setupLayout()
  }
  
  private func setupLayout() {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 24
    stack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stack)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
      stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
      stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
      stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
      stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
    ])
    
    userNameLabel.text = ""
    userNameLabel.font = .uspBold(ofSize: 24)
    userNameLabel.textAlignment = .center
    
    let saldoStack = UIStackView()
    saldoStack.axis = .vertical
    saldoStack.spacing = 4
    saldoStack.alignment = .center
    saldoStack.translatesAutoresizingMaskIntoConstraints = false
    
    saldoTitleLabel.text = "Saldo disponível"
    saldoTitleLabel.font = .uspRegular(ofSize: 14)
    saldoTitleLabel.textColor = .uspAccent
    
    saldoValueLabel.text = "R$ --,--"
    saldoValueLabel.font = .uspBold(ofSize: 24)
    saldoValueLabel.textColor = .uspAccent
    
    saldoStack.addArrangedSubview(saldoTitleLabel)
    saldoStack.addArrangedSubview(saldoValueLabel)
    saldoContainer.addSubview(saldoStack)
    
    NSLayoutConstraint.activate([
      saldoStack.topAnchor.constraint(equalTo: saldoContainer.topAnchor, constant: 12),
      saldoStack.bottomAnchor.constraint(equalTo: saldoContainer.bottomAnchor, constant: -12),
      saldoStack.leadingAnchor.constraint(equalTo: saldoContainer.leadingAnchor, constant: 16),
      saldoStack.trailingAnchor.constraint(equalTo: saldoContainer.trailingAnchor, constant: -16)
    ])
    
    formHeader.text = "Recarga via Pix"
    formHeader.font = .uspBold(ofSize: 20)
    formHeader.textColor = .uspSecondary
    formHeader.textAlignment = .left
    
    let formStack = UIStackView()
    formStack.axis = .vertical
    formStack.spacing = 12
    formStack.translatesAutoresizingMaskIntoConstraints = false
    
    instructionsLabel.text = "Digite o valor desejado e gere um código Pix para recarga."
    instructionsLabel.font = .uspRegular(ofSize: 16)
    instructionsLabel.numberOfLines = 0
    instructionsLabel.textAlignment = .center
    
    valueTextField.placeholder = "Valor a carregar (R$)"
    valueTextField.font = .uspRegular(ofSize: 16)
    valueTextField.keyboardType = .decimalPad
    valueTextField.borderStyle = .roundedRect
    
    generatePixButton.setTitle("Gerar código Pix", for: .normal)
    generatePixButton.setTitleColor(.white, for: .normal)
    generatePixButton.backgroundColor = .uspPrimary
    generatePixButton.titleLabel?.font = .uspBold(ofSize: 16)
    generatePixButton.layer.cornerRadius = 8
    generatePixButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    formStack.addArrangedSubview(instructionsLabel)
    formStack.addArrangedSubview(valueTextField)
    formStack.addArrangedSubview(generatePixButton)
    formContainer.addSubview(formStack)
    
    NSLayoutConstraint.activate([
      formStack.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 16),
      formStack.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: -16),
      formStack.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 16),
      formStack.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16)
    ])
    
    lastPixHeader.text = "Último Pix gerado"
    lastPixHeader.font = .uspBold(ofSize: 20)
    lastPixHeader.textColor = .uspSecondary
    
    lastPixHeader.textAlignment = .left
    
    lastPixLabel.text = "Valor: R$ 20,00"
    lastPixLabel.font = .uspRegular(ofSize: 16)
    
    lastPixStatusLabel.text = "Status: Em aberto"
    lastPixStatusLabel.font = .uspLight(ofSize: 14)
    lastPixStatusLabel.textColor = .uspSecondary
    
    var config = UIButton.Configuration.filled()
    config.title = "Copiar código Pix"
    config.baseBackgroundColor = .uspPrimary
    config.baseForegroundColor = .white
    config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
    copyPixButton.configuration = config
    copyPixButton.titleLabel?.font = .uspBold(ofSize: 14)
    copyPixButton.layer.cornerRadius = 8
    copyPixButton.heightAnchor.constraint(equalToConstant: 36).isActive = true

    let status = lastPixStatusLabel.text?.lowercased() ?? ""
    if status.contains("pago") || status.contains("cancelado") {
      copyPixButton.isEnabled = false
      copyPixButton.alpha = 0.5
    }
    
    let lastPixInfoStack = UIStackView(arrangedSubviews: [lastPixLabel, lastPixStatusLabel])
    lastPixInfoStack.axis = .vertical
    lastPixInfoStack.spacing = 4
    
    let lastPixHorizontal = UIStackView(arrangedSubviews: [lastPixInfoStack, copyPixButton])
    lastPixHorizontal.axis = .horizontal
    lastPixHorizontal.spacing = 12
    lastPixHorizontal.alignment = .center
    lastPixHorizontal.distribution = .equalSpacing
    
    stack.addArrangedSubview(userNameLabel)
    stack.addArrangedSubview(saldoContainer)
    stack.addArrangedSubview(UIView()) // spacer
    stack.addArrangedSubview(formHeader)
    stack.addArrangedSubview(formContainer)
    stack.addArrangedSubview(UIView()) // spacer
    stack.addArrangedSubview(lastPixHeader)
    stack.addArrangedSubview(lastPixHorizontal)
  }
}
