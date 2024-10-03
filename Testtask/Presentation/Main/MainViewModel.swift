//
//  MainViewModel.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Network

final class MainViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var isNotConected: Bool = false
    var monitor: NWPathMonitor = NWPathMonitor()
    init() {
        Task { await self.start() }
    }
    func start() async {
        for await update in self.monitor {
            let conected = update.status == .satisfied
            await MainActor.run {
                self.updateIsNotConected(!conected)
            }
        }
    }
    @MainActor
    func updateIsNotConected(_ isNotConected: Bool) {
        self.isNotConected = isNotConected
    }
    func retry() {
        self.monitor.cancel()
        self.monitor = NWPathMonitor()
    }
    func cancelMonitoring() {
        monitor.cancel()
    }
    deinit {
        monitor.cancel()
    }
}
