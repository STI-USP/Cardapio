//
//  RestaurantDTO.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Foundation

struct RestaurantDTO: Decodable {
  let id: String
  let name: String
  let address: String
  let phones: PhoneJSON
  let latitude: DoubleJSON
  let longitude: DoubleJSON
  let workinghours: WorkingHoursDTO
  let cashiers: [CashierDTO]?
  let photourl: String?
  
  func toDomain() -> Restaurant {
    Restaurant(
      id: id,
      name: name,
      address: address,
      phones: phones.values,
      latitude: latitude.double,
      longitude: longitude.double,
      workingHours: workinghours.toDomain(),
      cashiers: cashiers?.map { $0.toDomain() } ?? [],
      photoURL: photourl.flatMap(URL.init(string:))
    )
  }
}

// helper que aceita ["tel1","tel2"] OU "tel"
enum PhoneJSON: Decodable {
  case array([String]), single(String)
  
  var values: [String] {
    switch self {
    case .array(let arr): return arr
    case .single(let s):  return [s]
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let arr = try? container.decode([String].self) {
      self = .array(arr)
    } else {
      let s = try container.decode(String.self)
      self = .single(s)
    }
  }
}

enum DoubleJSON: Decodable {
  case value(Double), string(String)
  
  var double: Double {
    switch self {
    case .value(let d):   return d
    case .string(let str): return Double(str) ?? .zero
    }
  }
  
  init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if let d = try? c.decode(Double.self) { self = .value(d) }
    else { self = .string(try c.decode(String.self)) }
  }
}
