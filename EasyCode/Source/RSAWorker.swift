//
//  RSAWorker.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 16.10.2024.
//

import Foundation
import Security
import CryptoKit

public protocol RSAService {
    func encrypt(_ string: String, publicKey: String, type: RSAPaddingType) -> Data?
}

public enum RSAPaddingType {
    case PKCS1
    case OAEP
}

public class RSAWorker: RSAService {

    private var publicKey: SecKey?
    private var privateKey: SecKey?

    public init() {}

    public func encrypt(_ string: String, publicKey: String, type: RSAPaddingType) -> Data? {
        guard let formattedKey = extractPublicKey(from: publicKey),
              let secKey = createPublicKey(from: formattedKey) else {
            return nil
        }
        let data = type == .PKCS1 ? encryptPKCS1(string, publicKey: secKey)
                                  : encryptOAEP(data: Data(string.utf8), publicKey: secKey)
        return data
    }

    private func extractPublicKey(from publicKey: String) -> String? {
        let pattern: RegularExpression = #"[-]+BEGIN [^-]+[-]+\s*([A-Za-z0-9+/=\s]+?)\s*[-]+END [^-]+[-]+"#
        let key = pattern.firstMatch(in: publicKey, subgroupPosition: 1)
        return key?.replacingOccurrences(of: #"\s"#, with: "", options: .regularExpression)
    }

    private func createPublicKey(from publicKey: String) -> SecKey? {
        guard let data = Data(base64Encoded: publicKey) else { return nil }

        let attributes: CFDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048
        ] as CFDictionary

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            if let error = error?.takeRetainedValue() {
                print("Error creating public key: \(error.localizedDescription)")
            }
            return nil
        }

        return secKey
    }

    private func encryptPKCS1(_ string: String, publicKey: SecKey) -> Data? {
        let buffer = [UInt8](string.utf8)

        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        let status = SecKeyEncrypt(
            publicKey,
            SecPadding.PKCS1,
            buffer,
            buffer.count,
            &keyBuffer,
            &keySize
        )
        guard status == errSecSuccess else { return nil }

        return Data(bytes: keyBuffer, count: keySize)
    }

    private func encryptOAEP(data: Data, publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) else {
            return nil
        }

        return encryptedData as Data
    }
}
