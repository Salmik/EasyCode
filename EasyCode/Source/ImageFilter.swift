//
//  ImageFilter.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import CoreImage
import UIKit

public enum ImageFilter {

    public enum QRType {
        case string(text: String)
        case url(url: String)
    }

    case qrCode(type: QRType, scaleX: CGFloat = 4, scaleY: CGFloat = 4)
    case blur(CGFloat)
    case sepiaTone(CGFloat)
    case blackAndWhite
    case colorInvert
    case contrastAdjustment(CGFloat)
    case saturationAdjustment(CGFloat)
    case hueAdjustment(CGFloat)
    case vignetteEffect(CGFloat)
    case grainEffect(CGFloat)
    case warmTone
    case coolTone
    case motionBlur(CGFloat)

    public func apply(to inputImage: UIImage) -> UIImage? {
        switch self {
        case .qrCode(let type, let scaleX, let scaleY):
            return generateQRCode(for: type, scaleX: scaleX, scaleY: scaleY, over: inputImage)
        case .blur(let radius):
            return applyFilter(filterName: "CIGaussianBlur", parameters: ["inputRadius": radius], to: inputImage)
        case .sepiaTone(let intensity):
            return applyFilter(filterName: "CISepiaTone", parameters: ["inputIntensity": intensity], to: inputImage)
        case .blackAndWhite:
            return applyFilter(filterName: "CIPhotoEffectNoir", parameters: [:], to: inputImage)
        case .colorInvert:
            return applyFilter(filterName: "CIColorInvert", parameters: [:], to: inputImage)
        case .contrastAdjustment(let contrast):
            return applyFilter(
                filterName: "CIColorControls",
                parameters: ["inputContrast": contrast],
                to: inputImage
            )
        case .saturationAdjustment(let saturation):
            return applyFilter(
                filterName: "CIColorControls",
                parameters: ["inputSaturation": saturation],
                to: inputImage
            )
        case .hueAdjustment(let angle):
            return applyFilter(filterName: "CIHueAdjust", parameters: ["inputAngle": angle], to: inputImage)
        case .vignetteEffect(let intensity):
            return applyFilter(
                filterName: "CIVignette",
                parameters: ["inputIntensity": intensity, "inputRadius": 2],
                to: inputImage
            )
        case .grainEffect(let intensity):
            return applyFilter(
                filterName: "CIGrain",
                parameters: ["inputIntensity": intensity, "inputSharpness": 0.5],
                to: inputImage
            )
        case .warmTone:
            return applyFilter(filterName: "CIPhotoEffectTransfer", parameters: [:], to: inputImage)
        case .coolTone:
            return applyFilter(filterName: "CIPhotoEffectInstant", parameters: [:], to: inputImage)
        case .motionBlur(let intensity):
            return applyFilter(
                filterName: "CIMotionBlur",
                parameters: ["inputRadius": intensity, "inputAngle": 0],
                to: inputImage
            )
        }
    }

    private func generateQRCode(
        for type: QRType,
        scaleX: CGFloat,
        scaleY: CGFloat,
        over inputImage: UIImage
    ) -> UIImage? {
        guard let qrImage = createQRCodeImage(for: type, scaleX: scaleX, scaleY: scaleY) else { return nil }

        UIGraphicsBeginImageContext(inputImage.size)
        inputImage.draw(in: CGRect(origin: .zero, size: inputImage.size))

        let qrCodeSize = CGSize(width: inputImage.size.width / 2, height: inputImage.size.height / 2)
        let qrCodeOrigin = CGPoint(
            x: (inputImage.size.width - qrCodeSize.width) / 2,
            y: (inputImage.size.height - qrCodeSize.height) / 2
        )
        qrImage.draw(in: CGRect(origin: qrCodeOrigin, size: qrCodeSize))

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }

    private func createQRCodeImage(for type: QRType, scaleX: CGFloat, scaleY: CGFloat) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let outputData: Data

        switch type {
        case .string(let text):
            guard let data = text.data(using: String.Encoding.ascii) else { return nil }
            outputData = data
        case .url(let url):
            guard let url = URL(string: url),
                  let data = url.absoluteString.data(using: String.Encoding.ascii) else {
                return nil
            }
            outputData = data
        }
        filter.setValue(outputData, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }

    private func applyFilter(filterName: String, parameters: [String: Any], to inputImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage),
              let filter = CIFilter(name: filterName, parameters: parameters) else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let output = filter.outputImage else { return nil }
        return UIImage(ciImage: output)
    }
}
