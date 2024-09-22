//
//  NetworkMonitor.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = false
    static let instance: NetworkMonitor = NetworkMonitor()
    private var monitor: NWPathMonitor?
    
    private init() {
        Task { await self.start() }
    }
    
    private func start() async {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { [weak self] path in
            Task {
                let conected = path.status == .satisfied
                await self?.updateConnectionStatus(isConnected: conected)
            }
        }
    }
    private func updateConnectionStatus(isConnected: Bool) async {
        self.isConnected = isConnected
    }
    func retry() {
        monitor?.cancel()
        Task { await self.start() }
    }
    func cancelMonitoring() {
        monitor?.cancel()
    }
}
