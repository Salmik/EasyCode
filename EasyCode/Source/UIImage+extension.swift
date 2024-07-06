//
//  UIImage+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import CoreImage

public extension UIImage {

    /// Returns the size string of the image in PNG format.
    var pngSizeString: String? { self.pngData()?.sizeString }

    /// Returns the size string of the image in JPEG format.
    var jpegSizeString: String? { self.jpegData(compressionQuality: 1)?.sizeString }

    /// Resizes the image while maintaining its aspect ratio to fit within a maximum size.
    ///
    /// - Parameter size: The maximum size to fit the image.
    /// - Returns: The resized UIImage object.
    ///
    /// # Example:
    /// ``` swift
    /// let resizedImage = originalImage.fitted(in: CGSize(width: 300, height: 200))
    /// ```
    /// This resizes `originalImage` to fit within a size of 300x200 while maintaining aspect ratio.
    func fitted(in size: CGSize) -> UIImage {
        let newSize: CGSize
        let aspectRatio = self.size.width / self.size.height

        if aspectRatio < 1 {
            let width = size.height * aspectRatio
            if width > size.width {
                let newHeight = size.width / aspectRatio
                newSize = CGSize(width: size.width, height: newHeight)
            } else {
                newSize = CGSize(width: width, height: size.height)
            }
        } else {
            let height = size.width / aspectRatio
            if height > size.height {
                let newWidth = size.height * aspectRatio
                newSize = CGSize(width: newWidth, height: size.height)
            } else {
                newSize = CGSize(width: size.width, height: height)
            }
        }

        return resized(to: newSize)
    }

    /// Resizes the image to the specified size.
    ///
    /// - Parameter size: The new size for the image.
    /// - Returns: The resized UIImage object.
    ///
    /// # Example:
    /// ``` swift
    /// let resizedImage = originalImage.resized(to: CGSize(width: 800, height: 600))
    /// ```
    /// This resizes `originalImage` to a new size of 800x600.
    func resized(to size: CGSize) -> UIImage {
        autoreleasepool {
            return UIGraphicsImageRenderer(size: size).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }

    /// Centers the image inside a transparent area of the provided size.
    ///
    /// - Parameter size: The size of the transparent area.
    /// - Returns: The centered UIImage object.
    ///
    /// # Example:
    /// ``` swift
    /// let centeredImage = originalImage.centered(in: CGSize(width: 500, height: 500))
    /// ```
    /// This centers `originalImage` inside a size of 500x500, maintaining transparency.
    func centered(in size: CGSize) -> UIImage {
        if size.width < self.size.width || size.height < self.size.height {
            return fitThenCenter(in: size)
        }

        let result = autoreleasepool {
            return UIGraphicsImageRenderer(size: size).image { _ in
                let origin = CGPoint(x: (size.width - self.size.width) / 2, y: (size.height - self.size.height) / 2)
                draw(at: origin)
            }
        }

        return result
    }

    /// Fits the image to the provided size and centers it within, maintaining transparency.
    ///
    /// - Parameter size: The final size for the image.
    /// - Returns: The UIImage object if possible.
    ///
    /// # Example:
    /// ``` swift
    /// let fittedAndCenteredImage = originalImage.fitThenCenter(in: CGSize(width: 600, height: 400))
    /// ```
    /// This fits `originalImage` within 600x400 and centers it, preserving transparency.
    func fitThenCenter(in size: CGSize) -> UIImage {
        return fitted(in: size).centered(in: size)
    }

    /// Applies a Core Image filter to the image.
    ///
    /// - Parameter filter: The name of the Core Image filter to apply.
    /// - Returns: The filtered UIImage object if successful, otherwise `nil`.
    ///
    /// # Example:
    /// ``` swift
    /// let filteredImage = originalImage.addFilter(filter: "CIColorControls")
    /// ```
    /// This applies the "CIColorControls" filter to `originalImage`.
    func addFilter(filter : String) -> UIImage? {
        guard let filter = CIFilter(name: filter),
              let ciInput = CIImage(image: self) else {
            return nil
        }
        let ciContext = CIContext()
        filter.setValue(ciInput, forKey: "inputImage")

        guard let ciOutput = filter.outputImage,
              let cgImage = ciContext.createCGImage(ciOutput, from: (ciOutput.extent)) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    /// Retrieves the UIColor of the pixel at the specified coordinates in the image.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate of the pixel.
    ///   - y: The y-coordinate of the pixel.
    /// - Returns: The UIColor of the pixel at the specified coordinates, or `nil` if out of bounds.
    ///
    /// # Example:
    /// ``` swift
    /// if let pixelColor = image[x: 100, y: 200] {
    ///     print("Pixel color at (100, 200): \(pixelColor)")
    /// }
    /// ```
    /// This retrieves the color of the pixel at coordinates (100, 200) in `image`.
    subscript (x x: Int, y y: Int) -> UIColor? {
        let width = Int(size.width)
        guard x >= 0 && x < width && y >= 0 && y < Int(size.height),
              let cgImage = cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }

        let index = 4 * (width * y + x)

        let r = CGFloat(bytes[index]) / 255
        let g = CGFloat(bytes[index + 1]) / 255
        let b = CGFloat(bytes[index + 2]) / 255
        let a = CGFloat(bytes[index + 3]) / 255

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
