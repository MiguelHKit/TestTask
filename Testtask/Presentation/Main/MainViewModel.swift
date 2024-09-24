//
//  MainViewModel.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var isNotConected: Bool = false
    private var monitoringTask: Task<Void, Never>?
    var cancellables: Set<AnyCancellable> = []
    init() {
        NetworkMonitor.observable.$isConnected
            .receive(on: RunLoop.main)
            .map { !$0 } //convert isConected to isNotConected
            .assign(to: \.isNotConected, on: self)
            .store(in: &cancellables)
    }
    func retry() {
        Task {
            await NetworkMonitor.instance.retry()            
        }
    }
}
