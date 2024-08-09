//
//  Array+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    ///
    /// - Parameter index: The index of the element.
    /// - Returns: The element at the specified index or nil if the index is out of bounds.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 3]
    /// print(array[safe: 1]) // Optional(2)
    /// print(array[safe: 3]) // nil
    /// ```
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }

    /// Returns a slice of the array within the specified range, ensuring the range is within bounds.
    ///
    /// - Parameter range: The range of elements to include in the slice.
    /// - Returns: An array containing the elements in the specified range.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 3, 4, 5]
    /// print(array.slice(safe: 1..<4)) // [2, 3, 4]
    /// print(array.slice(safe: 3..<10)) // [4, 5]
    /// ```
    func slice(safe range: Range<Int>) -> [Element] {
        let start = Swift.max(0, range.lowerBound)
        let end = Swift.min(range.upperBound, self.count)
        return Array(self[start..<end])
    }
}

public extension Array where Element == String? {

    /// Joins non-nil elements of the array into a single string, separated by the given separator.
    ///
    /// - Parameter separator: A string to insert between each of the elements in the resulting string.
    /// - Returns: A single string with the non-nil elements joined by the separator.
    ///
    /// # Example:
    /// ``` swift
    /// let array: [String?] = ["hello", nil, "world"]
    /// print(array.nonNilJoined(separator: ", ")) // "hello, world"
    /// ```
    func nonNilJoined(separator: String = "") -> String { compactMap { $0 }.joined(separator: separator) }
}

public extension Sequence where Element: Hashable {

    /// Returns an array of unique elements, preserving their original order.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 2, 3, 1]
    /// print(array.unique) // [1, 2, 3]
    /// ```
    var unique: [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }

    /// Returns an array of elements with unique values for the specified key path, preserving their original order.
    ///
    /// - Parameter keyPath: A key path to the value used for uniqueness.
    /// - Returns: An array of elements with unique values for the key path.
    ///
    /// # Example:
    /// ``` swift
    /// struct Person { let id: Int, name: String }
    /// let array = [Person(id: 1, name: "Alice"), Person(id: 2, name: "Bob"), Person(id: 1, name: "Alice")]
    /// print(array.uniqued(on: \.id)) // [Person(id: 1, name: "Alice"), Person(id: 2, name: "Bob")]
    /// ```
    func uniqued<T: Hashable>(on keyPath: KeyPath<Element, T>) -> [Element] {
        var set = Set<T>()
        return filter { set.insert($0[keyPath: keyPath]).inserted }
    }
}

public extension Array where Element: Hashable {

    /// Returns an array of elements that are in either the current array or the other array, but not both.
    ///
    /// - Parameter other: Another array to compare with.
    /// - Returns: An array of elements that are in either array but not both.
    ///
    /// # Example:
    /// ``` swift
    /// let array1 = [1, 2, 3]
    /// let array2 = [3, 4, 5]
    /// print(array1.difference(from: array2)) // [1, 2, 4, 5]
    /// ```
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }

    /// Groups the elements of the array by the specified key path.
    ///
    /// - Parameter keyPath: A key path to the value to group by.
    /// - Returns: A dictionary with the values of the key path as keys and arrays of elements as values.
    ///
    /// # Example:
    /// ``` swift
    /// struct Person { let age: Int, name: String }
    /// let array = [Person(age: 30, name: "Alice"), Person(age: 40, name: "Bob"), Person(age: 30, name: "Charlie")]
    /// print(array.grouped(by: \.age)) // [30: [Person(age: 30, name: "Alice"), Person(age: 30, name: "Charlie")], 40: [Person(age: 40, name: "Bob")]]
    /// ```
    func grouped<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    /// Converts the array to a dictionary using the specified key path as the key.
    ///
    /// - Parameter keyPath: A key path to the value to use as the key.
    /// - Returns: A dictionary with the values of the key path as keys and elements as values.
    ///
    /// # Example:
    /// ``` swift
    /// struct Person { let id: Int, name: String }
    /// let array = [Person(id: 1, name: "Alice"), Person(id: 2, name: "Bob")]
    /// print(array.toDictionary(keyPath: \.id)) // [1: Person(id: 1, name: "Alice"), 2: Person(id: 2, name: "Bob")]
    /// ```
    func toDictionary<T>(keyPath: KeyPath<Element, T>) -> [T: Element] {
        return Dictionary(uniqueKeysWithValues: map { ($0[keyPath: keyPath], $0) })
    }
}

public extension Array where Element: Equatable {

    /// Updates all elements that satisfy the given condition with the specified update.
    ///
    /// - Parameters:
    ///   - condition: A closure that takes an element and returns a Boolean value indicating whether the element should be updated.
    ///   - update: A closure that takes an element and updates it.
    /// - Returns: The updated array.
    ///
    /// # Example:
    /// ``` swift
    /// var array = [1, 2, 3, 4]
    /// array.updateAll(where: { $0 % 2 == 0 }, with: { $0 *= 2 })
    /// print(array) // [1, 4, 3, 8]
    /// ```
    @discardableResult
    mutating func updateAll(
        where condition: (Element) -> Bool,
        with update: (inout Element) -> Void
    ) -> [Element] {
        for index in indices where condition(self[index]) {
            update(&self[index])
        }
        return self
    }

    /// Updates the first element that satisfies the given condition with the specified update.
    ///
    /// - Parameters:
    ///   - condition: A closure that takes an element and returns a Boolean value indicating whether the element should be updated.
    ///   - update: A closure that takes an element and updates it.
    /// - Returns: The updated array.
    ///
    /// # Example:
    /// ``` swift
    /// var array = [1, 2, 3, 4]
    /// array.updateFirst(where: { $0 % 2 == 0 }, with: { $0 *= 2 })
    /// print(array) // [1, 4, 3, 4]
    /// ```
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

    /// Returns an array containing the smallest elements of the array up to the specified count.
    ///
    /// - Parameter count: The maximum number of elements to return.
    /// - Returns: An array of the smallest elements or nil if the array is empty or count is non-positive.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [5, 3, 1, 4, 2]
    /// print(array.min(count: 3)) // Optional([1, 2, 3])
    /// ```
    func min(count: Int) -> [Element]? {
        guard !self.isEmpty, count > 0 else { return nil }
        let sortedArray = self.sorted()
        return Array(sortedArray.prefix(count))
    }

    /// Returns an array containing the largest elements of the array up to the specified count.
    ///
    /// - Parameter count: The maximum number of elements to return.
    /// - Returns: An array of the largest elements or nil if the array is empty or count is non-positive.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [5, 3, 1, 4, 2]
    /// print(array.max(count: 3)) // Optional([5, 4, 3])
    /// ```
    func max(count: Int) -> [Element]? {
        guard !self.isEmpty, count > 0 else { return nil }
        let sortedArray = self.sorted(by: >)
        return Array(sortedArray.prefix(count))
    }
}

public extension Array where Element: BinaryInteger {

    /// Returns the mean (average) of the elements in the array.
    ///
    /// - Returns: The mean of the elements or 0 if the array is empty.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 3, 4, 5]
    /// print(array.mean()) // 3.0
    /// ```
    func mean() -> Double {
        return isEmpty ? 0 : Double(self.reduce(0, +)) / Double(self.count)
    }

    /// Returns the median of the elements in the array.
    ///
    /// - Returns: The median of the elements or 0 if the array is empty.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 3, 4, 5]
    /// print(array.median()) // 3.0
    /// ```
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

    /// Returns an array of indexes for all occurrences of the specified element.
    ///
    /// - Parameter item: The element to search for.
    /// - Returns: An array of indexes for all occurrences of the element.
    ///
    /// # Example:
    /// ``` swift
    /// let array = [1, 2, 3, 1, 2, 3]
    /// print(array.indexes(of: 2)) // [1, 4]
    /// ```
    func indexes(of item: Element) -> [Int] {
        return self.enumerated().filter { $0.element == item }.map { $0.offset }
    }
}

public extension Array where Element == Any {

    /// Flattens a nested array of elements into a single array.
    ///
    /// - Returns: A flattened array.
    ///
    /// # Example:
    /// ``` swift
    /// let array: [Any] = [1, [2, 3], [4, [5, 6]]]
    /// print(array.flattenArray()) // [1, 2, 3, 4, 5, 6]
    /// ```
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
