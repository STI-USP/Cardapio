//
//  HomeViewModel.swift
//  Cardapio USP
//
//  Created by Vagner Machado on 29/05/25.
//  Copyright © 2025 USP. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var state: HomeState?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let service: HomeService

    init(service: HomeService = HomeServiceImpl()) {
        self.service = service
        Task { await load() }
    }

    func load() async {
        isLoading = true; error = nil
        do {
            state = try await service.loadState()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
