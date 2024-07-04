//
//  DeviceInformation.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import UIKit

public protocol DeviceInformation {}

public extension DeviceInformation {

    var appName: String? { Bundle.main.infoDictionary?["CFBundleName"] as? String }

    var appVersion: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }

    var buildNumber: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }

    var deviceId: String? { UIDevice.current.identifierForVendor?.uuidString }

    var systemVersionString: String { UIDevice.current.systemVersion }

    var systemNameString: String { UIDevice.current.systemName }

    var deviceModel: String { UIDevice.current.model }

    var deviceLocalizedModel: String { UIDevice.current.localizedModel }

    var deviceName: String { UIDevice.current.name }

    var batteryLevel: Float { UIDevice.current.batteryLevel }

    var isBatteryMonitoringEnabled: Bool {
        get { UIDevice.current.isBatteryMonitoringEnabled }
        set { UIDevice.current.isBatteryMonitoringEnabled = newValue }
    }

    var isMultitaskingSupported: Bool { UIDevice.current.isMultitaskingSupported }

    var preferredLanguage: String { Locale.preferredLanguages.first ?? "Unknown" }

    var totalDiskSpace: String? {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            if let space = attributes[FileAttributeKey.systemSize] as? NSNumber {
                return ByteCountFormatter.string(fromByteCount: space.int64Value, countStyle: .file)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }

    var freeDiskSpace: String? {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            if let space = attributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return ByteCountFormatter.string(fromByteCount: space.int64Value, countStyle: .file)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
}
