//
//  NSLayoutConstraint+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension NSLayoutConstraint {

    @discardableResult
    func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }

    @discardableResult
    func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }
}
