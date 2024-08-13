//
//  NetworkError.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `NetworkError` is an enumeration that defines various errors that can occur during network operations.
/// Each case represents a specific type of error that might be encountered while making network requests or handling their responses.
public enum NetworkError: Error {

    /// The URL provided for the request is not valid.
    case badUrl

    /// A server-side error occurred.
    case serverError

    /// The HTTP response received is not as expected (e.g., status code is not in the 200-299 range).
    case badResponse

    /// No data was received in the response.
    case noData

    /// An error occurred while parsing the response data.
    case parseError

    /// The request sent to the server was invalid (e.g., missing parameters, incorrect format).
    case badRequest

    /// A generic error occurred with a custom message.
    case genericError(String)

    /// The parameters provided for the request were `nil`.
    case parametersNil

    /// An error occurred while encoding parameters (e.g., JSON encoding failed).
    case encodingFail

    /// The user has unauthorized access to location services.
    case unauthorizedLocationAccess

    /// An error occurred while attempting to copy a file.
    case copyError

    /// A computed property that provides a user-friendly error message for each error case.
    var errorMessage: String {
        switch self {
        case .badUrl:
            return "URL is not valid"
        case .serverError:
            return "Server Error"
        case .badResponse:
            return "Bad HTTP response"
        case .noData:
            return "No data found"
        case .parseError:
            return "Parsing Error"
        case .badRequest:
            return "Bad Request"
        case .genericError(let message):
            return message
        case .parametersNil:
            return "Parameters were nil."
        case .encodingFail:
            return "Parameter encoding fail."
        case .unauthorizedLocationAccess:
            return "Unauthorized Location Access"
        case .copyError:
            return "Unable to copy file"
        }
    }
}
