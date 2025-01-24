//
//  WebSocketManagerDelegate.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 20.01.2025.
//

import Foundation

public protocol WebSocketManagerDelegate: AnyObject {

    func webSocketDidConnect()
    func webSocketDidDisconnect(code: URLSessionWebSocketTask.CloseCode?, reason: String?)
    func reconnectingPassed()
    func webSocketDidReceiveMessage(text: String)
    func webSocketDidReceiveData(_ data: Data)
    func webSocketDidReceiveError(_ error: Error)
}

extension WebSocketManagerDelegate {

    func webSocketDidConnect() {}

    func webSocketDidDisconnect(code: URLSessionWebSocketTask.CloseCode?, reason: String?) {}

    func webSocketDidReceiveMessage(text: String) {}

    func webSocketDidReceiveData(_ data: Data) {}

    func webSocketDidReceiveError(_ error: Error) {}

    func reconnectingPassed() {}
}
