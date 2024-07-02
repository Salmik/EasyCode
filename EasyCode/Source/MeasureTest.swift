//
//  MeasureTest.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import QuartzCore

public class MeasureTest {

    public class func measureTime(closure: () -> Void) {
        let start = CACurrentMediaTime()
        closure()
        let end = CACurrentMediaTime()
        let elapsedTime = end - start
        print("Execution time: \(elapsedTime) seconds")
    }
}
