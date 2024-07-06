//
//  Dictionary+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Dictionary {

    /// Returns a JSON-formatted string representation of the dictionary with pretty printing.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "John", "age": 30, "city": "New York"]
    /// let prettyString = dictionary.prettyString
    /// print(prettyString)
    /// ```
    var prettyString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }

    /// Decodes the dictionary into a type `T` that conforms to `Decodable`.
    ///
    /// # Example:
    /// ``` swift
    /// let jsonDictionary = ["name": "Alice", "age": 25]
    /// struct Person: Decodable {
    ///     let name: String
    ///     let age: Int
    /// }
    /// if let person: Person = jsonDictionary.decode() {
    ///     print("Decoded Person: \(person)")
    /// }
    /// ```
    ///
    /// - Returns: An instance of type `T` decoded from the dictionary, or `nil` if decoding fails.
    func decode<T: Decodable>() -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let object = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return object
    }

    /// Returns a subdictionary containing only the entries with keys specified in the `keys` array.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let keysToExtract = ["name", "city"]
    /// let subDict = dictionary.subdictionary(with: keysToExtract)
    /// print("Subdictionary: \(subDict)")
    /// ```
    ///
    /// - Parameter keys: An array of keys to include in the subdictionary.
    /// - Returns: A subdictionary containing entries with keys from the `keys` array.
    func subdictionary(with keys: [Key]) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for key in keys {
            if let value = self[key] {
                result[key] = value
            }
        }
        return result
    }

    /// Transforms the values of the dictionary using a transformation closure.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25]
    /// let transformedDictionary = dictionary.mapValues { value in
    ///     return "\(value) - Transformed"
    /// }
    /// print("Transformed Dictionary: \(transformedDictionary)")
    /// ```
    ///
    /// - Parameter transform: A closure that transforms the value of each key-value pair.
    /// - Returns: A new dictionary with transformed values.
    func mapValues<T>(_ transform: (Value) -> T) -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            result[key] = transform(value)
        }
        return result
    }

    /// Transforms the values of the dictionary using an optional transformation closure that returns an optional value.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "salary": "5000"]
    /// let transformedDictionary = dictionary.compactMapValues { value -> Int? in
    ///     return Int(value)
    /// }
    /// print("Transformed Dictionary: \(transformedDictionary)")
    /// ```
    ///
    /// - Parameter transform: A closure that transforms the value of each key-value pair.
    /// - Returns: A new dictionary with transformed values, excluding nil transformations.
    func compactMapValues<T>(_ transform: (Value) -> T?) -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            if let transformedValue = transform(value) {
                result[key] = transformedValue
            }
        }
        return result
    }

    /// Returns an array of keys for which the corresponding values satisfy the given predicate.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let filteredKeys = dictionary.keys(forValuesMatching: { value in
    ///     return value is String
    /// })
    /// print("Filtered Keys: \(filteredKeys)")
    /// ```
    ///
    /// - Parameter predicate: A closure that takes a value as its parameter and returns a boolean indicating whether the value satisfies a condition.
    /// - Returns: An array of keys for which the corresponding values satisfy the predicate.
    func keys(forValuesMatching predicate: (Value) -> Bool) -> [Key] {
        return compactMap { key, value in
            predicate(value) ? key : nil
        }
    }

    /// Merges the dictionary with another dictionary, overwriting existing entries and adding new ones.
    ///
    /// # Example:
    /// ``` swift
    /// var dictionary1 = ["name": "Alice", "age": 25]
    /// let dictionary2 = ["city": "London", "country": "UK"]
    /// let mergedDictionary = dictionary1.merge(with: dictionary2)
    /// print("Merged Dictionary: \(mergedDictionary)")
    /// ```
    ///
    /// - Parameter dictionary: The dictionary to merge into the current dictionary.
    /// - Returns: A new dictionary containing entries from both dictionaries.
    func merge(with dictionary: [Key: Value]) -> [Key: Value] {
        var result = self
        dictionary.forEach { key, value in
            result[key] = value
        }
        return result
    }

    /// Returns a dictionary containing only the entries with keys that satisfy the given predicate.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let filteredDictionary = dictionary.filterKeys { key in
    ///     key != "age"
    /// }
    /// print("Filtered Dictionary: \(filteredDictionary)")
    /// ```
    ///
    /// - Parameter isIncluded: A closure that takes a key as its parameter and returns a boolean indicating whether the key should be included in the resulting dictionary.
    /// - Returns: A new dictionary containing only the entries with keys that satisfy the predicate.
    func filterKeys(_ isIncluded: (Key) -> Bool) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, value) in self where isIncluded(key) {
            result[key] = value
        }
        return result
    }

    /// Returns a dictionary containing only the entries with values that satisfy the given predicate.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let filteredDictionary = dictionary.filteredValues { value in
    ///     return value is String
    /// }
    /// print("Filtered Dictionary: \(filteredDictionary)")
    /// ```
    ///
    /// - Parameter predicate: A closure that takes a value as its parameter and returns a boolean indicating whether the value should be included in the resulting dictionary.
    /// - Returns: A new dictionary containing only the entries with values that satisfy the predicate.
    func filteredValues(predicate: (Value) -> Bool) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, value) in self where predicate(value) {
            result[key] = value
        }
        return result
    }

    /// Returns an array of key-value pairs that satisfy the given predicate.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let filteredArray = try? dictionary.toArray { key, value in
    ///     return value is String
    /// }
    /// print("Filtered Array: \(filteredArray ?? [])")
    /// ```
    ///
    /// - Parameter filter: A closure that takes a key-value pair as its parameter and returns a boolean indicating whether the pair should be included in the resulting array.
    /// - Returns: An array of key-value pairs that satisfy the predicate.
    func toArray(filter: (Element) throws -> Bool = { _ in true }) rethrows -> [(Key, Value)] {
        return try compactMap { (key, value) in
            guard try filter((key, value)) else { return nil }
            return (key, value)
        }
    }

    /// Returns an array of all key-value pairs in the dictionary.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25, "city": "London"]
    /// let keyValueArray = dictionary.toArray()
    /// print("Key-Value Array: \(keyValueArray)")
    /// ```
    ///
    /// - Returns: An array of all key-value pairs in the dictionary.
    func toArray() -> [(Key, Value)] { map { ($0.key, $0.value) } }

    /// Checks if the dictionary contains a specific key.
    ///
    /// # Example:
    /// ``` swift
    /// let dictionary = ["name": "Alice", "age": 25]
    /// let hasNameKey = dictionary.has(key: "name")  // true
    /// let hasCityKey = dictionary.has(key: "city")  // false
    /// ```
    ///
    /// - Parameter key: The key to check for existence in the dictionary.
    /// - Returns: `true` if the dictionary contains the key, otherwise `false`.
    func has(key: Key) -> Bool { index(forKey: key) != nil }
}
