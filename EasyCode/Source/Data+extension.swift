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

    var json: String? {
        if let jsonObject = try? JSONSerialization.jsonObject(with: self),
           let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
            return String(data: data, encoding: .utf8)
        }
        return String(data: self, encoding: .utf8)
    }

    var printableJsonString: String? {
        guard var json else { return nil }

        let specials = [("\\/", "/"), ("\\t", "\t"), ("\\n", "\n"), ("\\r", "\r"), ("\\\"", "\""), ("\\\'", "\'")]
        for special in specials {
            json = json.replacingOccurrences(of: special.0, with: special.1, options: .literal)
        }
        json = json.replacingOccurrences(of: "\" : ", with: "\": ", options: .literal)

        return json
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
        case 0x00:
            if count >= 12 {
                let subdata = self.subdata(in: 4..<12)
                let headerString = String(data: subdata, encoding: .ascii)
                if headerString?.hasPrefix("ftyp") == true {
                    return "video/mp4"
                } else if headerString?.hasPrefix("M4V") == true {
                    return "video/x-m4v"
                }
            }
            return "application/octet-stream"
        default: return "application/octet-stream"
        }
    }

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
