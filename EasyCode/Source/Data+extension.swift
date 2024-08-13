//
//  Data+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

/// Extension providing additional functionality to the `Data` type.
public extension Data {

    var dictionary: [String: Any]? {
        return try? JSONSerialization.jsonObject(with: self) as? [String: Any]
    }

    /// Converts the data to a hexadecimal string representation.
    var hexString: String { map { String(format: "%02hhx", $0) }.joined() }

    /// Converts the size of the data to a human-readable string representation.
    var sizeString: String { ByteCountFormatter.string(fromByteCount: Int64(self.count), countStyle: .file) }

    /// Converts the data to a JSON formatted string, if possible.
    var jsonString: String {
        let writingOptions: JSONSerialization.WritingOptions = [
            .fragmentsAllowed,
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self)
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: writingOptions)
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            return jsonString.replacingOccurrences(of: "\" : ", with: "\": ", options: .literal)
        } catch {
            dump(error)
            return ""
        }
    }

    /// Determines the MIME type of the data based on its initial byte.
    var mimeType: String {
        var buffer = UInt8(0)
        copyBytes(to: &buffer, count: 1)

        switch buffer {
        case 0xFF: return "image/jpeg"
        case 0x89: return "image/png"
        case 0x47: return "image/gif"
        case 0x49, 0x4D: return "image/tiff"
        case 0x25: return "application/pdf"
        case 0xD0: return "application/vnd"
        case 0x46: return "text/plain"
        default: return "application/octet-stream"
        }
    }

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
