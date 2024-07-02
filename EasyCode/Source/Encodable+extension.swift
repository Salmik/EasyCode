//
//  Encodable+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Encodable {

    func encode() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return object
        } else {
            return nil
        }
    }
}
