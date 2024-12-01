//
//  PublishedProperty.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation
import Combine

@propertyWrapper
public struct PublishedProperty<Value> {

    private let subject = PassthroughSubject<Value, Never>()
    public var wrappedValue: Value {
        didSet { subject.send(wrappedValue) }
    }

    public var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    public init(wrappedValue: Value = ()) where Value == Void {
        self.wrappedValue = wrappedValue
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
