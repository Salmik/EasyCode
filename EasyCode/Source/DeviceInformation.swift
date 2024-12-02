//
//  DeviceInformation.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

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

    /// Is device enabled power mode
    var isLowPowerModeEnabled: Bool { ProcessInfo.processInfo.isLowPowerModeEnabled }

    // swiftlint:disable control_statement
    /// Retrieves the IP address of the device for the preferred network interfaces.
    ///
    /// This computed property returns the device's IP address as a `String`, or `nil` if the IP address cannot be determined.
    ///
    /// The method iterates over the available network interfaces on the device and checks their address families. If an interface belongs to one of the preferred network interfaces (`en0`, `en1`, `en2`, `en3`) and has an IPv4 address, the IP address is extracted and returned.
    ///
    /// - Returns: A `String` representing the IP address of the device, or `nil` if the address cannot be retrieved.
    var wifiOrEthernetIPAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr
            let preferredInterfaces = ["en0", "en1", "en2", "en3"]

            while pointer != nil {
                guard let interface = pointer?.pointee else { break }

                let addrFamily = interface.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    print("Interface name: \(name)")

                    if preferredInterfaces.contains(name) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (
                            getnameinfo(
                                interface.ifa_addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST
                            ) == 0
                        ) {
                            address = String(cString: hostname)
                            break
                        }
                    }
                }

                pointer = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        return address
    }

    /// Retrieves the IP address of the device, prioritizing mobile network interfaces (e.g., cellular) and falling back to preferred Wi-Fi/Ethernet interfaces if no mobile address is available.
    ///
    /// This computed property iterates over the available network interfaces on the device, checking for IPv4 addresses. It prioritizes interfaces with a prefix of `pdp_ip` (typically used for mobile/cellular networks). If no valid IP address is found in these interfaces, it checks the preferred Wi-Fi/Ethernet interfaces (`en0`, `en1`, `en2`, `en3`).
    ///
    /// Link-local addresses (e.g., `169.254.x.x`) are excluded to ensure the returned IP address is usable for external communication.
    ///
    /// - Returns: A `String` representing the device's IP address (mobile or preferred network), or `nil` if no valid IP address can be determined.
    var mobileOrPreferredIPAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr

            while pointer != nil {
                guard let interface = pointer?.pointee else { break }

                let addrFamily = interface.ifa_addr.pointee.sa_family
                let name = String(cString: interface.ifa_name)

                if addrFamily == UInt8(AF_INET), name.hasPrefix("pdp_ip") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    ) == 0 {
                        let ip = String(cString: hostname)
                        if !ip.hasPrefix("169.254") {
                            address = ip
                            break
                        }
                    }
                }

                pointer = interface.ifa_next
            }

            if address == nil {
                pointer = ifaddr
                while pointer != nil {
                    guard let interface = pointer?.pointee else { break }

                    let addrFamily = interface.ifa_addr.pointee.sa_family
                    let name = String(cString: interface.ifa_name)

                    if addrFamily == UInt8(AF_INET), name.hasPrefix("en") {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(
                            interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST
                        ) == 0 {
                            let ip = String(cString: hostname)
                            if !ip.hasPrefix("169.254") {
                                address = ip
                                break
                            }
                        }
                    }

                    pointer = interface.ifa_next
                }
            }

            freeifaddrs(ifaddr)
        }

        return address ?? ""
    }

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
