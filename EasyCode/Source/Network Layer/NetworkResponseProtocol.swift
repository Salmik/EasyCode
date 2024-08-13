//
//  NetworkResponseProtocol.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `NetworkResponseProtocol` is a protocol that defines the structure of a network response.
/// It includes properties for checking the success of the response, the status code, the data received,
/// any errors encountered, and the headers associated with the response.
public protocol NetworkResponseProtocol {

    /// A Boolean value indicating whether the request was successful.
    /// Success is determined based on the status code, which should be in the range 200..<300.
    var success: Bool { get }

    /// The HTTP status code returned by the network request.
    var statusCode: Int { get }

    /// The data received from the network request, if any.
    var data: Data? { get }

    /// An error object representing any issues encountered during the network request.
    var error: NetworkError? { get }

    /// A dictionary of headers associated with the network response.
    var headers: [AnyHashable: Any]? { get }
}

/// Provides default implementations of some useful properties and methods for `NetworkResponseProtocol`.
public extension NetworkResponseProtocol {

    /// A Boolean value indicating whether the request was successful.
    /// The success is determined by checking if the status code is within the range 200..<300.
    var success: Bool { 200..<300 ~= statusCode }

    /// Attempts to decode the response data into a JSON object.
    /// - Returns: A dictionary representation of the JSON data, or `nil` if decoding fails.
    var json: [String: Any]? {
        guard let data = data,
              let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return result
    }

    /// Converts the response data into a UTF-8 encoded string.
    /// - Returns: A string representation of the data, or `nil` if the conversion fails.
    var string: String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Attempts to decode the response data into a specified `Decodable` type.
    /// - Returns: An instance of the specified type, or `nil` if decoding fails.
    func decode<T: Decodable>() -> T? {
        guard let data = data else { return nil }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            dump(error, name: "NetworkResponse")
            return nil
        }
    }
}

/// `FailureNetworkResponse` is a concrete implementation of `NetworkResponseProtocol` that represents a failed network response.
struct FailureNetworkResponse: NetworkResponseProtocol {

    /// The HTTP status code returned by the network request.
    var statusCode: Int

    /// The data received from the network request, if any.
    var data: Data?

    /// An error object representing any issues encountered during the network request.
    var error: NetworkError?

    /// A dictionary of headers associated with the network response.
    var headers: [AnyHashable: Any]?

    /// Initializes a new instance of `FailureNetworkResponse`.
    /// - Parameters:
    ///   - statusCode: The HTTP status code of the response.
    ///   - error: The error encountered during the request.
    ///   - data: The data received from the network request, if any.
    ///   - headers: A dictionary of headers associated with the network response, if any.
    init(
        statusCode: Int,
        error: NetworkError,
        data: Data? = nil,
        headers: [AnyHashable: Any]? = nil
    ) {
        self.statusCode = statusCode
        self.error = error
        self.data = data
        self.headers = headers
    }
}

/// `SuccessNetworkResponse` is a concrete implementation of `NetworkResponseProtocol` that represents a successful network response.
struct SuccessNetworkResponse: NetworkResponseProtocol {

    /// The HTTP status code returned by the network request.
    var statusCode: Int

    /// The data received from the network request, if any.
    var data: Data?

    /// An error object representing any issues encountered during the network request.
    var error: NetworkError?

    /// A dictionary of headers associated with the network response.
    var headers: [AnyHashable: Any]?

    /// Initializes a new instance of `SuccessNetworkResponse`.
    /// - Parameters:
    ///   - statusCode: The HTTP status code of the response.
    ///   - error: An optional error encountered during the request.
    ///   - data: The data received from the network request, if any.
    ///   - headers: A dictionary of headers associated with the network response, if any.
    init(
        statusCode: Int,
        error: NetworkError? = nil,
        data: Data? = nil,
        headers: [AnyHashable: Any]? = nil
    ) {
        self.statusCode = statusCode
        self.error = error
        self.data = data
        self.headers = headers
    }
}
