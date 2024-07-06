//
//  AVCaptureDevice+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import AVFoundation

public extension AVCaptureDevice {

    /// Sets the torch mode of the device's default video capture device.
    ///
    /// - Parameter mode: The torch mode to set. Can be `.on`, `.off`, or `.auto`.
    ///
    /// This method checks if the default video capture device has a torch and sets its mode accordingly.
    ///
    /// # Example:
    /// ``` swift
    /// // Turn the torch on
    /// AVCaptureDevice.setTorchMode(.on)
    ///
    /// // Turn the torch off
    /// AVCaptureDevice.setTorchMode(.off)
    ///
    /// // Set the torch to automatic mode
    /// AVCaptureDevice.setTorchMode(.auto)
    /// ```
    ///
    /// If the device doesn't have a torch or if the configuration fails, the method will return without changing the torch mode.
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
