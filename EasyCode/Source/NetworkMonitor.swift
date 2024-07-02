//
//  NetworkMonitor.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Network

public protocol NetworkMonitorDelegate: AnyObject {

    func networkMonitor(_ networkMonitor: NetworkMonitor, didChangeStatusTo connected: Bool)
}

public class NetworkMonitor {

    public enum ConnectionType {

        case wifi
        case cellular
        case enthernet
        case unknown
    }

    private let queue = DispatchQueue.global(qos: .userInteractive)
    private let monitor = NWPathMonitor()

    private var isConnected = true {
        didSet {
            guard isConnected != oldValue else { return }

            DispatchQueue.main.async { [weak self] in
                guard let monitor = self else { return }
                monitor.delegate?.networkMonitor(monitor, didChangeStatusTo: monitor.isConnected)
            }
        }
    }

    private var connectionType: ConnectionType = .unknown

    public init() {}

    private func getConnectionType(path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .enthernet
        } else {
            connectionType = .unknown
        }
    }

    public weak var delegate: NetworkMonitorDelegate?

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let monitor = self else { return }
            monitor.isConnected = path.status == .satisfied
            monitor.getConnectionType(path: path)
        }
        monitor.start(queue: queue)
    }

    public func stopMonitoring() { monitor.cancel() }
}
