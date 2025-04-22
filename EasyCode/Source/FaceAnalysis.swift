//
//  FaceAnalysis.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 22.04.2025.
//

import Foundation
import UIKit.UIImage
import Vision
import CoreImage

public class FaceAnalysis {

    public init() {}

    private let context = CIContext()
    private lazy var detector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: context,
        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )

    public func isSmileDetected(in image: UIImage) -> Bool {
        guard let ciImage = CIImage(image: image), let detector else { return false }

        let options: [String: Any] = [
            CIDetectorSmile: true,
            CIDetectorImageOrientation: NSNumber(value: image.imageOrientation.rawValue)
        ]

        guard let faceFeatures = detector.features(in: ciImage, options: options) as? [CIFaceFeature],
              let faceFeature = faceFeatures.first else {
            return false
        }

        return faceFeature.hasSmile
    }

    public func areEyesOpen(in image: UIImage) -> Bool {
        guard let ciImage = CIImage(image: image), let detector else { return false }

        let options: [String: Any] = [
            CIDetectorImageOrientation: NSNumber(value: image.imageOrientation.rawValue),
            CIDetectorEyeBlink: true
        ]

        guard let faceFeatures = detector.features(in: ciImage, options: options) as? [CIFaceFeature],
              let face = faceFeatures.first else {
            return false
        }

        return !face.leftEyeClosed && !face.rightEyeClosed
    }

    open func isMouthOpen(in image: UIImage) -> Bool {
        guard let ciImage = CIImage(image: image) else { return false }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        var isMouthOpen = false

        do {
            try handler.perform([request])
            if let firstFace = request.results?.first as? VNFaceObservation,
               let landmarks = firstFace.landmarks,
               let outerLips = landmarks.outerLips {

                let maxY = outerLips.normalizedPoints.max(by: { $0.y < $1.y })?.y ?? 0
                let minY = outerLips.normalizedPoints.min(by: { $0.y < $1.y })?.y ?? 0
                let maxX = outerLips.normalizedPoints.max(by: { $0.x < $1.x })?.x ?? 0
                let minX = outerLips.normalizedPoints.min(by: { $0.x < $1.x })?.x ?? 0

                let verticalOpenAmount = maxY - minY
                let horizontalExpandAmount = maxX - minX

                let verticalThreshold: CGFloat = 0.27
                let horizontalThreshold: CGFloat = 0.2

                isMouthOpen = verticalOpenAmount > verticalThreshold && horizontalExpandAmount > horizontalThreshold
            }
        } catch {
            print("Face landmarks detection failed:", error.localizedDescription)
        }
        return isMouthOpen
    }
}
