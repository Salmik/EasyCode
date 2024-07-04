//
//  Array+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Array {

    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }

    func slice(safe range: Range<Int>) -> [Element] {
       let start = Swift.max(0, range.lowerBound)
       let end = Swift.min(range.upperBound, self.count)
       return Array(self[start..<end])
    }
}

public extension Array where Element == String? {

    func nonNilJoined(separator: String = "") -> String { compactMap { $0 }.joined(separator: separator) }
}

public extension Sequence where Element: Hashable {

    var unique: [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }

    func uniqued<T: Hashable>(on keyPath: KeyPath<Element, T>) -> [Element] {
        var set = Set<T>()
        return filter { set.insert($0[keyPath: keyPath]).inserted }
    }
}

public extension Array where Element: Hashable {

    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }

    func grouped<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    func toDictionary<T>(keyPath: KeyPath<Element, T>) -> [T: Element] {
        return Dictionary(uniqueKeysWithValues: map { ($0[keyPath: keyPath], $0) })
    }
}

public extension Array where Element: Equatable {

    @discardableResult
    mutating func updateAll(
        where condition: (Element) -> Bool,
        with update: (inout Element) -> Void
    ) -> [Element] {
        for index in indices {
            if condition(self[index]) {
                update(&self[index])
            }
        }
        return self
    }

    @discardableResult
    mutating func updateFirst(
        where condition: (Element) -> Bool,
        with update: (inout Element) -> Void
    ) -> [Element] {
        guard let index = self.firstIndex(where: condition) else { return self }
        update(&self[index])
        return self
    }
}

public extension Array where Element: Comparable {

    func min(count: Int) -> [Element]? {
        guard !self.isEmpty, count > 0 else { return nil }
        let sortedArray = self.sorted()
        return Array(sortedArray.prefix(count))
    }

    func max(count: Int) -> [Element]? {
        guard !self.isEmpty, count > 0 else { return nil }
        let sortedArray = self.sorted(by: >)
        return Array(sortedArray.prefix(count))
    }
}

public extension Array where Element: BinaryInteger {

    func mean() -> Double {
        return isEmpty ? 0 : Double(self.reduce(0, +)) / Double(self.count)
    }
}

public extension Array where Element: BinaryInteger {

    func median() -> Double {
        let sorted = self.sorted()
        if sorted.isEmpty {
            return 0
        }
        let midIndex = sorted.count / 2
        if sorted.count % 2 == 0 {
            return Double(sorted[midIndex - 1] + sorted[midIndex]) / 2.0
        } else {
            return Double(sorted[midIndex])
        }
    }
}

public extension Array where Element: Equatable {

    func indexes(of item: Element) -> [Int] {
        return self.enumerated().filter { $0.element == item }.map { $0.offset }
    }
}

public extension Array where Element == Any {

    func flattenArray() -> [Any] {
        var flattened: [Any] = []

        for element in self {
            if let subArray = element as? [Any] {
                flattened.append(contentsOf: subArray.flattenArray())
            } else {
                flattened.append(element)
            }
        }

        return flattened
    }
}
