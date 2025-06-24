//
//  USPCardView.swift
//  Cardapio USP – Design System
//
//  Criado em 16/04/25 • Última revisão em 23/06/25
//
//  Um contêiner visual reutilizável que segue a identidade USP.
//  Oferece duas variantes: elevado (sombra) e outline (apenas borda).
//  Inclui convenience-init que já embute qualquer sub-view com padding.
//

import UIKit

/// Cartão genérico usado em várias telas (saldo, formulários, listas…).
/// Encapsula fundo, borda e, opcionalmente, elevação com sombra.
final class USPCardView: UIView {
  
  // MARK: – Estilo
  enum Style { case elevated, outline }
  
  // MARK: – Init
  /// Cartão vazio. Use quando for adicionar sub-views manualmente.
  init(style: Style = .elevated) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    configure(style: style)
  }
  
  /// Cartão que já contém `view` alinhada em todos os lados por `inset`.
  convenience init(embed view: UIView,
                   style: Style = .elevated,
                   inset: CGFloat = 12) {
    self.init(style: style)
    embed(view, inset: inset)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: – Private helpers
  private func configure(style: Style) {
    backgroundColor = .secondarySystemBackground
    layer.cornerRadius = 12
    switch style {
    case .elevated:
      layer.masksToBounds = false
      addShadow()
    case .outline:
      layer.borderWidth = 1
      layer.borderColor = UIColor.uspBorder.cgColor
    }
  }
  
  private func addShadow() {
    layer.shadowColor   = UIColor.label.withAlphaComponent(0.15).cgColor
    layer.shadowOpacity = 1
    layer.shadowRadius  = 6
    layer.shadowOffset  = CGSize(width: 0, height: 2)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    // Define shadowPath p/ rasterizar sombra estática (perf).
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
  }
}

// MARK: – Helper p/ embedar sub-view dentro do card
private extension UIView {
  func embed(_ subview: UIView, inset: CGFloat) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subview)
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
      subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
      subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
      subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
    ])
  }
}
