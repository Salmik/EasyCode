//
//  TemporaryImageCache.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import UIKit

/// Protocol for caching images, providing subscript access to store and retrieve images by key.
public protocol ImageCache {
    subscript(_ key: String) -> UIImage? { get set }
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
public class TemporaryImageCache: ImageCache {

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    private let queue = DispatchQueue(label: "com.temporaryImageCache.queue", attributes: .concurrent)

    /// Accesses the image associated with the given key for reading and writing.
    /// - Parameter key: The key to identify the image.
    /// - Returns: The image associated with the key, or `nil` if no image exists for the key.
    public subscript(_ key: String) -> UIImage? {
        get {
            return queue.sync {
                cache.object(forKey: key as NSString)
            }
        }
        set {
            return queue.async(flags: .barrier) {
                if let newValue {
                    self.cache.setObject(newValue, forKey: key as NSString)
                } else {
                    self.cache.removeObject(forKey: key as NSString)
                }
            }
        }
    }

    public func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAllObjects()
        }
    }
}
