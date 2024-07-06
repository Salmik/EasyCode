//
//  NSLayoutConstraint+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension NSLayoutConstraint {

    /// Activates the constraint.
    ///
    /// - Returns: The activated constraint.
    @discardableResult
    func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }

    /// Deactivates the constraint.
    ///
    /// - Returns: The deactivated constraint.
    @discardableResult
    func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }
}
