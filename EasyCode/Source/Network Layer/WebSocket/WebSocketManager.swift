//
//  WebSocketManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 20.01.2025.
//

import Foundation
import Network

open class WebSocketManager: NSObject {

    public weak var delegate: WebSocketManagerDelegate?
    public private(set) var isConnected: Bool = false

    public var heartbeatInterval: TimeInterval = 15
    public var isAutoReconnectEnabled = true
    public var isNeedToLog = true
    public var isSSLPinningEnabled = false
    public var certDataItems: [Data] = []

    private var session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private var heartbeatTimer: Timer?
    private var endpoint: WebSocketEndPointProtocol?
    private var isReconnecting = false

    private var pathMonitor: NWPathMonitor?
    private var isNetworkViable = true

    public init(session: URLSession) {
        self.session = session
        super.init()
    }

    public convenience init(
        isSSLPinningEnabled: Bool = false,
        certDataItems: [Data] = Bundle.main.SSLCertificates,
        isNeedToLog: Bool = true,
        isAutoReconnectEnabled: Bool = true,
        heartbeatInterval: TimeInterval = 15
    ) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated

        let tempSession = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
        self.init(session: tempSession)

        self.isNeedToLog = isNeedToLog
        self.isAutoReconnectEnabled = isAutoReconnectEnabled
        self.heartbeatInterval = heartbeatInterval
        self.isSSLPinningEnabled = isSSLPinningEnabled
        self.certDataItems = certDataItems

        recreateSession()
    }

    private func recreateSession() {
        let config = session.configuration
        let newSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        session.invalidateAndCancel()
        self.webSocketTask = nil
        session = newSession
    }

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        guard heartbeatInterval > 0 else { return }

        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func sendPing() {
        guard let task = webSocketTask else { return }

        if isNeedToLog {
            Logger.printDivider()
            print("⚪️ PING")
            Logger.printDivider()
        }

        task.sendPing { [weak self] error in
            if let error {
                if self?.isNeedToLog == true {
                    Logger.print("🔴 PING ERROR: \(error.localizedDescription)")
                }
                self?.delegate?.webSocketDidReceiveError(error)
            } else {
                if self?.isNeedToLog == true {
                    Logger.print("⚪️ PONG (RECEIVED RESPONSE TO PING)")
                }
            }
        }
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            if self.isNeedToLog {
                Logger.printDivider()
            }

            switch result {
            case .failure(let error):
                if isNeedToLog {
                    print("🔴 WEBSOCKET RECEIVED ERROR")
                    print("➤ ERROR: \(error.localizedDescription)")
                    Logger.printDivider()
                }

                self.isConnected = false
                self.delegate?.webSocketDidReceiveError(error)

                if self.isAutoReconnectEnabled {
                    if self.isNeedToLog {
                        print("⚪️ WEBSOCKET SUGGESTS RECONNECTION")
                        Logger.printDivider()
                    }
                    self.tryReconnect()
                } else {
                    self.delegate?.webSocketDidDisconnect(
                        code: nil,
                        reason: error.localizedDescription
                    )
                }

            case .success(let message):
                if !self.isConnected {
                    self.isConnected = true
                    if self.isNeedToLog {
                        print("🟢 WEBSOCKET CONNECTED")
                        Logger.printDivider()
                    }
                    if self.isReconnecting {
                        print("🟢 WEBSOCKET RECONNECTED")
                        Logger.printDivider()
                        self.delegate?.webSocketDidConnect()
                    }
                    self.delegate?.reconnectingPassed()
                    self.isReconnecting = false
                }

                switch message {
                case .string(let text):
                    if self.isNeedToLog {
                        print("🟢 WEBSOCKET RECEIVED MESSAGE: \(text)")
                    }
                    self.delegate?.webSocketDidReceiveMessage(text: text)

                case .data(let data):
                    let base64String = data.base64EncodedString()
                    if self.isNeedToLog {
                        print("🟢 WEBSOCKET RECEIVED DATA: \(base64String)")
                    }
                    self.delegate?.webSocketDidReceiveData(data)

                @unknown default:
                    break
                }
                if self.isNeedToLog {
                    Logger.printDivider()
                }
                self.listen()
            }
        }
    }

    private func tryReconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self, let endpoint = self.endpoint else { return }
            if isNeedToLog {
                print("⚪️ RECONNECTING WEBSOCKET...")
                Logger.printDivider()
            }
            self.isReconnecting = true
            self.connect(endpoint: endpoint)
        }
    }

    private func startPathMonitor() {
        let monitor = NWPathMonitor()
        self.pathMonitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            let isViable = path.status == .satisfied
            guard let self else { return }

            if self.isNetworkViable != isViable {
                self.isNetworkViable = isViable

                if self.isNeedToLog {
                    Logger.printDivider()
                    print("⚪️ VIABILITY_CHANGED: \(isViable)")
                    Logger.printDivider()
                }
            }
        }
        let queue = DispatchQueue(label: "com.myapp.WebSocketManager.pathMonitor")
        monitor.start(queue: queue)
    }

    open func connect(endpoint: WebSocketEndPointProtocol) {
        if isNeedToLog {
            Logger.printDivider()
            print("➤ ATTEMPTING TO CONNECT TO WEBSOCKET")
        }

        self.endpoint = endpoint
        var request = URLRequest(url: endpoint.url)
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        listen()
        startHeartbeat()
        startPathMonitor()

        if isNeedToLog {
            print("➤ WEBSOCKET TASK RESUMED\n")
            Logger.printDivider()
        }
    }

    open func disconnect(code: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) {
        if isNeedToLog {
            Logger.printDivider()
            print("🔴 WEBSOCKET DISCONNECT INITIATED")
            print("➤ CODE: \(code.rawValue)")
        }
        if let reasonString = reason.flatMap({ String(data: $0, encoding: .utf8) }) {
            if isNeedToLog {
                print("➤ REASON: \(reasonString)")
            }
        }

        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        pathMonitor?.cancel()
        pathMonitor = nil

        webSocketTask?.cancel(with: code, reason: reason)
        webSocketTask = nil
        isConnected = false

        if isNeedToLog {
            Logger.print("🔴 WEBSOCKET CANCELLED\n")
        }

        delegate?.webSocketDidDisconnect(
            code: code,
            reason: reason.flatMap { String(data: $0, encoding: .utf8) }
        )
    }

    open func send(text: String) {
        guard let task = webSocketTask else { return }
        let message = URLSessionWebSocketTask.Message.string(text)

        if isNeedToLog {
            Logger.printDivider()
            print("➤ SENDING TEXT MESSAGE: \(text)")
            Logger.printDivider()
        }

        task.send(message) { [weak self] error in
            if let error {
                if self?.isNeedToLog == true {
                    Logger.print("🔴 WEBSOCKET SEND ERROR: \(error.localizedDescription)")
                }
                self?.delegate?.webSocketDidReceiveError(error)
            }
        }
    }

    open func send(data: Data) {
        guard let task = webSocketTask else { return }
        let message = URLSessionWebSocketTask.Message.data(data)

        if isNeedToLog {
            Logger.printDivider()
            print("➤ SENDING BINARY DATA, size: \(data.sizeString)")
            Logger.printDivider()
        }

        task.send(message) { [weak self] error in
            if let error {
                if self?.isNeedToLog == true {
                    Logger.print("🔴 WEBSOCKET SEND ERROR: \(error.localizedDescription)")
                }
                self?.delegate?.webSocketDidReceiveError(error)
            }
        }
    }
}

// MARK: - URLSessionDelegate (SSL Pinning)
extension WebSocketManager: URLSessionDelegate {

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard isSSLPinningEnabled else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var secError: CFError?
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, &secError)

        if #available(iOS 15.0, *) {
            if isServerTrusted,
               let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
               let serverCertificate = certificates.first {
                let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

                for localCertData in certDataItems where localCertData == serverCertificateData {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                    return
                }
            }
        } else {
            let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust))
                .compactMap { SecTrustGetCertificateAtIndex(serverTrust, $0) }
            if let firstCert = serverCertificates.first {
                let serverCertificateData = SecCertificateCopyData(firstCert) as Data
                for localCertData in certDataItems where localCertData == serverCertificateData {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                    return
                }
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
