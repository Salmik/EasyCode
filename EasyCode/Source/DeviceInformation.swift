//
//  DeviceInformation.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import UIKit

public protocol DeviceInformation {}

public extension DeviceInformation {

    /// The name of the application.
    var appName: String? { Bundle.main.infoDictionary?["CFBundleName"] as? String }

    /// The version of the application.
    var appVersion: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }

    /// The build number of the application.
    var buildNumber: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }

    /// The unique identifier for the device.
    var deviceId: String? { UIDevice.current.identifierForVendor?.uuidString }

    /// The current system version of the device.
    var systemVersionString: String { UIDevice.current.systemVersion }

    /// The name of the operating system.
    var systemNameString: String { UIDevice.current.systemName }

    /// The model of the device.
    var deviceModel: String { UIDevice.current.model }

    /// The localized model of the device.
    var deviceLocalizedModel: String { UIDevice.current.localizedModel }

    /// The name of the device.
    var deviceName: String { UIDevice.current.name }

    /// The current battery level of the device.
    var batteryLevel: Float { UIDevice.current.batteryLevel }

    /// Indicates whether battery monitoring is enabled on the device.
    var isBatteryMonitoringEnabled: Bool {
        get { UIDevice.current.isBatteryMonitoringEnabled }
        set { UIDevice.current.isBatteryMonitoringEnabled = newValue }
    }

    /// Indicates whether multitasking is supported on the device.
    var isMultitaskingSupported: Bool { UIDevice.current.isMultitaskingSupported }

    /// The preferred language of the device.
    var preferredLanguage: String { Locale.preferredLanguages.first ?? "Unknown" }

    /// The total disk space available on the device.
    var totalDiskSpace: String? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = attributes[FileAttributeKey.systemSize] as? NSNumber else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: space.int64Value, countStyle: .file)
    }

    /// The free disk space available on the device.
    var freeDiskSpace: String? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = attributes[FileAttributeKey.systemFreeSize] as? NSNumber else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: space.int64Value, countStyle: .file)
    }
}
