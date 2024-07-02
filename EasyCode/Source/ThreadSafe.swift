//
//  ThreadSafe.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class ThreadSafe<T> {

    private var value: T
    private let lock = NSLock()

    public init(_ value: T) {
        self.value = value
    }

    public var wrappedValue: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            self.value = newValue
        }
    }

    public func modify(_ modify: (inout T) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        modify(&value)
    }

    public func read<R>(_ read: (T) -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return read(value)
    }
}
