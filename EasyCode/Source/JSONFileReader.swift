//
//  JSONFileReader.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class JSONFileReader {

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
}
