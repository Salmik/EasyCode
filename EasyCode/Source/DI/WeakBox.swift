//
//  WeakBox.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

class WeakBox {

    weak var value: AnyObject?

    init(_ value: AnyObject) {
        self.value = value
    }
}
