//
//  TemporaryImageCache.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import UIKit

/// Protocol for caching images, providing subscript access to store and retrieve images by key.
public protocol ImageCache {
    subscript(_ key: NSString) -> UIImage? { get set }
}

/// Implementation of `ImageCache` using `NSCache` to temporarily store images in memory.
/// # Example:
/// ``` swift
/// let imageCache = TemporaryImageCache()
/// let sampleKey = NSString(string: "sampleImageKey")
/// let sampleImage = UIImage(named: "sampleImage")
///
/// // Store image in cache
/// imageCache[sampleKey] = sampleImage
///
/// // Retrieve image from cache
/// if let cachedImage = imageCache[sampleKey] {
///     print("Image retrieved from cache: \(cachedImage)")
/// }
///
/// // Remove image from cache
/// imageCache[sampleKey] = nil
/// if imageCache[sampleKey] == nil {
///     print("Image successfully removed from cache")
/// }
/// ```
public struct TemporaryImageCache: ImageCache {

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    /// Accesses the image associated with the given key for reading and writing.
    /// - Parameter key: The key to identify the image.
    /// - Returns: The image associated with the key, or `nil` if no image exists for the key.
    public subscript(_ key: NSString) -> UIImage? {
        get { cache.object(forKey: key) }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }
}
