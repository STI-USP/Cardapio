//
//  UIColor+USP.swift
//  banner
//
//  Created by Vagner Machado on 15/04/25.
//

import UIKit

extension UIColor {
  
  static let uspPrimary = UIColor(hex: "#148194")
  static let uspSecondary = UIColor(hex: "#005059")
  static let uspAccent = UIColor(hex: "#148194")
  static let uspNeutral = UIColor(hex: "#4f4645")
  static let uspLightBlue = UIColor(hex: "#64c4d2")
  static let uspDarkBlue = UIColor(hex: "#005059")
  static let uspYellow = UIColor(hex: "#FCB421")
  static let uspLightYellow = UIColor(hex: "#F3CD8D")

  static let uspSuccess = UIColor(hex: "#148194")
  static let uspWarning = UIColor(hex: "#FCB421")
  static let uspError = UIColor(hex: "#D32F2F")
  static let uspBorder = UIColor(hex: "#4f4645")
  static let uspBackgroundCard = UIColor(hex: "#F8F8F8")


  convenience init(hex: String) {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hex = hex.replacingOccurrences(of: "#", with: "")
    
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    
    let a, r, g, b: UInt64
    switch hex.count {
    case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
    case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
    default: (a, r, g, b) = (255, 0, 0, 0)
    }
    
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}
