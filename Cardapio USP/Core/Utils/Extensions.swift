//
//  Extensions.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 13/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

// MARK: – Helper para achar ViewController
extension UIView {
  func findViewController() -> UIViewController? {
    sequence(first: self as UIResponder?) { $0?.next }
      .first { $0 is UIViewController } as? UIViewController
  }
}
