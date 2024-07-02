//
//  Observable.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class Observable<T> {

    public typealias Listener = (T) -> Void

    public var listener: Listener?

    public var value: T {
        didSet { listener?(value) }
    }

    public func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }

    public init(_ value: T) {
        self.value = value
    }
}
