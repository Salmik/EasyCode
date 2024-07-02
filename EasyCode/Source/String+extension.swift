//
//  String+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit
import CryptoKit

public extension String {

    private static let underscoreCharacterSet = CharacterSet(arrayLiteral: "_")
    private static let camelCasePatterns: [NSRegularExpression] = [
        "([A-Z]+)([A-Z][a-z]|[0-9])",
        "([a-z])([A-Z]|[0-9])",
        "([0-9])([A-Z])",
    ].compactMap { try? NSRegularExpression(pattern: $0, options: []) }

    var containsOnlyLetters: Bool { !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil }

    var isNumber: Bool { range(of: "^[0-9]*$", options: .regularExpression) != nil }

    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    var MD5: String {
        let hashData = Insecure.MD5.hash(data: Data(self.utf8))
        return hashData.compactMap { String(format: "%02hhx", $0) }.joined()
    }

    var SHA256: String {
        let hashData = CryptoKit.SHA256.hash(data: Data(self.utf8))
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }

    var int: Int? { Int(self) }

    var wholeRange: Range<String.Index> { startIndex ..< endIndex }

    var nsRange: NSRange { NSRange(wholeRange, in: self) }

    var snakeCaseFromCamelCase: String {
        let string = self.trimmingCharacters(in: String.underscoreCharacterSet)
        guard !string.isEmpty else { return string }

        let split = string.split(separator: "_")
        return "\(split[0])\(split.dropFirst().map { $0.capitalized }.joined())"
    }

    var camelCaseFromSnakeCase: String {
        return String.camelCasePatterns.reduce(self) { string, regex in
                regex.stringByReplacingMatches(
                    in: string,
                    options: [],
                    range: NSRange(location: 0, length: string.count),
                    withTemplate: "$1_$2"
                )
            }.lowercased()
    }

    var base64Encoded: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }

    var base64Decoded: String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }

        let remainder = count % 4
        var padding = ""

        if remainder > 0 {
            padding = String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: self + padding, options: .ignoreUnknownCharacters) else { return nil }

        return String(data: data, encoding: .utf8)
    }

    var words: [String] {
        let characterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = components(separatedBy: characterSet)
        return components.filter { !$0.isEmpty }
    }

    var isLatin: Bool {
        let latinRegex = "^[a-zA-Z.,0-9$@$!/%*?&#-_ +()|]+$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", latinRegex)
        return predicate.evaluate(with: self)
    }

    func matches(_ regex: String) -> Bool { self.range(of: regex, options: .regularExpression) != nil }

    func image(
        with size: CGSize = .init(width: 24, height: 24),
        font: UIFont = UIFont.systemFont(ofSize: 16),
        renderingMode: UIImage.RenderingMode = .alwaysTemplate
    ) -> UIImage {
        var textSize = self.size(withAttributes: [.font: font])

        if size.width < textSize.width || size.height < textSize.height { textSize = size }

        let textOrigin = CGPoint(
            x: (size.width / 2) - (textSize.width / 2),
            y: (size.height / 2) - (textSize.height / 2)
        )
        let textRect = CGRect(origin: textOrigin, size: textSize)

        let image = UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(
                in: textRect,
                withAttributes: [.font: font]
            )
        }

        return image.withRenderingMode(renderingMode)
    }

    var localized: String { NSLocalizedString(self, comment: "") }

    func decode<T: Decodable>() -> T? {
        guard let data = data(using: .utf8) else { return nil }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            dump(error)
            return nil
        }
    }

    func drop(prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    func drop(suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    static func loremIpsum(ofLength length: Int = 445) -> String {
        guard length > 0 else { return "" }

        let loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
        dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
        ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
        nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim
        id est laborum.
        """
        if loremIpsum.count > length {
            return String(loremIpsum[loremIpsum.startIndex..<loremIpsum.index(loremIpsum.startIndex, offsetBy: length)])
        }
        return loremIpsum
    }

    func capitalizingFirstLetter() -> String { prefix(1).capitalized + dropFirst() }

    func slicing(from index: Int, length: Int) -> String? {
        guard length >= 0, index >= 0, index < count else { return nil }
        guard index.advanced(by: length) <= count else { return self[safe: index..<count] }
        guard length > 0 else { return "" }
        return self[safe: index..<index.advanced(by: length)]
    }

    @discardableResult
    mutating func slice(from index: Int, length: Int) -> String {
        if let str = slicing(from: index, length: length) {
            self = String(str)
        }
        return self
    }

    @discardableResult
    mutating func truncate(toLength length: Int, trailing: String? = "...") -> String {
        guard length > 0 else { return self }
        if count > length {
            self = self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
        }
        return self
    }

    func truncated(toLength length: Int, trailing: String? = "...") -> String {
        guard 0..<count ~= length else { return self }
        return self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
    }

    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter)
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)
        let zeroDiff = versionComponents.count - otherVersionComponents.count

        if zeroDiff == 0 {
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros)
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric)
        }
    }

    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    subscript(safe range: Range<Int>) -> String? {
        let startIndex = index(
            self.startIndex,
            offsetBy: range.lowerBound,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        let endIndex = index(
            startIndex,
            offsetBy: range.upperBound - range.lowerBound,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        return String(self[startIndex..<endIndex])
    }

    subscript(safe range: ClosedRange<Int>) -> String? {
        guard range.lowerBound <= range.upperBound else { return nil }
        let startIndex = index(
            self.startIndex,
            offsetBy: range.lowerBound,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        let endIndex = index(
            startIndex,
            offsetBy: range.upperBound - range.lowerBound + 1,
            limitedBy: self.endIndex
        ) ?? self.endIndex
        return String(self[startIndex..<endIndex])
    }
}
