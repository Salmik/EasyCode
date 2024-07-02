//
//  Logger.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class Logger {

    class func print(_ string: String) { dividedPrint { Swift.print(string) } }

    class func print(_ block: () -> Void) { dividedPrint(block) }

    class func printDivider() { Swift.print("\n" + [String](repeating: "☰", count: 64).joined() + "\n") }

    private class func dividedPrint(_ block: () -> Void) {
        printDivider()
        block()
        printDivider()
    }
}
