//
//  MainViewModel.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import Combine
import Network

@MainActor
class MainViewModel: ObservableObject {
    @Published var isNotConected: Bool = false
    var cancellables: Set<AnyCancellable> = []
    let monitor: NWPathMonitor
    init() {
        self.monitor = NWPathMonitor()
        self.start(monitor: self.monitor)
    }
    func start(monitor: NWPathMonitor) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                let conected = path.status == .satisfied
                self?.isNotConected = !conected
            }
        }
    }
    
    func retry() {
        self.monitor.cancel()
        self.start(monitor: NWPathMonitor())
    }
    func cancelMonitoring() {
        monitor.cancel()
    }
}
