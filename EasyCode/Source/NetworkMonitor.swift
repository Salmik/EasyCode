//
//  NetworkMonitor.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Network

/// Delegate protocol for network status changes.
public protocol NetworkMonitorDelegate: AnyObject {

    /// Called when the network connection status changes.
    ///
    /// - Parameters:
    ///   - networkMonitor: The network monitor reporting the status change.
    ///   - connected: A Boolean indicating whether the network is connected.
    func networkMonitor(_ networkMonitor: NetworkMonitor, didChangeStatusTo connected: Bool)
}

/// Class for monitoring network connection status and type.
public class NetworkMonitor {

    /// Enumeration of possible connection types.
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
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
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    /// The delegate to notify about network status changes.
    public weak var delegate: NetworkMonitorDelegate?

    /// Starts monitoring the network connection.
    ///
    /// # Example:
    /// ``` swift
    /// let networkMonitor = NetworkMonitor()
    /// networkMonitor.delegate = self
    /// networkMonitor.startMonitoring()
    /// ```
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let monitor = self else { return }
            monitor.isConnected = path.status == .satisfied
            monitor.getConnectionType(path: path)
        }
        monitor.start(queue: queue)
    }

    /// Stops monitoring the network connection.
    ///
    /// # Example:
    /// ``` swift
    /// networkMonitor.stopMonitoring()
    /// ```
    public func stopMonitoring() { monitor.cancel() }
}
