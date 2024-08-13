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

    /// Computes the MD5 hash of a given string.
    ///
    /// # Example:
    /// ``` swift
    /// let input = "Hello, World!"
    /// let md5Hash = MD5(string: input)
    /// print("MD5 Hash:", md5Hash)
    /// ```
    ///
    /// - Parameter string: The input string to compute MD5 hash.
    /// - Returns: The MD5 hash string.
    func MD5(string: String) -> String {
        let hashData = Insecure.MD5.hash(data: Data(string.utf8))
        return hashData.compactMap { String(format: "%02hhx", $0) }.joined()
    }

    /// Computes the SHA-256 hash of a given string.
    ///
    /// # Example:
    /// ``` swift
    /// let input = "Hello, World!"
    /// let sha256Hash = SHA256(string: input)
    /// print("SHA-256 Hash:", sha256Hash)
    /// ```
    ///
    /// - Parameter string: The input string to compute SHA-256 hash.
    /// - Returns: The SHA-256 hash string.
    func SHA256(string: String) -> String {
        let hashData = CryptoKit.SHA256.hash(data: Data(string.utf8))
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Encrypts a string using AES-GCM algorithm.
    ///
    /// # Example:
    /// ``` swift
    /// let plaintext = "Secret message"
    /// let key = SymmetricKey(size: .bits256)
    /// do {
    ///     let encryptedData = try encryptWithAES(string: plaintext, key: key)
    ///     print("Encrypted:", encryptedData.base64EncodedString())
    /// } catch {
    ///     print("Encryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - string: The string to encrypt.
    ///   - key: The symmetric key used for encryption.
    /// - Returns: The encrypted data.
    /// - Throws: An error if encryption fails.
    func encryptWithAES(string: String, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(Data(string.utf8), using: key)
        return sealedBox.combined ?? Data()
    }

    /// Decrypts data using AES-GCM algorithm.
    ///
    /// # Example:
    /// ``` swift
    /// let encryptedData = Data(base64Encoded: "...")
    /// let key = SymmetricKey(size: .bits256)
    /// do {
    ///     let decryptedString = try decryptWithAES(data: encryptedData, key: key)
    ///     print("Decrypted:", decryptedString)
    /// } catch {
    ///     print("Decryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data: The encrypted data to decrypt.
    ///   - key: The symmetric key used for decryption.
    /// - Returns: The decrypted string.
    /// - Throws: An error if decryption fails.
    func decryptWithAES(data: Data, key: SymmetricKey) throws -> String {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return decryptedString
    }

    /// Encrypts a string using ChaChaPoly algorithm.
    ///
    /// # Example:
    /// ``` swift
    /// let plaintext = "Top secret message"
    /// let key = SymmetricKey(size: .bits256)
    /// do {
    ///     let encryptedData = try encryptWithChaChaPoly(string: plaintext, key: key)
    ///     print("Encrypted:", encryptedData.base64EncodedString())
    /// } catch {
    ///     print("Encryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - string: The string to encrypt.
    ///   - key: The symmetric key used for encryption.
    /// - Returns: The encrypted data.
    /// - Throws: An error if encryption fails.
    func encryptWithChaChaPoly(string: String, key: SymmetricKey) throws -> Data {
        let nonce = ChaChaPoly.Nonce()
        let sealedBox = try ChaChaPoly.seal(Data(string.utf8), using: key, nonce: nonce)
        return sealedBox.combined
    }

    /// Decrypts data using ChaChaPoly algorithm.
    ///
    /// # Example:
    /// ``` swift
    /// let encryptedData = Data(base64Encoded: "...")
    /// let key = SymmetricKey(size: .bits256)
    /// do {
    ///     let decryptedString = try decryptWithChaChaPoly(data: encryptedData, key: key)
    ///     print("Decrypted:", decryptedString)
    /// } catch {
    ///     print("Decryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data: The encrypted data to decrypt.
    ///   - key: The symmetric key used for decryption.
    /// - Returns: The decrypted string.
    /// - Throws: An error if decryption fails.
    func decryptWithChaChaPoly(data: Data, key: SymmetricKey) throws -> String {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return decryptedString
    }

    /// Encrypts data using RSA algorithm with a public key.
    ///
    /// # Example:
    /// ``` swift
    /// let dataToEncrypt = Data("Top secret data".utf8)
    /// let publicKey = try getPublicKey()
    /// do {
    ///     let encryptedData = try encryptRSA(data: dataToEncrypt, publicKey: publicKey)
    ///     print("Encrypted:", encryptedData.base64EncodedString())
    /// } catch {
    ///     print("Encryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - publicKey: The public key used for encryption.
    /// - Returns: The encrypted data.
    /// - Throws: An error if encryption fails.
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

    /// Decrypts data using RSA algorithm with a private key.
    ///
    /// # Example:
    /// ``` swift
    /// let encryptedData = Data(base64Encoded: "...")
    /// let privateKey = try getPrivateKey()
    /// do {
    ///     let decryptedData = try decryptRSA(data: encryptedData, privateKey: privateKey)
    ///     print("Decrypted:", String(data: decryptedData, encoding: .utf8) ?? "Failed to decode decrypted data")
    /// } catch {
    ///     print("Decryption failed:", error.localizedDescription)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data: The encrypted data to decrypt.
    ///   - privateKey: The private key used for decryption.
    /// - Returns: The decrypted data.
    /// - Throws: An error if decryption fails.
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

    func randomNonceString(length: Int = 32) -> String {
        guard length > 0 else { return "" }

        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard errorCode == errSecSuccess else { return "" }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }

        return String(nonce)
    }
}
