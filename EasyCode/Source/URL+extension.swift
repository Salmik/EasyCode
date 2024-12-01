//
//  URL+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension URL {

    var isDirectory: Bool { (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }

    /// A computed property that returns the file size as a formatted string.
    ///
    /// - Returns: The file size as a human-readable string (e.g., "10 KB", "5 MB"), or `nil` if the size could not be determined.
    ///
    /// # Example:
    /// ``` swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/file.txt")
    /// if let sizeString = fileURL.sizeString {
    ///     print("File size: \(sizeString)")
    /// } else {
    ///     print("Failed to get file size.")
    /// }
    /// ```
    var sizeString: String? {
        guard let resourceValues = try? self.resourceValues(forKeys: [.fileSizeKey]),
              let fileSize = resourceValues.fileSize else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    /// A computed property that returns the query parameters of the URL as a dictionary.
    ///
    /// - Returns: A dictionary where the keys are parameter names and the values are parameter values, or `nil` if there are no query parameters.
    ///
    /// # Example:
    /// ``` swift
    /// let url = URL(string: "https://example.com?param1=value1&param2=value2")!
    /// if let queryParams = url.queryParameters {
    ///     print(queryParams) // ["param1": "value1", "param2": "value2"]
    /// } else {
    ///     print("No query parameters found.")
    /// }
    /// ```
    var queryParameters: [String: String]? {
        guard let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems else {
            return nil
        }
        return Dictionary(queryItems.lazy.compactMap { item in
            guard let value = item.value else { return nil }
            return (item.name, value)
        }) { first, _ in first }
    }

    /// Appends the given query parameters to the URL.
    ///
    /// - Parameter parameters: A dictionary where the keys are parameter names and the values are parameter values to append.
    /// - Returns: A new URL with the appended query parameters, or `nil` if the URL components could not be resolved.
    ///
    /// # Example:
    /// ``` swift
    /// let baseURL = URL(string: "https://example.com")!
    /// let params = ["param1": "value1", "param2": "value2"]
    /// if let newURL = baseURL.appendingQueryParameters(params) {
    ///     print(newURL) // https://example.com?param1=value1&param2=value2
    /// } else {
    ///     print("Failed to append query parameters.")
    /// }
    /// ```
    @discardableResult
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
            .map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url
    }

    /// Appends the given query parameters to the URL.
    ///
    /// - Parameter parameters: An array of `URLQueryItem` to append.
    /// - Returns: A new URL with the appended query parameters, or `nil` if the URL components could not be resolved.
    ///
    /// # Example:
    /// ``` swift
    /// let baseURL = URL(string: "https://example.com")!
    /// let queryItems = [URLQueryItem(name: "param1", value: "value1"), URLQueryItem(name: "param2", value: "value2")]
    /// if let newURL = baseURL.appendingQueryParameters(queryItems) {
    ///     print(newURL) // https://example.com?param1=value1&param2=value2
    /// } else {
    ///     print("Failed to append query parameters.")
    /// }
    /// ```
    @discardableResult
    func appendingQueryParameters(_ parameters: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
        return urlComponents.url
    }

    /// Retrieves the value of the specified query parameter.
    ///
    /// - Parameter key: The name of the query parameter.
    /// - Returns: The value of the query parameter, or `nil` if the parameter is not present.
    ///
    /// # Example:
    /// ``` swift
    /// let url = URL(string: "https://example.com?param1=value1&param2=value2")!
    /// if let value = url.queryValue(for: "param1") {
    ///     print("Value for param1: \(value)") // "Value for param1: value1"
    /// } else {
    ///     print("No value for param1 found.")
    /// }
    /// ```
    func queryValue(for key: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == key }?
            .value
    }

    /// Returns a new URL with the scheme removed.
    ///
    /// - Returns: A new URL without the scheme, or the original URL if the scheme is not present.
    ///
    /// # Example:
    /// ``` swift
    /// let url = URL(string: "https://example.com/path")!
    /// if let newURL = url.droppedScheme() {
    ///     print(newURL) // example.com/path
    /// } else {
    ///     print("Failed to drop scheme.")
    /// }
    /// ```
    func droppedScheme() -> URL? {
        if let scheme = scheme {
            let droppedScheme = String(absoluteString.dropFirst(scheme.count + 3))
            return URL(string: droppedScheme)
        }

        guard host != nil else { return self }

        let droppedScheme = String(absoluteString.dropFirst(2))
        return URL(string: droppedScheme)
    }
}

extension URL: ExpressibleByStringLiteral {

    /// Initializes a URL object with a string literal.
    ///
    /// - Parameter value: The string literal representing the URL.
    ///
    /// # Example:
    /// ``` swift
    /// let url: URL = "https://example.com"
    /// print(url) // https://example.com
    /// ```
    public init(stringLiteral value: String) {
        guard let url = URL(string: value) else { fatalError("Invalid URL: \(value)") }
        self = url
    }
}
