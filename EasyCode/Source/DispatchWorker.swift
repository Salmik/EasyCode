//
//  DispatchWorker.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class DispatchWorker {

    public typealias ExecuteClosure = () -> Void
    public typealias UpdateClosure = () -> Void

    public class func execute(
        on queue: DispatchQueue,
        updateDelay milliseconds: Int? = nil,
        execute: @escaping ExecuteClosure,
        update: UpdateClosure? = nil
    ) {
        if let milliseconds {
            let delayInterval = DispatchTimeInterval.milliseconds(milliseconds)
            queue.asyncAfter(deadline: .now() + delayInterval) {
                execute()
                if let update { DispatchQueue.main.async(execute: update) }
            }
        } else {
            queue.async {
                execute()
                if let update { DispatchQueue.main.async(execute: update) }
            }
        }
    }
}
