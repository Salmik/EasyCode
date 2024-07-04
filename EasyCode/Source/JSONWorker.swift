//
//  JSONFileReader.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class JSONWorker {

    public init() {}

    public func read<T: Decodable>(fromFile fileName: String) -> T? {
        let name = fileName.drop(suffix: ".json")
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let output = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return output
    }

    public func makeJSon<T: Encodable>(from object: T) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(object)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            guard let jsonString = String(data: prettyJsonData, encoding: .utf8) else { return nil }
            return jsonString
        } catch {
            dump("Error encoding JSON: \(error.localizedDescription)", name: "JSONWorker")
            return nil
        }
    }
}
