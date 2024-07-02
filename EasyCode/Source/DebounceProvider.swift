//
//  DebounceProvider.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class DebounceProvider<T> {

    public typealias UpdateClosure = (_ object: T) -> Void
    public typealias DebounceClosure = () -> Void

    public static func debounce(
        milliseconds: Int,
        queue: DispatchQueue,
        performWhileDebounce: @escaping DebounceClosure = {},
        update: @escaping UpdateClosure
    ) -> UpdateClosure {

        var lastFireTime = DispatchTime.now()
        let dispatchDelayInterval = DispatchTimeInterval.milliseconds(milliseconds)

        return { object in

            lastFireTime = DispatchTime.now()
            let dispatchTime = DispatchTime.now() + dispatchDelayInterval
            queue.asyncAfter(deadline: dispatchTime) {
                let interval = lastFireTime + dispatchDelayInterval
                let presentTime = DispatchTime.now()
                performWhileDebounce()
                if presentTime.rawValue >= interval.rawValue {
                    update(object)
                }
            }
        }
    }
}

