//
//  Data+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

public extension Data {

    var hexString: String { map { String(format: "%02hhx", $0) }.joined() }

    var sizeString: String { ByteCountFormatter.string(fromByteCount: Int64(self.count), countStyle: .file) }

    var jsonString: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) else {
            return String(data: self, encoding: .utf8)
        }
        return String(data: data, encoding: .utf8)
    }

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
}
