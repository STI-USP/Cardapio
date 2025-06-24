//
//  AddCreditsViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 24/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import UIKit
import Combine
import SVProgressHUD

@MainActor
final class AddCreditsViewController: UIViewController, UITextFieldDelegate {
  
  // MARK: – View-Model
  private let viewModel = AddCreditsViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: – UI
  private let userNameLabel = UILabel()
  private let saldoValueLabel = UILabel()
  private let valueTextField = UITextField()
  private let generateButton = UIButton(type: .system)
  private let lastPixHeader = UILabel()
  private let lastPixLabel = UILabel()
  private let lastPixStatusLabel = UILabel()
  private let copyButton = UIButton(type: .system)
  
  // Formatter
  private let brlFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.locale = Locale(identifier: "pt_BR")
    f.numberStyle = .currency
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return f
  }()
  
  // MARK: – Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "RUCard"
    view.backgroundColor = UIColor(named: "MainBackground")
    
    buildLayout()
    bindViewModel()
    observeNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    SVProgressHUD.dismiss()
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Bindings
private extension AddCreditsViewController {
  
  func bindViewModel() {
    // Saldo
    viewModel.$balanceText
      .map(Optional.init)
      .receive(on: RunLoop.main)
      .assign(to: \.text, on: saldoValueLabel)
      .store(in: &cancellables)
    
    // Último Pix
    viewModel.$lastPix
      .receive(on: RunLoop.main)
      .sink { [weak self] pix in
        guard let self, let pix else { return }
        lastPixLabel.text   = "Valor: \(brlFormatter.string(from: pix.valor as NSDecimalNumber) ?? "--")"
        lastPixStatusLabel.text = "Situação: \(pix.situacao)"
        let open = pix.situacao == "Em aberto"
        copyButton.isEnabled = open
        copyButton.alpha     = open ? 1 : 0.5
      }.store(in: &cancellables)
    
    // Loading HUD
    viewModel.$isLoading
      .receive(on: RunLoop.main)
      .sink { $0 ? SVProgressHUD.show() : SVProgressHUD.dismiss() }
      .store(in: &cancellables)
    
    // Error
    viewModel.$error
      .compactMap { $0 }
      .receive(on: RunLoop.main)
      .sink { [weak self] in self?.showAlert($0) }
      .store(in: &cancellables)
  }
}

// MARK: - Legacy notifications (apenas Pix criado & login)
private extension AddCreditsViewController {
  
  func observeNotifications() {
    let nc = NotificationCenter.default
    
    nc.addObserver(forName: .init("DidCreatePix"), object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor in
        SVProgressHUD.dismiss()
        self?.presentPixModal() }
    }
    
    nc.addObserver(forName: .init("DidReceiveLoginError"), object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor in self?.presentLogin() }
    }
  }
  
  @MainActor
  func presentPixModal() {
    let sb  = UIStoryboard(name: "Main_iPhone", bundle: nil)
    guard let pvc = sb.instantiateViewController(withIdentifier: "pixViewController") as? PixViewController else { return }
    
    let nav = UINavigationController(rootViewController: pvc)
    nav.modalPresentationStyle = .formSheet
    present(nav, animated: true)
  }
}

// MARK: - Layout
private extension AddCreditsViewController {
  
  func buildLayout() {
    // Scroll + Stack
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scroll)
    
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 24
    stack.translatesAutoresizingMaskIntoConstraints = false
    scroll.addSubview(stack)
    
    NSLayoutConstraint.activate([
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 24),
      stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 24),
      stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -24),
      stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
      stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -48)
    ])
    
    // 1) Nome
    userNameLabel.font = .uspBold(ofSize: 24)
    userNameLabel.textAlignment = .center
    userNameLabel.numberOfLines = 2
    userNameLabel.text = OAuthUSP.sharedInstance().userData?["nomeUsuario"] as? String
    
    // 2) Saldo card
    let saldoCard = USPCardView()
    let saldoTitle = UILabel(text: "Saldo disponível", font: .uspRegular(ofSize: 14))
    saldoTitle.textColor = .uspAccent
    saldoValueLabel.font = .uspBold(ofSize: 24)
    saldoValueLabel.textColor = .uspAccent
    let saldoStack = UIStackView(arrangedSubviews: [saldoTitle, saldoValueLabel])
    saldoStack.axis = .vertical
    saldoStack.alignment = .center
    saldoStack.spacing = 4
    saldoStack.pin(in: saldoCard, inset: 12)
    
    // 3) Formulário
    let recargaHeader = UILabel(text: "Recargue seu RUCard", font: .uspBold(ofSize: 20))
    recargaHeader.textColor = .uspSecondary
    
    valueTextField.borderStyle = .roundedRect
    valueTextField.keyboardType = .decimalPad
    valueTextField.placeholder = "Valor (R$)"
    valueTextField.delegate = self
    valueTextField.addTarget(self, action: #selector(maskCurrency(_:)), for: .editingChanged)
    
    generateButton.configuration = .filled()
    generateButton.configuration?.title = "Gerar código Pix"
    generateButton.configuration?.baseBackgroundColor = .uspPrimary
    generateButton.configuration?.baseForegroundColor  = .white
    generateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    generateButton.addTarget(self, action: #selector(generatePixTapped), for: .touchUpInside)
    
    let formInfo = UILabel(text: "Gere um código de pagamento via Pix para valores entre R$10,00 e R$200,00.",
                           font: .uspRegular(ofSize: 16),
                           lines: 0,
                           alignment: .center)
    
    let formStack = UIStackView(arrangedSubviews: [formInfo, valueTextField, generateButton])
    formStack.axis = .vertical
    formStack.spacing = 12
    let formCard = USPCardView(embed: formStack, inset: 16)
    
    // 4) Último Pix card
    lastPixHeader.text = "Último Pix gerado"
    lastPixHeader.font = .uspBold(ofSize: 20)
    lastPixHeader.textColor = .uspSecondary
    
    lastPixLabel.font = .uspRegular(ofSize: 16)
    lastPixStatusLabel.font = .uspLight(ofSize: 14)
    lastPixStatusLabel.textColor = .uspSecondary
    
    copyButton.configuration = .filled()
    copyButton.configuration?.title = "Copiar código Pix"
    copyButton.configuration?.baseBackgroundColor = .uspPrimary
    copyButton.configuration?.baseForegroundColor  = .white
    copyButton.addTarget(self, action: #selector(copyPixTapped), for: .touchUpInside)
    
    let lastInfo = UIStackView(arrangedSubviews: [lastPixLabel, lastPixStatusLabel])
    lastInfo.axis = .vertical
    lastInfo.spacing = 4
    
    let lastRow = UIStackView(arrangedSubviews: [lastInfo, copyButton])
    lastRow.axis = .horizontal
    lastRow.alignment = .center
    lastRow.distribution = .equalSpacing
    
    let lastCard = USPCardView(embed: lastRow, style: .outline, inset: 16)
    
    // 5) Add to stack
    stack.addArrangedSubview(userNameLabel)
    stack.addArrangedSubview(saldoCard)
    stack.addArrangedSubview(recargaHeader)
    stack.addArrangedSubview(formCard)
    stack.addArrangedSubview(lastPixHeader)
    stack.addArrangedSubview(lastCard)
  }
}

// MARK: - Actions
private extension AddCreditsViewController {
  
  @objc func generatePixTapped() {
    guard validateValueMin(10) else { return }
    SVProgressHUD.show()
    Task { await viewModel.generatePix(amountText: numericText()) }
  }
  
  @objc func copyPixTapped() {
    guard let code = viewModel.lastPix?.copiaCola, !code.isEmpty else { return }
    UIPasteboard.general.string = code
    SVProgressHUD.showSuccess(withStatus: "Copiado")
  }
}

// MARK: - UITextField helpers
private extension AddCreditsViewController {
  
  @objc func maskCurrency(_ tf: UITextField) {
    let digits = tf.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? ""
    let cents  = Decimal(string: digits) ?? 0
    let value  = cents / 100
    tf.text = brlFormatter.string(from: value as NSNumber)
    
    // mantém cursor no fim
    if let end = tf.position(from: tf.endOfDocument, offset: 0),
       let range = tf.textRange(from: end, to: end) {
      tf.selectedTextRange = range
    }
  }
  
  func numericText() -> String {
    let digits = valueTextField.text?
      .components(separatedBy: CharacterSet.decimalDigits.inverted)
      .joined() ?? ""
    return digits.insertingComma(beforeFromEnd: 2)
  }
}

// MARK: - Validation & alert
private extension AddCreditsViewController {
  
  func validateValueMin(_ min: Decimal) -> Bool {
    let txt = numericText().replacingOccurrences(of: ",", with: ".")
    guard let value = Decimal(string: txt),
          value >= min, value <= 200 else {
      showAlert("Insira um valor entre R$ \(min) e R$ 200,00")
      return false
    }
    return true
  }
  
  func showAlert(_ msg: String) {
    let ac = UIAlertController(title: "Erro", message: msg, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
  
  
  func presentLogin() {
    if let vc = storyboard?.instantiateViewController(withIdentifier: "loginWebViewController") {
      present(vc, animated: true)
    }
  }
}

// MARK: – Extensões utilitárias
private extension UILabel {
  convenience init(text: String, font: UIFont, lines: Int = 1, alignment: NSTextAlignment = .left) {
    self.init()
    self.text = text
    self.font = font
    self.numberOfLines = lines
    self.textAlignment = alignment
  }
}

private extension UIView {
  func pin(in superview: UIView, inset: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    superview.addSubview(self)
    NSLayoutConstraint.activate([
      topAnchor .constraint(equalTo: superview.topAnchor,    constant: inset),
      bottomAnchor .constraint(equalTo: superview.bottomAnchor, constant: -inset),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: inset),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -inset)
    ])
  }
}

private extension USPCardView {
  convenience init(embed view: UIView, inset: CGFloat = 12) {
    self.init()
    view.pin(in: self, inset: inset)
  }
}

private extension String {
  /// Intercala vírgula antes dos ‘n’ últimos dígitos (ex.: “1234” → “12,34”)
  func insertingComma(beforeFromEnd n: Int) -> String {
    guard !isEmpty else { return "0,00" }
    let padded = String(repeating: "0", count: max(0, n + 1 - count)) + self
    let idx = padded.index(padded.endIndex, offsetBy: -n)
    return padded[..<idx] + "," + padded[idx...]
  }
}
