//
//  RegularExpression.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public struct RegularExpression {

    private let regex: NSRegularExpression

    public init(regex: NSRegularExpression) {
        self.regex = regex
    }

    public func matches(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [NSTextCheckingResult] {
        return regex.matches(in: string, options: options, range: NSRange(string.startIndex..., in: string))
    }

    public func firstMatch(
        in string: String,
        options: NSRegularExpression.MatchingOptions = [],
        subgroupPosition: Int = 0
    ) -> String? {
        guard let match = regex.firstMatch(in: string, options: options, range: NSRange(string.startIndex..., in: string)),
              let matchingRange = Range(match.range(at: subgroupPosition), in: string) else {
            return nil
        }
        return String(string[matchingRange])
    }

    public func replaceMatches(
        in string: String,
        with replacement: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> String {
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: options, range: range, withTemplate: replacement)
    }
}

extension RegularExpression: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        guard let regex = try? NSRegularExpression(pattern: value, options: []) else {
            fatalError("Invalid Regex: \(value)")
        }
        self.init(regex: regex)
    }
}
