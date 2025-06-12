//
//  Date+TodayInSaoPaulo.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 12/06/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

extension Date {
  func isTodayInSaoPaulo() -> Bool {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    
    let now = Date()
    return calendar.isDate(self.convertToSaoPaulo(), inSameDayAs: now.convertToSaoPaulo())
  }
  
  func convertToSaoPaulo() -> Date {
    let tz = TimeZone(identifier: "America/Sao_Paulo")!
    let seconds = tz.secondsFromGMT(for: self)
    return addingTimeInterval(TimeInterval(seconds))
  }
}
