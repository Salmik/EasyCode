//
//  UIImage+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import CoreImage

public extension UIImage {

    var pngSizeString: String? { self.pngData()?.sizeString }

    var jpegSizeString: String? { self.jpegData(compressionQuality: 1)?.sizeString }

    /// Get resized image by keeping its aspect ratio
    ///
    /// - Parameter size: maximum size
    /// - Returns: resized image
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

    /// Get resized image
    ///
    /// - Parameter size: new image size
    /// - Returns: resized UIImage object
    func resized(to size: CGSize) -> UIImage {
        autoreleasepool {
            return UIGraphicsImageRenderer(size: size).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }

    /// Get image centered inside the transparent area with provided size;
    /// If provided width (height) is less than the original width (height) then return fitted then centered image
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

    /// Fit image for provided size then center in it so the unfilled space is transparent
    /// - Parameter size: final image size
    /// - Returns: UIImage if possible
    func fitThenCenter(in size: CGSize) -> UIImage {
        return fitted(in: size).centered(in: size)
    }

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

    /// Get pixel color
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
