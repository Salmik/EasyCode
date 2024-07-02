//
//  EncryptionCryptoProtocol.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import CryptoKit

public protocol EncryptionCryptoProtocol {

    func MD5(string: String) -> String
    func SHA256(string: String) -> String
    func encryptWithAES(string: String, key: SymmetricKey) throws -> Data
    func decryptWithAES(data: Data, key: SymmetricKey) throws -> String
    func encryptWithChaChaPoly(string: String, key: SymmetricKey) throws -> Data
    func decryptWithChaChaPoly(data: Data, key: SymmetricKey) throws -> String
    func encryptRSA(data: Data, publicKey: SecKey) throws -> Data
    func decryptRSA(data: Data, privateKey: SecKey) throws -> Data
}

public extension EncryptionCryptoProtocol {

    func MD5(string: String) -> String {
        let hashData = Insecure.MD5.hash(data: Data(string.utf8))
        return hashData.compactMap { String(format: "%02hhx", $0) }.joined()
    }

    func SHA256(string: String) -> String {
        let hashData = CryptoKit.SHA256.hash(data: Data(string.utf8))
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }

    func encryptWithAES(string: String, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(Data(string.utf8), using: key)
        return sealedBox.combined ?? Data()
    }

    func decryptWithAES(data: Data, key: SymmetricKey) throws -> String {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return decryptedString
    }

    func encryptWithChaChaPoly(string: String, key: SymmetricKey) throws -> Data {
        let nonce = ChaChaPoly.Nonce()
        let sealedBox = try ChaChaPoly.seal(Data(string.utf8), using: key, nonce: nonce)
        return sealedBox.combined
    }

    func decryptWithChaChaPoly(data: Data, key: SymmetricKey) throws -> String {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return decryptedString
    }

    func encryptRSA(data: Data, publicKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                throw error as Error
            } else {
                throw NSError(domain: "UnknownError", code: -1, userInfo: nil)
            }
        }
        return encryptedData as Data
    }

    func decryptRSA(data: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(
            privateKey,
            .rsaEncryptionOAEPSHA256,
            data as CFData,
            &error
        ) else {
            if let error = error?.takeRetainedValue() {
                throw error as Error
            } else {
                throw NSError(domain: "UnknownError", code: -1, userInfo: nil)
            }
        }
        return decryptedData as Data
    }
}
