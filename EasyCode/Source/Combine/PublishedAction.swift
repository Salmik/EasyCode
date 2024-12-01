//
//  PublishedAction.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation
import Combine

public struct PublishedAction<Value> {

    private var subject = PassthroughSubject<Value, Never>()
    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    public func send(_ value: Value) {
        subject.send(value)
    }

    public func send(_ value: Value = ()) where Value == Void {
        subject.send(value)
    }
}
