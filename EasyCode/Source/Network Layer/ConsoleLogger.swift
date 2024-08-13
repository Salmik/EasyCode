//
//  ConsoleLogger.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `ConsoleLogger` is a class responsible for logging network requests and responses to the console.
/// It provides detailed logging, including URLs, HTTP methods, headers, and bodies for both requests and responses.
/// The logs are formatted for readability and include timestamps, status codes, and any errors encountered.
public class ConsoleLogger {

    /// Initializes a new instance of `ConsoleLogger`.
    public init() {}

    /// A computed property that generates a separator line for log entries.
    /// This is used to visually separate different sections of the log output.
    private var separatorLine: String { [String](repeating: "☰", count: 64).joined() }

    /// Formats a title string for log sections, indicating whether the log pertains to a request or response.
    /// - Parameter token: A string that specifies the type of log (e.g., "Request", "Response").
    /// - Returns: A formatted title string for the log section.
    private func title(_ token: String) -> String { "[ Network: HTTP " + token + " ]" }

    /// Generates a detailed log string for a given `URLRequest`.
    /// - Parameter request: The `URLRequest` for which to generate the log.
    /// - Returns: A string containing the formatted log details for the request.
    private func getLog(for request: URLRequest) -> String {
        var log = ""

        if let url = request.url,
           let method = request.httpMethod {
            var urlString = url.absoluteString
            if urlString.last == "?" { urlString.removeLast() }
            log += "‣ URL: " + urlString + "\n\n"
            log += "‣ METHOD: " + method + "\n\n"
        }

        if let headerFields = request.allHTTPHeaderFields,
           !headerFields.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: headerFields),
           let jsonString = getJsonString(from: data) {
            log += "‣ REQUEST HEADERS: " + jsonString + "\n\n"
        }

        if let data = request.httpBody, !data.isEmpty {
            if let jsonString = getJsonString(from: data) {
                log += "‣ REQUEST BODY: " + jsonString + "\n\n"
            } else {
                log += "‣ REQUEST BODY (FAILED TO PRINT)\n\n"
            }
        }

        return log
    }

    /// Converts `Data` to a formatted JSON string for logging.
    /// - Parameter data: The data to be converted into a JSON string.
    /// - Returns: A formatted JSON string, or the raw data as a string if JSON conversion fails.
    private func getJsonString(from data: Data) -> String? {
        let writingOptions: JSONSerialization.WritingOptions = [
            .fragmentsAllowed,
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: writingOptions),
              let jsonString = String(data: data, encoding: .utf8) else {
            return String(data: data, encoding: .utf8)
        }

        return jsonString.replacingOccurrences(of: "\" : ", with: "\": ", options: .literal)
    }
}

public extension ConsoleLogger {

    /// Logs the details of a `URLRequest` to the console.
    /// - Parameter request: The `URLRequest` to be logged.
    func log(request: URLRequest) {
        var log = ""

        log += "\n" + separatorLine + "\n\n"
        log += title("Request ➡️") + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += getLog(for: request)
        log += separatorLine + "\n\n"

        print(log)
    }

    /// Logs the details of a `URLRequest` and its corresponding `HTTPURLResponse` to the console.
    /// Includes the status code, response headers, response body, and any errors encountered.
    /// - Parameters:
    ///   - request: The `URLRequest` that was made.
    ///   - response: The `HTTPURLResponse` received from the server.
    ///   - responseData: The data received in the response.
    ///   - error: Any error that occurred during the request or response.
    func log(request: URLRequest, response: HTTPURLResponse?, responseData: Data?, error: Error?) {
        var log = ""

        log += "\n" + separatorLine + "\n\n"
        log += title("Response ⬅️") + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"

        if let statusCode = response?.statusCode {
            let emoji: String
            if let response = response, 200..<300 ~= response.statusCode {
                emoji = "✅"
            } else {
                emoji = "⚠️"
            }
            log += "‣ STATUS CODE: " + statusCode.description + " " + emoji + "\n\n"
        }

        log += getLog(for: request)

        if let headerFields = response?.allHeaderFields,
           !headerFields.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: headerFields),
           let jsonString = getJsonString(from: data) {
            log += "‣ RESPONSE HEADERS: " + jsonString + "\n\n"
        }

        if let data = responseData, !data.isEmpty {
            if let jsonString = getJsonString(from: data) {
                log += "‣ RESPONSE BODY: " + jsonString + "\n\n"
            } else {
                log += "‣ RESPONSE BODY (FAILED TO PRINT)\n\n"
            }
        }

        if let error = error as? NetworkError {
            log += "‣ ERROR: " + error.errorMessage + "\n\n"
        } else if let error {
            log += "‣ ERROR: " + error.localizedDescription + "\n\n"
        }
        log += separatorLine + "\n\n"

        print(log)
    }
}
