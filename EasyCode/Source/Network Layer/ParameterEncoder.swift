//
//  ParameterEncoder.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `ParameterEncoder` is a protocol that defines a method for encoding parameters into a `URLRequest`.
/// Conforming types are responsible for encoding parameters in a specific format, such as JSON or URL-encoded.
protocol ParameterEncoder {

    /// Encodes the provided parameters into the given `URLRequest`.
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` into which the parameters will be encoded.
    ///   - parameters: The parameters to encode into the request.
    /// - Note: The method is `static`, meaning it should be called on the type itself, not an instance.
    static func encode(urlRequest: inout URLRequest, with parameters: Any)
}

/// `JSONParameterEncoder` is a struct that conforms to `ParameterEncoder` and encodes parameters as JSON.
/// This is typically used for APIs that expect request bodies in JSON format.
struct JSONParameterEncoder: ParameterEncoder {

    /// Encodes the provided parameters into the given `URLRequest` as a JSON body.
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` into which the parameters will be encoded.
    ///   - parameters: The parameters to encode into the request.
    /// - Note: The `Content-Type` header is set to `application/json` if not already specified.
    static func encode(urlRequest: inout URLRequest, with parameters: Any) {
        guard JSONSerialization.isValidJSONObject(parameters),
              let jsonAsData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            dump(NetworkError.encodingFail.errorMessage, name: urlRequest.url?.absoluteString)
            return
        }
        urlRequest.httpBody = jsonAsData
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}

/// `URLParameterEncoder` is a struct that conforms to `ParameterEncoder` and encodes parameters as URL-encoded.
/// This is typically used for APIs that expect parameters to be passed in the URL's query string.
struct URLParameterEncoder: ParameterEncoder {

    /// Encodes the provided parameters into the given `URLRequest` as URL query parameters.
    /// - Parameters:
    ///   - urlRequest: The `URLRequest` into which the parameters will be encoded.
    ///   - parameters: The parameters to encode into the request, expected to be a dictionary of key-value pairs.
    /// - Note: The `Content-Type` header is set to `application/x-www-form-urlencoded; charset=utf-8` if not already specified.
    static func encode(urlRequest: inout URLRequest, with parameters: Any) {
        guard let url = urlRequest.url, let queryParams = parameters as? [String: Any] else {
            dump(NetworkError.badUrl.errorMessage, name: urlRequest.url?.absoluteString)
            return
        }

        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !queryParams.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()

            for (key, value) in queryParams {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
