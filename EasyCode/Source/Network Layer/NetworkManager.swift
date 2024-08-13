//
//  NetworkManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias Parameters = Any
public typealias MultipartFormDataParameter = (data: Data, name: String, fileName: String, mimeType: String)

/// `NetworkManager` is a class responsible for managing network requests in your application. It provides
/// methods for making standard HTTP requests, handling multipart form data, and supports SSL pinning for enhanced security.
/// The class also includes request logging capabilities and offers both callback-based and async/await APIs.
///
/// # Example
///
/// ```swift
/// import UIKit
///
/// struct Post: Codable {
///
///     let userId: Int
///     let id: Int
///     let title: String
///     let body: String
/// }
///
/// class ViewController: UIViewController {
///
///     private let performManager = PerformManager()
///
///     private let networkManager: NetworkManager = {
///         let manager = NetworkManager()
///         manager.certDataItems = Bundle.main.SSLCertificates
///         manager.isSSLPinningEnabled = false // default is false
///         manager.isNeedToLogRequests = true // default is true
///         return manager
///     }()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         view.backgroundColor = .white
///
///         // async/await
///         performManager.addTask { [weak networkManager] in
///             await networkManager?.request(JSONPlaceholderApi.getComments(id: 1))
///         }
///         performManager.addTask { [weak networkManager] in
///             let post = Post(userId: 132, id: 129, title: "Zhanibek", body: "TestBody")
///             let postRequest = await networkManager?.request(JSONPlaceholderApi.insertPost(post: post))
///
///             guard let decodedPost: Post = postRequest?.decode() else { return }
///             print(decodedPost.title)
///         }
///         performManager.addTask { [weak networkManager] in
///             guard let data = UIImage(systemName: "star")?.jpegData(compressionQuality: 1) else { return }
///
///             let arrayOfImages = [
///                 (data, "image", "image.jpg", data.mimeType),
///                 (data, "image2", "image2.jpg", data.mimeType),
///                 (data, "image3", "image3.jpg", data.mimeType)
///             ]
///             let _ = await networkManager?.multiPart(JSONPlaceholderApi.multipart, with: arrayOfImages)
///             print("Multipart")
///         }
///         performManager.performTasks(inSequence: true) {
///             print("AllTasks Done!")
///             print(Thread.current)
///         }
///
///         // default
///         networkManager.request(JSONPlaceholderApi.getComments(id: 1)) { response in
///             guard response.success else { return }
///             print("Data")
///         }
///
///         let post = Post(userId: 132, id: 129, title: "Zhanibek", body: "TestBody")
///         networkManager.request(JSONPlaceholderApi.insertPost(post: post)) { response in
///             guard response.success else { return }
///
///             if let post: Post = response.decode() {
///                 print(post.title)
///             }
///         }
///
///         if let data = UIImage(systemName: "star")?.jpegData(compressionQuality: 1) {
///             let arrayOfImages = [
///                 (data, "image", "image.jpg", data.mimeType),
///                 (data, "image2", "image2.jpg", data.mimeType),
///                 (data, "image3", "image3.jpg", data.mimeType)
///             ]
///
///             networkManager.multiPart(JSONPlaceholderApi.multipart, with: arrayOfImages) { response in
///                 guard response.success else { return }
///                 print("Data")
///             }
///         }
///     }
/// }
///
/// import Foundation
///
/// enum JSONPlaceholderApi: EndPointProtocol {
///
///     case getComments(id: Int)
///     case insertPost(post: Post)
///     case multipart
///
///     var baseURL: String {
///         switch self {
///         case .getComments, .insertPost: return "https://jsonplaceholder.typicode.com/"
///         case .multipart: return "https://httpbin.org/"
///         }
///     }
///
///     var path: String {
///         switch self {
///         case .getComments: return "comments"
///         case .insertPost: return "posts"
///         case .multipart: return "post"
///         }
///     }
///
///     var timeoutInterval: TimeInterval {
///         switch self {
///         case .getComments, .insertPost: return 30
///         case .multipart: return 60
///         }
///     }
///
///     var cachePolicy: URLRequest.CachePolicy {
///         switch self {
///         case .getComments, .insertPost: return .returnCacheDataElseLoad
///         case .multipart: return .reloadIgnoringLocalAndRemoteCacheData
///         }
///     }
///
///     var encoding: EncodingType {
///         switch self {
///         case .getComments: return .url
///         case .insertPost: return .json
///         case .multipart: return .none
///         }
///     }
///
///     var httpMethod: HTTPMethod {
///         switch self {
///         case .getComments: return .get
///         case .insertPost: return .post
///         case .multipart: return .post
///         }
///     }
///
///     var headers: HTTPHeaders? {
///         switch self {
///         case .getComments, .insertPost, .multipart: return ["Authorization": "Bearer jgjdfsgnjfdnjhl68430968904"]
///         }
///     }
///
///     var parameters: Parameters? {
///         switch self {
///         case .getComments(let id): return ["postId": id]
///         case .insertPost(let post): return encode(post)
///         case .multipart: return nil
///         }
///     }
/// }
/// ```
public class NetworkManager: NSObject {

    /// The `URLSession` used for making network requests. It is lazily initialized with the default configuration
    /// and uses `self` as the delegate.
    public lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

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
    ///   - isNeedToResumeImmediatly: A boolean value indicating whether the request should start immediately.
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
        isNeedToResumeImmediatly: Bool = true,
        completion: @escaping (NetworkResponseProtocol) -> Void
    ) -> URLSessionDataTask? {
        guard let request = endpoint.makeRequest() else { return nil }

        if isNeedToLogRequests {
            ConsoleLogger().log(request: request)
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let manager = self else { return }

            if let response = response as? HTTPURLResponse, manager.isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: response, responseData: data, error: error)
            }

            let response = manager.composeResponse(data: data, response: response, error: error)
            completion(response)
        }
        if isNeedToResumeImmediatly { task.resume() }

        return task
    }

    /// Sends a multipart form-data request using the specified endpoint and multipart parameters.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
    ///   - isNeedToResumeImmediatly: A boolean value indicating whether the request should start immediately.
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
        request.httpBody = data

        if isNeedToLogRequests {
            ConsoleLogger().log(request: request)
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let manager = self else { return }

            if let response = response as? HTTPURLResponse, manager.isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: response, responseData: data, error: error)
            }

            let response = manager.composeResponse(data: data, response: response, error: error)
            completion(response)
        }
        if isNeedToResumeImmediatly { task.resume() }

        return task
    }

    // MARK: - Async/await

    /// Sends an HTTP request using async/await and returns the response.
    ///
    /// - Parameter endpoint: An object conforming to `EndPointProtocol` that defines the request details.
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
    public func request(_ endpoint: EndPointProtocol) async -> NetworkResponseProtocol? {
        guard let request = endpoint.makeRequest() else { return nil }

        if isNeedToLogRequests {
            ConsoleLogger().log(request: request)
        }
        do {
            let (data, response) = try await session.data(for: request)
            if let response = response as? HTTPURLResponse, isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: response, responseData: data, error: nil)
            }

            let composedResponse = composeResponse(data: data, response: response, error: nil)
            return composedResponse
        } catch {
            if isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: nil, responseData: nil, error: error)
            }
            let composedResponse = composeResponse(data: nil, response: nil, error: error)
            return composedResponse
        }
    }

    /// Sends a multipart form-data request using async/await and returns the response.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `EndPointProtocol` that defines the request details.
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
        request.httpBody = data

        if isNeedToLogRequests {
            ConsoleLogger().log(request: request)
        }
        do {
            let (responseData, response) = try await session.data(for: request)
            if let response = response as? HTTPURLResponse, isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: response, responseData: responseData, error: nil)
            }
            let composedResponse = composeResponse(data: responseData, response: response, error: nil)
            return composedResponse
        } catch {
            if isNeedToLogRequests {
                ConsoleLogger().log(request: request, response: nil, responseData: nil, error: error)
            }
            let composedResponse = composeResponse(data: nil, response: nil, error: error)
            return composedResponse
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
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let manager = self else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            var disposition: URLSession.AuthChallengeDisposition = .cancelAuthenticationChallenge

            guard manager.isSSLPinningEnabled else {
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

                    for localCertData in manager.certDataItems where serverCertificateData == localCertData {
                        let credential = URLCredential(trust: serverTrust)
                        disposition = .useCredential
                        completionHandler(disposition, credential)
                        return
                    }
                }
            } else {
                let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust))
                        .compactMap { SecTrustGetCertificateAtIndex(serverTrust, $0) }
                let serverCertificateData = serverCertificates.first.map { SecCertificateCopyData($0) as Data }

                if let serverCertificateData = serverCertificateData {
                    for localCertData in manager.certDataItems where serverCertificateData == localCertData {
                        let credential = URLCredential(trust: serverTrust)
                        disposition = .useCredential
                        completionHandler(disposition, credential)
                        return
                    }
                }
            }

            completionHandler(disposition, nil)
        }
    }
}
