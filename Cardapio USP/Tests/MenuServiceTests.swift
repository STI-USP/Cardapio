////
////  MenuServiceTests.swift
////  Cardapio USP
////
////  Created by Vagner Machado on 29/05/25.
////  Copyright © 2025 USP. All rights reserved.
////
//
//import XCTest
//
//final class MenuServiceTests: XCTestCase {
//    func testFetchToday_ParsesJSON() async throws {
//        // given
//        let http = MockHTTPClient(jsonFile: "menu_stub")
//        let sut  = MenuServiceImpl(client: http)
//
//        // when
//        let menu = try await sut.fetchToday(for: "central")
//
//        // then
//        XCTAssertEqual(menu.items.first, "Arroz")
//        XCTAssertEqual(menu.period, .lunch)
//    }
//}
