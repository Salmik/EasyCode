//
//  NetworkManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `NetworkManager` is a class responsible for managing network requests in your application. It provides
/// methods for making standard HTTP requests, handling multipart form data, and supports SSL pinning for enhanced security.
/// The class also includes request logging capabilities and offers both callback-based and async/await APIs.
///
public class NetworkManager: NSObject {

    public enum SessionType { case main, multipart }

    private let logger = ConsoleLogger()
    private var longPollTimer: Timer?

    /// The `URLSession` used for making network requests. It is lazily initialized with the default configuration
    /// and uses `self` as the delegate.
    private lazy var session: URLSession = {
        let confirguration = URLSessionConfiguration.default
        confirguration.waitsForConnectivity = true
        confirguration.timeoutIntervalForResource = 30
        confirguration.timeoutIntervalForRequest = 30
        return URLSession(configuration: confirguration, delegate: self, delegateQueue: .main)
    }()

    private lazy var multipartSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

    /// A boolean value that indicates whether SSL pinning is enabled. When enabled, the manager will perform SSL
    /// pinning by validating the server's SSL certificate against the certificates included in `certDataItems`.
    public var isSSLPinningEnabled = false

    /// A boolean value that determines whether network requests and responses should be logged.
    public var isNeedToLogRequests = true

    /// An array of `Data` objects representing the SSL certificates to be used for SSL pinning.
    public var certDataItems = [Data]()

    /// Initializes a new instance of `NetworkManager`.
    public override init() {}

    private func composeResponse(data: Data?, response: URLResponse?, error: Error?) -> NetworkResponseProtocol {
        guard let response = response as? HTTPURLResponse else {
            if let error = error as NSError? {
                switch error.code {
                case -999: return FailureNetworkResponse(statusCode: error.code, error: .genericError("Canceled"))
                case -1001: return FailureNetworkResponse(statusCode: error.code, error: .genericError("Timeout"))
                default: break
                }
            }
            return FailureNetworkResponse(
                statusCode: (error as? NSError)?.code ?? 1000,
                error: .genericError("unknown")
            )
        }

        guard 200..<300 ~= response.statusCode else {
            return FailureNetworkResponse(
                statusCode: response.statusCode,
                error: .serverError,
                data: data,
                headers: response.allHeaderFields
            )
        }

        return SuccessNetworkResponse(
            statusCode: response.statusCode,
            data: data,
            headers: response.allHeaderFields
        )
    }

    /// Sends an HTTP request using the specified endpoint and returns the response via a completion handler.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - retryCount: The number of retry attempts to make in case of a timeout (`NSURLErrorTimedOut`) or cancellation
    ///                 (`NSURLErrorCancelled`). Default is `1`, meaning one initial attempt plus one retry.
    ///   - retryDeadline: The delay in seconds before each retry. Default is `0` (retry immediately).
    ///   - isNeedToPerformImmediatly: A boolean value indicating whether the request should start immediately.
    ///   - completion: A closure that is called with the response object conforming to `NetworkResponseProtocol`.
    /// - Returns: The `URLSessionDataTask` for the request, or `nil` if the request could not be created.
    ///
    /// # Example
    /// ```swift
    /// networkManager.request(myEndpoint) { response in
    ///     if response.success {
    ///         print("Request succeeded")
    ///     } else {
    ///         print("Request failed with error: \(response.error?.errorMessage ?? "Unknown error")")
    ///     }
    /// }
    /// ```
    @discardableResult
    public func request(
        _ endpoint: EndPointProtocol,
        retryCount: Int = 1,
        retryDeadline: TimeInterval = 0,
        isNeedToPerformImmediatly: Bool = true,
        completion: @escaping (NetworkResponseProtocol) -> Void
    ) -> URLSessionDataTask? {
        guard let request = endpoint.makeRequest() else { return nil }

        let identifiedRequest = IdentifiedRequest(request: request)
        let row = LoggerRow(request: identifiedRequest)
        if isNeedToLogRequests {
            logger.log(request: request)
            DispatchQueue.main.async {
                NetworkGlobals.loggerViewController.insert(row: row)
            }
        }

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let manager = self else { return }

            if let response = response as? HTTPURLResponse, manager.isNeedToLogRequests {
                manager.logger.log(request: request, response: response, responseData: data, error: error)
            }

            let composedResponse = manager.composeResponse(data: data, response: response, error: error)
            if manager.isNeedToLogRequests {
                DispatchQueue.main.async {
                    NetworkGlobals.loggerViewController.update(
                        id: identifiedRequest.id,
                        response: composedResponse
                    )
                }
            }

            if let error {
                let nsError = error as NSError
                if retryCount > 0, nsError.code == -1001 || nsError.code == -999 {
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + retryDeadline) {
                        _ = manager.request(
                            endpoint,
                            retryCount: retryCount - 1,
                            retryDeadline: retryDeadline,
                            isNeedToPerformImmediatly: isNeedToPerformImmediatly,
                            completion: completion
                        )
                    }
                }
            } else {
                completion(composedResponse)
            }
        }
        if isNeedToPerformImmediatly { task.resume() }

        return task
    }

    /// Sends a multipart form-data request using the specified endpoint and multipart parameters.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - retryCount: The number of retry attempts to make in case of a timeout (`NSURLErrorTimedOut`) or cancellation
    ///                 (`NSURLErrorCancelled`). Default is `1`, meaning one initial attempt plus one retry.
    ///   - retryDeadline: The delay in seconds before each retry. Default is `0` (retry immediately).
    ///   - isNeedToPerformImmediatly: A boolean value indicating whether the request should start immediately.
    ///   - multiPartParams: An array of `MultipartFormDataParameter` representing the form data.
    ///   - completion: A closure that is called with the response object conforming to `NetworkResponseProtocol`.
    /// - Returns: The `URLSessionDataTask` for the request, or `nil` if the request could not be created.
    ///
    /// # Example
    /// ```swift
    /// let multipartParams: [MultipartFormDataParameter] = [
    ///     MultipartFormDataParameter(name: "file", fileName: "image.png", mimeType: "image/png", data: imageData)
    /// ]
    ///
    /// networkManager.multiPart(myEndpoint, with: multipartParams) { response in
    ///     if response.success {
    ///         print("Multipart request succeeded")
    ///     } else {
    ///         print("Multipart request failed with error: \(response.error?.errorMessage ?? "Unknown error")")
    ///     }
    /// }
    /// ```
    @discardableResult
    public func multiPart(
        _ endpoint: EndPointProtocol,
        retryCount: Int = 1,
        retryDeadline: TimeInterval = 0,
        isNeedToResumeImmediatly: Bool = true,
        with multiPartParams: [MultipartFormDataParameter],
        completion: @escaping (NetworkResponseProtocol) -> Void
    ) -> URLSessionDataTask? {
        guard var request = endpoint.makeRequest() else { return nil }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        for param in multiPartParams {
            data.append("\r\n--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(param.name)\"; filename=\"\(param.fileName)\"\r\n")
            data.append("Content-Type: \(param.mimeType)\r\n\r\n")
            data.append(param.data)
            data.append("\r\n")
        }
        data.append("--\(boundary)--\r\n")

        let identifiedRequest = IdentifiedRequest(request: request)
        let row = LoggerRow(request: identifiedRequest)
        if isNeedToLogRequests {
            logger.log(request: request)
            DispatchQueue.main.async {
                NetworkGlobals.loggerViewController.insert(row: row)
            }
        }

        let task = multipartSession.uploadTask(with: request, from: data) { [weak self] data, response, error in
            guard let manager = self else { return }

            if let response = response as? HTTPURLResponse, manager.isNeedToLogRequests {
               manager.logger.log(request: request, response: response, responseData: data, error: error)
            }

            let composedResponse = manager.composeResponse(data: data, response: response, error: error)
            if manager.isNeedToLogRequests {
                DispatchQueue.main.async {
                    NetworkGlobals.loggerViewController.update(
                        id: identifiedRequest.id,
                        response: composedResponse
                    )
                }
            }

            if let error {
                let nsError = error as NSError
                if retryCount > 0, nsError.code == -1001 || nsError.code == -999 {
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + retryDeadline) {
                        _ = manager.multiPart(
                            endpoint,
                            retryCount: retryCount - 1,
                            retryDeadline: retryDeadline,
                            isNeedToResumeImmediatly: isNeedToResumeImmediatly,
                            with: multiPartParams,
                            completion: completion
                        )
                    }
                }
            } else {
                completion(composedResponse)
            }
        }
        if isNeedToResumeImmediatly { task.resume() }

        return task
    }

    // MARK: - Async/await

    /// Sends an HTTP request using async/await and returns the response.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - retryCount: The number of retry attempts to make in case of a timeout (`NSURLErrorTimedOut`) or cancellation
    ///                 (`NSURLErrorCancelled`). Default is `1`, meaning one initial attempt plus one retry.
    ///   - retryDeadline: The delay in seconds before each retry. Default is `0` (retry immediately).
    /// - Returns: A `NetworkResponseProtocol` object representing the response, or `nil` if the request could not be created.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     if let response = await networkManager.request(myEndpoint) {
    ///         if response.success {
    ///             print("Async request succeeded")
    ///         } else {
    ///             print("Async request failed with error: \(response.error?.errorMessage ?? "Unknown error")")
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func request(
        _ endpoint: EndPointProtocol,
        retryCount: Int = 1,
        retryDeadline: UInt64 = 0
    ) async -> NetworkResponseProtocol? {
        guard let request = endpoint.makeRequest() else { return nil }

        var attempts = 0
        let maximumAttempts = retryCount + 1
        while attempts < maximumAttempts {
            let identifiedRequest = IdentifiedRequest(request: request)
            let row = LoggerRow(request: identifiedRequest)
            if isNeedToLogRequests {
                logger.log(request: request)
                await MainActor.run { NetworkGlobals.loggerViewController.insert(row: row) }
            }

            do {
                let (data, response) = try await session.data(for: request)
                if let response = response as? HTTPURLResponse, isNeedToLogRequests {
                    logger.log(request: request, response: response, responseData: data, error: nil)
                }
                let composedResponse = composeResponse(data: data, response: response, error: nil)
                if isNeedToLogRequests {
                    await MainActor.run {
                        NetworkGlobals.loggerViewController.update(
                            id: identifiedRequest.id,
                            response: composedResponse
                        )
                    }
                }
                return composedResponse
            } catch {
                let nsError = error as NSError
                if (nsError.code == -1001 || nsError.code == -999) && attempts < retryCount {
                    attempts += 1
                    if isNeedToLogRequests {
                        logger.log(request: request, response: nil, responseData: nil, error: error)
                        let composedResponse = composeResponse(data: nil, response: nil, error: error)
                        await MainActor.run {
                            NetworkGlobals.loggerViewController.update(
                                id: identifiedRequest.id,
                                response: composedResponse
                            )
                        }
                    }
                    if retryDeadline > 0 {
                        try? await Task.sleep(nanoseconds: retryDeadline * 1_000_000_000)
                    }
                } else {
                    if isNeedToLogRequests {
                        logger.log(request: request, response: nil, responseData: nil, error: error)
                    }
                    let composedResponse = composeResponse(data: nil, response: nil, error: error)
                    if isNeedToLogRequests {
                        await MainActor.run {
                            NetworkGlobals.loggerViewController.update(
                                id: identifiedRequest.id,
                                response: composedResponse
                            )
                        }
                    }

                    return composedResponse
                }
            }
        }

        return nil
    }

    /// Sends a multipart form-data request using async/await and returns the response.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - retryCount: The number of retry attempts to make in case of a timeout (`NSURLErrorTimedOut`) or cancellation
    ///                 (`NSURLErrorCancelled`). Default is `1`, meaning one initial attempt plus one retry.
    ///   - retryDeadline: The delay in seconds before each retry. Default is `0` (retry immediately).
    ///   - multiPartParams: An array of `MultipartFormDataParameter` representing the form data.
    /// - Returns: A `NetworkResponseProtocol` object representing the response, or `nil` if the request could not be created.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     if let response = await networkManager.multiPart(myEndpoint, with: multipartParams) {
    ///         if response.success {
    ///             print("Multipart async request succeeded")
    ///         } else {
    ///             print("Multipart async request failed with error: \(response.error?.errorMessage ?? "Unknown error")")
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func multiPart(
        _ endpoint: EndPointProtocol,
        retryCount: Int = 1,
        retryDeadline: UInt64 = 0,
        with multiPartParams: [MultipartFormDataParameter]
    ) async -> NetworkResponseProtocol? {
        guard var request = endpoint.makeRequest() else { return nil }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        for param in multiPartParams {
            data.append("\r\n--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(param.name)\"; filename=\"\(param.fileName)\"\r\n")
            data.append("Content-Type: \(param.mimeType)\r\n\r\n")
            data.append(param.data)
            data.append("\r\n")
        }
        data.append("--\(boundary)--\r\n")

        var attempts = 0
        let maximumAttempts = retryCount + 1
        while attempts < maximumAttempts {
            let identifiedRequest = IdentifiedRequest(request: request)
            let row = LoggerRow(request: identifiedRequest)
            if isNeedToLogRequests {
                logger.log(request: request)
                await MainActor.run { NetworkGlobals.loggerViewController.insert(row: row) }
            }
            do {
                let (responseData, response) = try await multipartSession.upload(for: request, from: data)
                if let response = response as? HTTPURLResponse, isNeedToLogRequests {
                    logger.log(request: request, response: response, responseData: responseData, error: nil)
                }
                let composedResponse = composeResponse(data: responseData, response: response, error: nil)
                if isNeedToLogRequests {
                    await MainActor.run {
                        NetworkGlobals.loggerViewController.update(
                            id: identifiedRequest.id,
                            response: composedResponse
                        )
                    }
                }
                return composedResponse
            } catch {
                let nsError = error as NSError
                if (nsError.code == -1001 || nsError.code == -999) && attempts < retryCount {
                    attempts += 1
                    if isNeedToLogRequests {
                        logger.log(request: request, response: nil, responseData: nil, error: error)
                        let composedResponse = composeResponse(data: nil, response: nil, error: error)
                        await MainActor.run {
                            NetworkGlobals.loggerViewController.update(
                                id: identifiedRequest.id,
                                response: composedResponse
                            )
                        }
                    }
                    if retryDeadline > 0 {
                        try? await Task.sleep(nanoseconds: retryDeadline * 1_000_000_000)
                    }
                } else {
                    if isNeedToLogRequests {
                        logger.log(request: request, response: nil, responseData: nil, error: error)
                    }
                    let composedResponse = composeResponse(data: nil, response: nil, error: error)
                    if isNeedToLogRequests {
                        await MainActor.run {
                            NetworkGlobals.loggerViewController.update(
                                id: identifiedRequest.id,
                                response: composedResponse
                            )
                        }
                    }

                    return composedResponse
                }
            }
        }

        return nil
    }

    /// Starts a long-polling process to periodically send HTTP requests to the specified endpoint.
    ///
    /// Long-polling involves repeatedly sending requests at a specified interval to fetch updated data.
    /// Use the `completion` callback to handle each response, and provide a way to stop the polling.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - interval: The time interval (in seconds) between successive requests.
    ///   - completion: A closure that gets called with each response. It provides:
    ///     - `response`: The response object conforming to `NetworkResponseProtocol`.
    ///     - `stop`: A closure to terminate the long-polling process.
    ///
    /// # Example
    /// ```swift
    /// networkManager.startLongPolling(endpoint: myEndpoint, interval: 10) { response, stop in
    ///     if response.success {
    ///         print("Long-polling succeeded with data: \(response.data ?? Data())")
    ///         stop()
    ///     } else {
    ///         print("Long-polling failed with error: \(response.error?.errorMessage ?? "Unknown error")")
    ///     }
    /// }
    /// ```
    public func startLongPolling(
        endpoint: EndPointProtocol,
        interval: TimeInterval,
        retryCount: Int = 1,
        retryDeadline: TimeInterval = 0,
        isNeedToPerformImmediatly: Bool = true,
        completion: @escaping (_ response: NetworkResponseProtocol, _ stop: @escaping () -> Void) -> Void
    ) {
        stopLongPolling()

        longPollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }

            self.request(
                endpoint,
                retryCount: retryCount,
                retryDeadline: retryDeadline,
                isNeedToPerformImmediatly: isNeedToPerformImmediatly
            ) { response in
                let stopClosure = { [weak self] in
                    guard let self else { return }
                    self.stopLongPolling()
                }
                completion(response, stopClosure)
            }
        }

        if let longPollTimer {
            RunLoop.main.add(longPollTimer, forMode: .common)
        }

        longPollTimer?.fire()
    }

    /// Stops the currently running long-polling process.
    ///
    /// Call this method to manually terminate the long-polling process.
    public func stopLongPolling() {
        longPollTimer?.invalidate()
        longPollTimer = nil
    }

    /// Sets a new `URLSession` instance for the specified session type.
    ///
    /// This method allows you to replace the session used for either `.main` or `.multipart`
    /// operations. Useful when you need a custom session configuration for specific request types.
    ///
    /// - Parameters:
    ///   - sessionType: The type of session to configure (`.main` or `.multipart`).
    ///   - session: The new `URLSession` instance to assign for the given type.
    ///
    /// Example:
    /// ```swift
    /// let customSession = URLSession(configuration: .default)
    /// setNewSession(for: .main, session: customSession)
    /// ```
    public func setNewSession(for sessionType: SessionType, session: URLSession) {
        switch sessionType {
        case .main:
            self.session = session
        case .multipart:
            multipartSession = session
        }
    }
}

// MARK: - URLSessionDelegate

extension NetworkManager: URLSessionDelegate {

    /// Handles SSL pinning by validating the server's certificate against the stored certificates.
    /// This method is called when the session receives an authentication challenge.
    /// - Parameters:
    ///   - session: The `URLSession` instance that received the challenge.
    ///   - challenge: The `URLAuthenticationChallenge` object containing the server's credentials.
    ///   - completionHandler: A closure that your handler must call, providing the disposition and credential.
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        var disposition: URLSession.AuthChallengeDisposition = isSSLPinningEnabled ? .cancelAuthenticationChallenge
                                                                                   : .performDefaultHandling
        var urlCredential: URLCredential?

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(disposition, nil)
            return
        }

        if !isSSLPinningEnabled {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let isTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        if !isTrusted {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertificateData: Data?
        if #available(iOS 15.0, *) {
            if let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
               let firstCert = certificates.first {
                serverCertificateData = SecCertificateCopyData(firstCert) as Data
            } else {
                serverCertificateData = nil
            }
        } else {
            if let firstCert = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                serverCertificateData = SecCertificateCopyData(firstCert) as Data
            } else {
                serverCertificateData = nil
            }
        }

        guard let serverCertData = serverCertificateData else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        for localCertData in certDataItems where serverCertData == localCertData {
            let credential = URLCredential(trust: serverTrust)
            disposition = .useCredential
            urlCredential = credential
            break
        }

        completionHandler(disposition, urlCredential)
    }
}
