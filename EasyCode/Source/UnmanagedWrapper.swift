//
//  UnmanagedWrapper.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

public class UnmanagedWrapper<T: AnyObject> {

    private var unmanaged: Unmanaged<T>?

    public init(_ instance: T) {
        self.unmanaged = Unmanaged.passRetained(instance)
    }

    public func getManagedInstance() -> T? {
        return unmanaged?.takeUnretainedValue()
    }

    public func toOpaque() -> UnsafeMutableRawPointer? {
        return unmanaged?.toOpaque()
    }

    public func release() {
        unmanaged?.release()
        unmanaged = nil
    }

    deinit {
        if unmanaged != nil {
            unmanaged?.release()
        }
    }
}
