//
//  Dictionary+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Dictionary {

    var prettyString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }

    func decode<T: Decodable>() -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let object = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return object
    }

    func subdictionary(with keys: [Key]) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for key in keys {
            if let value = self[key] {
                result[key] = value
            }
        }
        return result
    }

    func mapValues<T>(_ transform: (Value) -> T) -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            result[key] = transform(value)
        }
        return result
    }

    func compactMapValues<T>(_ transform: (Value) -> T?) -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            if let transformedValue = transform(value) {
                result[key] = transformedValue
            }
        }
        return result
    }

    func keys(forValuesMatching predicate: (Value) -> Bool) -> [Key] {
        return compactMap { key, value in
            predicate(value) ? key : nil
        }
    }

    func merge(with dictionary: [Key: Value]) -> [Key: Value] {
        var result = self
        dictionary.forEach { key, value in
            result[key] = value
        }
        return result
    }

    func filterKeys(_ isIncluded: (Key) -> Bool) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, value) in self where isIncluded(key) {
            result[key] = value
        }
        return result
    }

    func filteredValues(predicate: (Value) -> Bool) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, value) in self where predicate(value) {
            result[key] = value
        }
        return result
    }

    func toArray(filter: (Element) throws -> Bool = { _ in true }) rethrows -> [(Key, Value)] {
        return try compactMap { (key, value) in
            guard try filter((key, value)) else { return nil }
            return (key, value)
        }
    }

    func toArray() -> [(Key, Value)] { map { ($0.key, $0.value) } }

    func has(key: Key) -> Bool { index(forKey: key) != nil }
}
