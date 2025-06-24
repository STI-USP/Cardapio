//
//  AddCreditsViewController.swift
//  Cardapio USP
//
//  Criado em 16/04/25 – **atualizado em 24/06/25**
//

import UIKit
import Combine
import SVProgressHUD

final class AddCreditsViewController: UIViewController, UITextFieldDelegate {
  
  // MARK: – Dependências
  private let creditService: CreditService = CreditServiceLegacyAdapter()
  private let checkoutModel = CheckoutDataModel.sharedInstance()
  private let dataModel = DataModel.getInstance()
  
  // MARK: – State / Combine
  private var cancellables = Set<AnyCancellable>()
  @Published private var balance: Double?
  @Published private var lastPix: Pix?
  @Published private var isLoading = false
  @Published private var error: String?
  
  // MARK: – UI
  private let userNameLabel = UILabel()
  private let saldoValueLabel = UILabel()
  private let valueTextField = UITextField()
  private let generatePixButton = UIButton(type: .system)
  private let lastPixHeader = UILabel()
  private let lastPixLabel = UILabel()
  private let lastPixStatusLabel = UILabel()
  private let copyPixButton = UIButton(type: .system)
  
  // MARK: – Formatter BRL
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
    view.backgroundColor = .secondarySystemBackground
    
    buildLayout()
    bindState()
    observeLegacyNotifications()
    loadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    SVProgressHUD.dismiss()
  }
}

// MARK: – Networking
private extension AddCreditsViewController {
  
  func loadData() {
    Task { @MainActor in
      isLoading = true
      do {
        balance = try await creditService.fetchBalance()
        fetchLastPix()
        isLoading = false
      } catch {
        self.error = error.localizedDescription
        isLoading = false
      }
    }
  }
  
  func fetchLastPix() { checkoutModel?.getLastPix() }
}

// MARK: – Combine bindings
private extension AddCreditsViewController {
  
  func bindState() {
    // Saldo
    $balance
      .compactMap { $0 }
      .sink { [weak self] value in
        self?.saldoValueLabel.text =
        self?.brlFormatter.string(from: value as NSNumber)
      }
      .store(in: &cancellables)
    
    // Último Pix
    $lastPix
      .compactMap { $0 }
      .sink { [weak self] pix in
        guard let self else { return }
        
        lastPixLabel.text = "Valor: \(brlFormatter.string(from: pix.valor as NSDecimalNumber) ?? "--")"
        lastPixStatusLabel.text = "Situação: \(pix.situacao)"
        
        // habilita só se estiver em aberto
        let emAberto = pix.situacao == "Em aberto"
        copyPixButton.isEnabled = emAberto
        copyPixButton.alpha = emAberto ? 1 : 0.5
      }
      .store(in: &cancellables)
    
    // Loading
    $isLoading
      .sink { loading in
        loading ? SVProgressHUD.show() : SVProgressHUD.dismiss()
      }
      .store(in: &cancellables)
    
    // Erro
    $error
      .compactMap { $0 }
      .sink { [weak self] msg in self?.showAlert(msg) }
      .store(in: &cancellables)
  }
}

// MARK: – Bridge Obj-C
private extension AddCreditsViewController {
  
  func observeLegacyNotifications() {
    
    let nc = NotificationCenter.default
    
    nc.publisher(for: .init("DidReceiveCredits"))
      .sink { [weak self] _ in
        if let txt = self?.dataModel?.ruCardCredit?
          .replacingOccurrences(of: ",", with: "."),
           let v = Double(txt) {
          self?.balance = v
        }
      }
      .store(in: &cancellables)
    
    nc.publisher(for: .init("DidReceiveLastPix"))
      .sink { [weak self] _ in
        guard let dict = self?.checkoutModel?.pix as? [String: Any] else { return }
        self?.lastPix = Pix(bridging: VMPix.model(with: dict))
      }
      .store(in: &cancellables)
    
    nc.publisher(for: .init("DidCreatePix"))
      .sink { [weak self] _ in
        SVProgressHUD.dismiss()
        self?.fetchLastPix()
        self?.valueTextField.text = ""
        self?.dismissKeyboard()
        self?.presentPixModal()
      }
      .store(in: &cancellables)
    
    nc.publisher(for: .init("DidReceiveLoginError"))
      .sink { [weak self] _ in self?.presentLogin() }
      .store(in: &cancellables)
  }
  
  /// Apresenta a tela PixViewController (storyboard "Main_iPhone")
  func presentPixModal() {
    let sb = UIStoryboard(name: "Main_iPhone", bundle: nil)
    if let vc = sb.instantiateViewController(withIdentifier: "pixViewController") as? PixViewController {
      vc.modalPresentationStyle = .formSheet
      present(vc, animated: true)
    }
  }
}

// MARK: – Layout
private extension AddCreditsViewController {
  
  func buildLayout() {
    
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scroll)
    
    let stack = UIStackView()
    stack.axis  = .vertical
    stack.spacing = 24
    stack.translatesAutoresizingMaskIntoConstraints = false
    scroll.addSubview(stack)
    
    NSLayoutConstraint.activate([
      scroll.topAnchor .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scroll.bottomAnchor .constraint(equalTo: view.bottomAnchor),
      
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
    if let nome = OAuthUSP.sharedInstance().userData?["nomeUsuario"] as? String {
      userNameLabel.text = nome
    }
    
    // 2) Saldo
    let saldoCard = USPCardView()
    let saldoTitle = UILabel(text: "Saldo disponível", font: .uspRegular(ofSize: 14))
    saldoTitle.textColor = .uspAccent
    
    saldoValueLabel.font = .uspBold(ofSize: 24)
    saldoValueLabel.textColor = .uspAccent
    saldoValueLabel.text = "R$ --,--"
    
    let saldoStack = UIStackView(arrangedSubviews: [saldoTitle, saldoValueLabel])
    saldoStack.axis = .vertical
    saldoStack.alignment = .center
    saldoStack.spacing = 4
    saldoStack.pin(in: saldoCard, inset: 12)
    
    // 3) Recarga
    let recargaHeader = UILabel(text: "Recargue seu RUCard", font: .uspBold(ofSize: 20))
    recargaHeader.textColor = .uspSecondary
    
    valueTextField.borderStyle = .roundedRect
    valueTextField.keyboardType = .decimalPad
    valueTextField.placeholder = "Valor (R$)"
    valueTextField.delegate = self
    valueTextField.addTarget(self, action: #selector(maskCurrency), for: .editingChanged)
    
    generatePixButton.configuration = .filled()
    generatePixButton.configuration?.title = "Gerar código Pix"
    generatePixButton.configuration?.baseBackgroundColor = .uspPrimary
    generatePixButton.configuration?.baseForegroundColor = .white
    generatePixButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    generatePixButton.addTarget(self, action: #selector(generatePixTapped), for: .touchUpInside)
    
    let formInfo = UILabel(text: "Gere um código de pagamento via Pix para valores entre R$10,00 e R$200,00.", font: .uspRegular(ofSize: 16), lines: 0, alignment: .center)
    
    let formStack = UIStackView(arrangedSubviews: [formInfo,
                                                   valueTextField,
                                                   generatePixButton])
    formStack.axis = .vertical
    formStack.spacing = 12
    
    let formCard = USPCardView(embed: formStack, inset: 16)
    
    // 4) Último Pix
    lastPixHeader.text = "Último Pix gerado";
    lastPixHeader.font = .uspBold(ofSize: 20);
    lastPixHeader.textColor = .uspSecondary
    lastPixLabel.font = .uspRegular(ofSize: 16)
    lastPixStatusLabel.font = .uspLight(ofSize: 14);
    lastPixStatusLabel.textColor = .uspSecondary
    copyPixButton.configuration = .filled();
    copyPixButton.configuration?.title = "Copiar código Pix";
    copyPixButton.configuration?.baseBackgroundColor = .uspPrimary;
    copyPixButton.configuration?.baseForegroundColor = .white;
    copyPixButton.addTarget(self, action: #selector(copyPixTapped), for: .touchUpInside)
    let lastInfo = UIStackView(arrangedSubviews: [lastPixLabel, lastPixStatusLabel]);
    lastInfo.axis = .vertical;
    lastInfo.spacing = 4
    let lastRow = UIStackView(arrangedSubviews: [lastInfo, copyPixButton]);
    lastRow.axis = .horizontal;
    lastRow.alignment = .center;
    lastRow.distribution = .equalSpacing
    let lastCard = USPCardView(embed: lastRow, style: .outline, inset: 16)
    
    // 5) Empilha
    stack.addArrangedSubview(userNameLabel)
    stack.addArrangedSubview(saldoCard)
    stack.addArrangedSubview(recargaHeader)
    stack.addArrangedSubview(formCard)
    stack.addArrangedSubview(lastPixHeader)
    stack.addArrangedSubview(lastCard)
  }
}

// MARK: – Text-field mask “R$ …”
private extension AddCreditsViewController {
  
  /// formata enquanto digita
  @objc func maskCurrency(_ tf: UITextField) {
    // remove tudo que não é dígito
    let digits = tf.text?
      .components(separatedBy: CharacterSet.decimalDigits.inverted)
      .joined() ?? ""
    
    // converte para centavos
    let cents = Decimal(string: digits) ?? 0
    let value = cents / 100
    
    tf.text = brlFormatter.string(from: value as NSNumber)
    
    // mantém cursor no final
    let end = tf.endOfDocument
    if let range = tf.textRange(from: end, to: end) {
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

// MARK: – Actions
private extension AddCreditsViewController {
  
  @objc func generatePixTapped() {
    guard validateValueMin(10) else { return }
    
    SVProgressHUD.show()
    checkoutModel?.valorRecarga = numericText()
    checkoutModel?.createPix()
  }
  
  @objc func copyPixTapped() {
    guard let code = lastPix?.copiaCola, !code.isEmpty else { return }
    UIPasteboard.general.string = code
    SVProgressHUD.showSuccess(withStatus: "Copiado")
  }
}

// MARK: – Helpers
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
  
  func dismissKeyboard() { view.endEditing(true) }
  
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
