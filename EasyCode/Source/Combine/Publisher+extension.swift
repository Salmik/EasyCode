//
//  Publisher+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation
import Combine

extension Publisher where Self.Failure == Never {

    public func assignWeak<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Self.Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
