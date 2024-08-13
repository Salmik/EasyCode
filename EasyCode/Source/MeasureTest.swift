//
//  MeasureTest.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import QuartzCore

/// Utility class for measuring execution time of closures.
public class MeasureTest {

    /// Measures the execution time of a closure and prints the elapsed time.
    ///
    /// - Parameter closure: The closure to measure.
    ///
    /// # Example:
    /// ``` swift
    /// MeasureTest.measureTime {
    ///     for _ in 1...1_000_000 {
    ///         // Some expensive operation
    ///     }
    /// }
    /// ```
    public class func measureTime(closure: () -> Void) {
        let start = CACurrentMediaTime()
        closure()
        let end = CACurrentMediaTime()
        let elapsedTime = end - start
        Logger.print("Execution time: \(elapsedTime) seconds")
    }
}
