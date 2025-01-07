//
//  EndPointProtocol.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `EncodingType` is an enumeration that represents the different types of encoding that can be used
/// when preparing a network request.
public enum EncodingType {
    case json    // JSON encoding
    case url     // URL encoding
    case none    // No encoding
}

/// `EndPointProtocol` is a protocol that defines the essential properties and methods required to create
/// a network endpoint. It provides a blueprint for configuring the various aspects of a network request,
/// such as the URL, HTTP method, headers, parameters, and encoding.
public protocol EndPointProtocol {

    /// The base URL for the endpoint. This is the root URL that will be combined with the `path` to form the full URL.
    var baseURL: String { get }

    /// The path component of the URL that is appended to the `baseURL`.
    var path: String { get }

    /// The timeout interval for the request, in seconds.
    var timeoutInterval: TimeInterval { get }

    /// The cache policy for the request, determining how the response should be cached.
    var cachePolicy: URLRequest.CachePolicy { get }

    /// The type of encoding to be used for the request parameters (e.g., JSON, URL, or none).
    var encoding: EncodingType { get }

    /// The HTTP method to be used for the request (e.g., GET, POST).
    var httpMethod: HTTPMethod { get }

    /// The HTTP headers to be included in the request.
    var headers: HTTPHeaders? { get }

    /// The parameters to be included in the request.
    var parameters: Parameters? { get }

    /// Creates a `URLRequest` object based on the properties defined in the endpoint.
    /// - Returns: A configured `URLRequest` object, or `nil` if the URL is invalid.
    func makeRequest() -> URLRequest?
}

/// Default implementations of some methods and helper functions for `EndPointProtocol`.
public extension EndPointProtocol {

    /// Creates a `URLRequest` object based on the properties defined in the endpoint.
    /// - Returns: A configured `URLRequest` object, or `nil` if the URL is invalid.
    func makeRequest() -> URLRequest? {
        guard let url = URL(string: baseURL + path) else {
            Logger.print("Invalid URL: \(baseURL + path)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval

        // Set the request headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Encode the parameters based on the specified encoding type
        switch encoding {
        case .json:
            if let parameters = parameters {
                JSONParameterEncoder.encode(urlRequest: &request, with: parameters)
            }
        case .url:
            if let parameters = parameters {
                URLParameterEncoder.encode(urlRequest: &request, with: parameters)
            }
        case .none:
            break
        }

        return request
    }

    /// Encodes a given `Encodable` object to JSON and returns it as an `Any` type.
    /// - Parameter object: The object to encode.
    /// - Returns: The JSON-encoded object as `Any`, or `nil` if encoding fails.
    func encode<T: Encodable>(_ object: T) -> Any? {
        do {
            let data = try JSONEncoder().encode(object)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            print("Error encoding object: \(NetworkError.encodingFail.errorMessage)")
            return nil
        }
    }
}
