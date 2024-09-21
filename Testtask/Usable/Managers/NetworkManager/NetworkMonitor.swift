//
//  NetworkMonitor.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = false
    static let instance: NetworkMonitor = NetworkMonitor()
    private var monitor: NWPathMonitor?
    
    private init() {
        self.start()
    }
    
    private func start() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { [weak self] path in
            Task {
                let conected = path.status == .satisfied
                self?.isConnected = conected
            }
        }
    }
    func retry() {
        monitor?.cancel()
        self.start()
    }
    func cancelMonitoring() {
        monitor?.cancel()
    }
}
