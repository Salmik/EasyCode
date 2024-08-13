//
//  Bundle+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// This extension adds functionality to the `Bundle` class to retrieve SSL certificates stored in the app's bundle.
/// The certificates can be in either `.cer` or `.crt` formats.
public extension Bundle {

    /// A computed property that returns an array of `Data` objects, each representing an SSL certificate found in the bundle.
    /// The method searches the bundle for files with the `.cer` and `.crt` extensions, loads them as `Data`, and returns them.
    var SSLCertificates: [Data] {
        var sslCertUrls: [URL] = []

        if let urls = urls(forResourcesWithExtension: "cer", subdirectory: nil) {
            sslCertUrls.append(contentsOf: urls)
        }

        if let urls = urls(forResourcesWithExtension: "crt", subdirectory: nil) {
            sslCertUrls.append(contentsOf: urls)
        }

        return sslCertUrls.compactMap { try? Data(contentsOf: $0) }
    }
}
