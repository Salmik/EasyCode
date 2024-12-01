//
//  DependencyError.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

enum DependencyError: Error, CustomDebugStringConvertible {

    case providerNotFound(type: Any.Type)

    var debugDescription: String {
        switch self {
        case .providerNotFound(let type):
            return "Нет зарегистрированного провайдера для типа \(type)"
        }
    }
}
