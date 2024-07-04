//
//  TemporaryImageCache.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import UIKit

public protocol ImageCache {
    subscript(_ key: NSString) -> UIImage? { get set }
}

public struct TemporaryImageCache: ImageCache {

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    public subscript(_ key: NSString) -> UIImage? {
        get { cache.object(forKey: key) }
        set {
            if let newValue {
                cache.setObject(newValue, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }
}
