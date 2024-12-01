//
//  LoggerRow.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

class LoggerRow {

    let request: IdentifiedRequest
    var response: NetworkResponseProtocol?
    let startDate: Date
    var endDate: Date?

    init(request: IdentifiedRequest) {
        self.request = request
        startDate = Date()
    }
}

extension LoggerRow {

    private func attributedHeader(key: String, value: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()

        attributedString.append(
            NSAttributedString(
                string: key + ": ",
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.blue]
            )
        )

        attributedString.append(
            NSAttributedString(
                string: value,
                attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.gray]
            )
        )

        return attributedString
    }

    private func attributedBody(string: String) -> NSAttributedString {
        let attributedString = NSAttributedString(
            string: string,
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.gray]
        )
        return attributedString
    }

    var endpoint: NSAttributedString {
        guard let url = request.request.url else { return NSAttributedString(string: "UNKNOWN") }

        return NSAttributedString(
            string: NSString.path(withComponents: url.pathComponents),
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.gray]
        )
    }

    var host: String? { request.request.url?.host }

    var status: String? {
        guard let code = response?.statusCode else { return nil }

        switch code {
        case -1001: return "🕓"
        case -999: return "🚫"
        case -1: return "🤝"
        default: return code.description
        }
    }

    var method: String? { request.request.httpMethod }

    var responseTime: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    var formattedResponseTime: String? {
        guard let responseTime = responseTime else { return nil }

        if responseTime < 1 { return Int(responseTime * 1000).description + "ms" }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.minute, .second]

        return formatter.string(from: responseTime)
    }

    var requestHeaders: [NSAttributedString]? {
        guard let headers = request.request.allHTTPHeaderFields, !headers.isEmpty else {
            return [attributedBody(string: "EMPTY")]
        }
        return headers.map { attributedHeader(key: $0.key, value: $0.value) }
    }

    var requestBody: [NSAttributedString]? {
        guard let body = request.request.httpBody else { return [attributedBody(string: "EMTPY")] }
        return [attributedBody(string: body.jsonString)]
    }

    var responseHeaders: [NSAttributedString]? {
        guard let headers = response?.headers else { return [attributedBody(string: "EMPTY")] }

        return headers.compactMap { key, value -> NSAttributedString? in
            guard let key = key as? String, let value = value as? String else { return nil }
            return attributedHeader(key: key, value: value)
        }
    }

    var responseBody: [NSAttributedString]? {
        guard let json = response?.data?.jsonString else { return [attributedBody(string: "EMTPY")] }
        return [attributedBody(string: json)]
    }
}
