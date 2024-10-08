//
//  JSONFileReader.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A utility class for working with JSON data.
public class JSONWorker {

    public init() {}

    /// Reads JSON data from a file and decodes it into a specified type.
    ///
    /// - Parameters:
    ///   - fileName: The name of the JSON file (without the extension).
    /// - Returns: An instance of type `T` decoded from the JSON file, or `nil` if decoding fails.
    ///
    /// # Example:
    /// ``` swift
    /// let worker = JSONWorker()
    /// if let user: User = worker.read(fromFile: "user") {
    ///     print("User loaded: \(user)")
    /// } else {
    ///     print("Failed to load user data.")
    /// }
    /// ```
    public func read<T: Decodable>(fromFile fileName: String) -> T? {
        let name = fileName.drop(suffix: ".json")
        do {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else { return nil }

            let data = try Data(contentsOf: url)
            let output = try JSONDecoder().decode(T.self, from: data)
            return output
        } catch {
            dump(error, name: "JSONWorker")
            return nil
        }
    }

    /// Converts an encodable object into a JSON string.
    ///
    /// - Parameter object: The object to convert into JSON.
    /// - Returns: A JSON string representation of the object, or `nil` if encoding fails.
    ///
    /// # Example:
    /// ``` swift
    /// let worker = JSONWorker()
    /// let user = User(name: "John", age: 30)
    /// let jsonString = worker.makeJSon(from: user)
    /// print("JSON string: \(jsonString)")
    /// ```
    public func makeJSon<T: Encodable>(from object: T) -> String {
        let writingOptions: JSONSerialization.WritingOptions = [
            .fragmentsAllowed,
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        do {
            let jsonData = try JSONEncoder().encode(object)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: writingOptions)
            let jsonString = String(data: prettyJsonData, encoding: .utf8) ?? ""
            return jsonString.replacingOccurrences(of: "\" : ", with: "\": ", options: .literal)
        } catch {
            dump(error, name: "JSONWorker")
            return ""
        }
    }
}
