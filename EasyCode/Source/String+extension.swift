//
//  String+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit
import CryptoKit
import NaturalLanguage

public extension String {

    private static let underscoreCharacterSet = CharacterSet(arrayLiteral: "_")
    private static let camelCasePatterns: [NSRegularExpression] = [
        "([A-Z]+)([A-Z][a-z]|[0-9])",
        "([a-z])([A-Z]|[0-9])",
        "([0-9])([A-Z])",
    ].compactMap { try? NSRegularExpression(pattern: $0, options: []) }


    /// Checks if the string contains only letters.
    /// # Example:
    /// ``` swift
    /// "HelloWorld".containsOnlyLetters` -> `true`
    /// ```
    var containsOnlyLetters: Bool { !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil }

    /// Checks if the string is a number.
    /// # Example:
    /// ``` swift
    /// "12345".isNumber` -> `true`
    /// ```
    var isNumber: Bool { range(of: "^[0-9]*$", options: .regularExpression) != nil }

    /// Converts the string to a NSAttributedString.
    /// #Example:
    /// ``` swift
    ///  let attributedString = "Hello".attributed
    ///  ```
    var attributed: NSAttributedString { NSAttributedString(string: self) }

    /// Checks if the string has content, i.e., is not empty.
    /// #Example:
    /// ``` swift
    /// " ".hasContent -> false
    /// ```
    var hasContent: Bool { !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Checks if the string is a valid email address.
    /// # Example:
    /// ``` swift
    /// "example@test.com".isValidEmail` -> `true`
    /// ```
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    /// Computes the MD5 hash of the string.
    /// # Example: 
    /// ``` swift
    /// "Hello".MD5` -> "8b1a9953c4611296a827abf8c47804d7"
    /// ```
    var MD5: String {
        let hashData = Insecure.MD5.hash(data: Data(self.utf8))
        return hashData.compactMap { String(format: "%02hhx", $0) }.joined()
    }

    /// Computes the SHA256 hash of the string.
    /// # Example:
    /// ``` swift
    /// "Hello".SHA256` -> "185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"
    /// ```
    var SHA256: String {
        let hashData = CryptoKit.SHA256.hash(data: Data(self.utf8))
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Converts the string to an integer.
    /// # Example:
    /// ``` swift
    /// "123".int` -> `123`
    /// ```
    var int: Int? { Int(self) }

    /// Returns the full range of the string.
    /// # Example:
    /// ``` swift
    /// "Hello".wholeRange` -> `0..<5`
    /// ```
    var wholeRange: Range<String.Index> { startIndex ..< endIndex }

    /// Returns the NSRange of the string.
    /// # Example:
    /// ``` swift
    /// "Hello".nsRange` -> `NSRange(location: 0, length: 5)`
    /// ```
    var nsRange: NSRange { NSRange(wholeRange, in: self) }

    /// Converts camelCase string to snake_case.
    /// # Example:
    /// ``` swift
    /// "helloWorld".snakeCaseFromCamelCase` -> `"hello_world"`
    /// ```
    var snakeCaseFromCamelCase: String {
        let string = self.trimmingCharacters(in: String.underscoreCharacterSet)
        guard !string.isEmpty else { return string }

        let split = string.split(separator: "_")
        return "\(split[0])\(split.dropFirst().map { $0.capitalized }.joined())"
    }

    /// Converts snake_case string to camelCase.
    /// # Example:
    /// ``` swift
    /// "hello_world".camelCaseFromSnakeCase` -> `"helloWorld"`
    /// ```
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

    /// Encodes the string to Base64.
    /// # Example:
    /// ``` swift
    /// "Hello".base64Encoded` -> `"SGVsbG8="`
    /// ```
    var base64Encoded: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }

    /// Decodes the Base64 encoded string.
    /// # Example: `
    /// ``` swift
    /// "SGVsbG8=".base64Decoded` -> `"Hello"`
    /// ```
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

    /// Splits the string into an array of words.
    /// # Example:
    /// ``` swift
    /// "Hello world!".words` -> `["Hello", "world"]`
    /// ```
    var words: [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = self
        return tokenizer.tokens(for: self.startIndex..<self.endIndex).map { String(self[$0]) }
    }

    /// Detects the dominant language of the string.
    /// # Example:
    /// ``` swift
    /// "Bonjour".language` -> `.french`
    /// ```
    var language: NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        return recognizer.dominantLanguage
    }

    /// Detects the probable languages of the string with confidence scores.
    /// # Example:
    /// ``` swift
    /// "Hello".languages` -> `[.english: 1.0]`
    /// ```
    var languages: [NLLanguage: Double] {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        return recognizer.languageHypotheses(withMaximum: 5)
    }

    /// Checks if the string contains only Latin characters.
    /// # Example:
    /// ``` swift
    /// "Hello".isLatin` -> `true`
    /// ```
    var isLatin: Bool {
        let latinRegex = "^[a-zA-Z.,0-9$@$!/%*?&#-_ +()|]+$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", latinRegex)
        return predicate.evaluate(with: self)
    }

    /// Localizes the string using NSLocalizedString.
    /// # Example:
    /// ``` swift
    /// "hello".localized`
    /// ```
    var localized: String { NSLocalizedString(self, comment: "") }

    /// Checks if the string matches the given regular expression.
    /// # Example:
    /// ``` swift
    /// "123".matches("\\d{3}")` -> `true`
    /// ```
    func matches(_ regex: String) -> Bool { self.range(of: regex, options: .regularExpression) != nil }

    /// Creates an image from the string with specified attributes.
    /// - Parameters:
    ///   - size: The size of the image.
    ///   - font: The font used for the text.
    ///   - renderingMode: The rendering mode of the image.
    /// - Returns: An image containing the string.
    /// # Example: 
    /// ``` swift
    /// "A".image(with: CGSize(width: 50, height: 50), font: UIFont.systemFont(ofSize: 20))`
    /// ```
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

    /// Decodes the string to a specified Decodable type.
    /// - Returns: The decoded object or nil if decoding fails.
    /// # Example:
    /// ``` swift
    /// "{\"name\":\"John\"}".decode() as User?`
    /// ```
    func decode<T: Decodable>() -> T? {
        guard let data = data(using: .utf8) else { return nil }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            dump(error)
            return nil
        }
    }

    /// Drops the specified prefix from the string.
    /// # Example:
    /// ``` swift
    /// "HelloWorld".drop(prefix: "Hello")` -> `"World"`
    /// ```
    func drop(prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// Drops the specified suffix from the string.
    /// # Example:
    /// ``` swift
    /// "HelloWorld".drop(suffix: "World")` -> `"Hello"`
    /// ```
    func drop(suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    /// Generates a Lorem Ipsum string of specified length.
    /// - Parameter length: The desired length of the string.
    /// - Returns: A Lorem Ipsum string of the specified length.
    /// # Example:
    /// ``` swift
    /// String.loremIpsum(ofLength: 100) -> "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor inci"
    /// ```
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

    /// Capitalizes the first letter of the string.
    /// # Example:
    /// ``` swift
    /// "hello".capitalizingFirstLetter() -> "Hello"
    /// ```
    func capitalizingFirstLetter() -> String { prefix(1).capitalized + dropFirst() }

    /// Slices the string from a given index with a specified length.
    /// - Parameters:
    ///   - index: The starting index.
    ///   - length: The length of the slice.
    /// - Returns: The sliced string or nil if out of bounds.
    /// # Example:
    /// ``` swift
    /// "Hello".slicing(from: 1, length: 3) -> "ell"
    /// ```
    func slicing(from index: Int, length: Int) -> String? {
        guard length >= 0, index >= 0, index < count else { return nil }
        guard index.advanced(by: length) <= count else { return self[safe: index..<count] }
        guard length > 0 else { return nil }
        return self[safe: index..<index.advanced(by: length)]
    }

    /// Slices the string from a given index with a specified length and updates the original string.
    /// - Parameters:
    ///   - index: The starting index.
    ///   - length: The length of the slice.
    /// - Returns: The sliced string.
    /// # Example:
    /// ``` swift
    /// "Hello".slice(from: 1, length: 3) -> "ell"
    /// ```
    @discardableResult
    mutating func slice(from index: Int, length: Int) -> String {
        if let str = slicing(from: index, length: length) {
            self = String(str)
        }
        return self
    }

    /// Truncates the string to a specified length and adds a trailing string if provided.
    /// - Parameters:
    ///   - length: The desired length.
    ///   - trailing: The trailing string to append if truncated.
    /// - Returns: The truncated string.
    /// # Example:
    /// ``` swift
    /// "Hello, World".truncate(toLength: 5)` -> "Hello..."
    /// ```
    @discardableResult
    mutating func truncate(toLength length: Int, trailing: String? = "...") -> String {
        guard length > 0 else { return self }
        if count > length {
            self = self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
        }
        return self
    }

    /// Returns a truncated version of the string to a specified length with an optional trailing string.
    /// - Parameters:
    ///   - length: The desired length.
    ///   - trailing: The trailing string to append if truncated.
    /// - Returns: The truncated string.
    /// # Example:
    /// ``` swift
    /// "Hello, World".truncated(toLength: 5) -> "Hello..."
    /// ```
    func truncated(toLength length: Int, trailing: String? = "...") -> String {
        guard 0..<count ~= length else { return self }
        return self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
    }

    /// Compares the string version with another version.
    /// - Parameter otherVersion: The version to compare with.
    /// - Returns: The comparison result.
    /// # Example:
    /// ``` swift
    /// "1.0.0".versionCompare("1.0.1") -> .orderedAscending
    /// ```
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

    /// Safe subscript to get a character at the specified index.
    /// - Parameter index: The index of the character.
    /// - Returns: The character at the specified index or nil if out of bounds.
    /// # Example:
    /// ``` swift
    /// "Hello"[safe: 1] -> "e"
    /// ```
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Safe subscript to get a substring within the specified range.
    /// - Parameter range: The range of the substring.
    /// - Returns: The substring or nil if out of bounds.
    /// # Example:
    /// ``` swift
    /// "Hello"[safe: 1..<4] -> "ell"
    /// ```
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

    /// Safe subscript to get a substring within the specified closed range.
    /// - Parameter range: The closed range of the substring.
    /// - Returns: The substring or nil if out of bounds.
    /// # Example:
    /// ``` swift
    /// "Hello"[safe: 1...3] -> "ell"
    /// ```
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
