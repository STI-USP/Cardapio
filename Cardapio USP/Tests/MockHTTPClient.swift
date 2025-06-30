////
////  MockHTTPClient.swift
////  Cardapio USP
////
////  Created by Vagner Machado on 29/05/25.
////  Copyright © 2025 USP. All rights reserved.
////
//
//import Foundation
//
//final class MockHTTPClient: HTTPClient {
//    var stubData: Data
//    init(jsonFile: String) {
//        let url = Bundle.module.url(forResource: jsonFile, withExtension: "json")!
//        self.stubData = try! Data(contentsOf: url)
//    }
//    func send<T>(_ request: URLRequest) async throws -> T where T : Decodable {
//        try JSONDecoder().decode(T.self, from: stubData)
//    }
//}
