//
//  WebSocketEndPointProtocol.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 20.01.2025.
//

import Foundation

public protocol WebSocketEndPointProtocol {

    var url: URL { get }
    var headers: [String: String]? { get }
}
