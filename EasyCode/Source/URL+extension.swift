//
//  URL+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension URL {

    var sizeString: String? {
        guard let resourceValues = try? self.resourceValues(forKeys: [.fileSizeKey]),
              let fileSize = resourceValues.fileSize else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var queryParameters: [String: String]? {
        guard let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems else {
            return nil
        }
        return Dictionary(queryItems.lazy.compactMap {
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        }) { first, _ in first }
    }

    @discardableResult
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
            .map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url
    }

    @discardableResult
    func appendingQueryParameters(_ parameters: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
        return urlComponents.url
    }

    func queryValue(for key: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == key }?
            .value
    }

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

    public init(stringLiteral value: String) {
        guard let url = URL(string: value) else { fatalError("Invalid URL: \(value)") }
        self = url
    }
}
