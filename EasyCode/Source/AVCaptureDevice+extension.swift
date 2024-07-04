//
//  AVCaptureDevice+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import AVFoundation

public extension AVCaptureDevice {

    static func setTorchMode(_ mode: AVCaptureDevice.TorchMode) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = mode
            device.unlockForConfiguration()
        } catch {
            dump(error, name: "AVCaptureDevice")
        }
    }
}
