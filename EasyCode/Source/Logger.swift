//
//  Logger.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// Utility class for logging messages with dividers.
public class Logger {

    /// Prints a string message with dividers.
    ///
    /// - Parameter string: The string message to print.
    ///
    /// # Example:
    /// ``` swift
    /// Logger.print("Hello, world!")
    /// ```
    public class func print(_ string: String) { dividedPrint { Swift.print(string) } }

    /// Executes a block and prints its output with dividers.
    ///
    /// - Parameter block: The block to execute and print its output.
    ///
    /// # Example:
    /// ``` swift
    /// Logger.print {
    ///     print("This is inside a block.")
    /// }
    /// ```
    public class func print(_ block: () -> Void) { dividedPrint(block) }

    /// Prints a divider line.
    ///
    /// # Example:
    /// ``` swift
    /// Logger.printDivider()
    /// ```
    public class func printDivider() { Swift.print("\n" + [String](repeating: "☰", count: 64).joined() + "\n") }

    private class func dividedPrint(_ block: () -> Void) {
        printDivider()
        block()
        printDivider()
    }
}
