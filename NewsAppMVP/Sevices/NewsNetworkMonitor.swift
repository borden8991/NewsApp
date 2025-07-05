//
//  NewsNetworkMonitor.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 01.07.2025.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool = false

    var didBecomeReachable: (() -> Void)?

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let wasConnected = self.isConnected
                self.isConnected = path.status == .satisfied
                if self.isConnected && !wasConnected {
                    self.didBecomeReachable?()
                }
            }
        }
        monitor.start(queue: queue)
    }
}
