//
//  NetworkMonitor.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Network
import Combine

class NetworkMonitorObservable {
    @Published var isConnected: Bool = true
    let subject = PassthroughSubject<Bool, Never>()
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.subject.sink { [weak self] value in
            self?.isConnected = value
        }.store(in: &cancellables)
    }
}

actor NetworkMonitor {
    static let instance: NetworkMonitor = NetworkMonitor()
    private var monitor: NWPathMonitor?
    static let observable: NetworkMonitorObservable = .init()
    
    private init() {
        Task { await self.start() }
    }
    
    private func start() {
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
        Self.observable.subject.send(isConnected)
    }
    func retry() {
        self.monitor?.cancel()
        self.start()
    }
    func cancelMonitoring() {
        monitor?.cancel()
    }
}
