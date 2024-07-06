//
//  Encodable+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Encodable {

    /// Encodes the object into a dictionary representation.
    ///
    /// № Example:
    /// ``` swift
    /// struct Person: Encodable {
    ///     var name: String
    ///     var age: Int
    /// }
    ///
    /// let person = Person(name: "Alice", age: 30)
    /// if let encoded = person.encode() {
    ///     print("Encoded object:", encoded)
    /// } else {
    ///     print("Encoding failed.")
    /// }
    /// ```
    ///
    /// - Returns: A dictionary representation of the encoded object, or `nil` if encoding fails.
    func encode() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return object
        } else {
            return nil
        }
    }
}
