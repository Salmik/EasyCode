//
//  LocalFileManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import PDFKit
import AVFoundation

/// A protocol that defines the required property for a folder type used in the LocalFileManager.
public protocol FolderTypeProtocol {
    var rawValue: String { get }
}

/// A class that provides methods to interact with the file system for saving, loading, updating, and deleting files.
public class LocalFileManager {

    /// Enumeration for errors that can occur during file management operations.
    public enum FileManagerError: Error {
        case directoryNotFound
        case notFound
        case invalidExtension
        case missingExtension
    }

    /// Enumeration for different file types supported by the LocalFileManager.
    public enum FileType: String {
        case image
        case pdf
        case video

        /// An array of supported file extensions for each file type.
        var extensions: [String] {
            switch self {
            case .image: return ["jpg", "jpeg", "png", "gif", "tiff", "raw", "heic", "heif"]
            case .pdf: return ["pdf"]
            case .video: return ["mov", "mp4"]
            }
        }
    }

    public init() {}

    private let fileManager = FileManager.default

    /// Retrieves the URL for the document directory.
    ///
    /// - Returns: The URL for the document directory.
    /// - Throws: An error if the document directory URL cannot be retrieved.
    private func documentDirectoryUrl() throws -> URL {
        return try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    /// Validates the file extension for a given file name and file type.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - type: The type of the file.
    /// - Throws: An error if the file extension is missing or invalid.
    private func validateExtension(ofFileName fileName: String, for type: FileType) throws {
        if NSString(string: fileName).pathExtension.isEmpty {
            throw FileManagerError.missingExtension
        }

        if !type.extensions.contains(NSString(string: fileName).pathExtension) {
            throw FileManagerError.invalidExtension
        }
    }

    /// Creates a folder with the specified folder type.
    ///
    /// - Parameter folderType: The folder type for which the folder should be created.
    /// - Throws: An error if the folder cannot be created.
    private func createFolder(with folderType: FolderTypeProtocol) throws {
        let directory = try documentDirectoryUrl().appendingPathComponent(folderType.rawValue)
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    /// Retrieves the URL for a file with the specified name and folder type.
    ///
    /// - Parameters:
    ///   - name: The name of the file.
    ///   - folderType: The folder type in which the file is located (optional).
    /// - Returns: The URL for the file.
    /// - Throws: An error if the URL cannot be constructed.
    public func fileUrl(withName name: String, in folderType: FolderTypeProtocol? = nil) throws -> URL {
        let url: URL
        if let folder = folderType {
            url = try documentDirectoryUrl().appendingPathComponent(
                folder.rawValue,
                isDirectory: true
            ).appendingPathComponent(name)
        } else {
            url = try documentDirectoryUrl().appendingPathComponent(name)
        }
        return url
    }

    /// Retrieves an image with the specified name and folder type.
    ///
    /// - Parameters:
    ///   - name: The name of the image file.
    ///   - folderType: The folder type in which the image is located (optional).
    /// - Returns: The image if it exists, or nil if the image cannot be found.
    /// - Throws: An error if the file extension is invalid or the image cannot be found.
    ///
    /// # Example:
    /// ``` swift
    /// let image = try localFileManager.image(withName: "example.jpg")
    /// ```
    public func image(withName name: String, in folderType: FolderTypeProtocol? = nil) throws -> UIImage? {
        try validateExtension(ofFileName: name, for: .image)

        let fileUrl = try fileUrl(withName: name, in: folderType).absoluteString.dropFirst(7)
        guard let image = UIImage(contentsOfFile: String(fileUrl)) else {
            throw FileManagerError.notFound
        }
        return image
    }

    /// Retrieves a PDF document with the specified name.
    ///
    /// - Parameter name: The name of the PDF file.
    /// - Returns: The PDF document if it exists, or nil if the document cannot be found.
    /// - Throws: An error if the file extension is invalid or the PDF document cannot be found.
    ///
    /// # Example:
    /// ``` swift
    /// let pdf = try localFileManager.pdf(withName: "example.pdf")
    /// ```
    public func pdf(withName name: String) throws -> PDFDocument? {
        try validateExtension(ofFileName: name, for: .pdf)

        let fileUrl = try fileUrl(withName: name)
        guard let pdf = PDFDocument(url: fileUrl) else {
            throw FileManagerError.notFound
        }
        return pdf
    }

    /// Retrieves a video asset with the specified name.
    ///
    /// - Parameter name: The name of the video file.
    /// - Returns: The video asset if it exists, or nil if the video cannot be found.
    /// - Throws: An error if the file extension is invalid or the video cannot be found.
    ///
    /// # Example:
    /// ``` swift
    /// let video = try localFileManager.video(withName: "example.mp4")
    /// ```
    public func video(withName name: String) throws -> AVAsset? {
        try validateExtension(ofFileName: name, for: .video)
        return try AVAsset(url: fileUrl(withName: name))
    }

    /// Saves data to a file with the specified name, type, and folder type.
    ///
    /// - Parameters:
    ///   - data: The data to save.
    ///   - type: The type of the file.
    ///   - name: The name of the file.
    ///   - folderType: The folder type in which the file should be saved (optional).
    /// - Throws: An error if the file extension is invalid or the data cannot be saved.
    ///
    /// # Example:
    /// ``` swift
    /// let imageData = UIImage(named: "example")!.pngData()!
    /// try localFileManager.save(data: imageData, ofType: .image, withName: "example.png")
    /// ```
    public func save(
        data: Data,
        ofType type: FileType,
        withName name: String,
        in folderType: FolderTypeProtocol? = nil
    ) throws {
        try validateExtension(ofFileName: name, for: type)

        if let folder = folderType {
            try createFolder(with: folder)
            let fileUrl = try fileUrl(withName: name, in: folder)
            try data.write(to: fileUrl)
        } else {
            let fileUrl = try fileUrl(withName: name)
            try data.write(to: fileUrl)
        }
    }

    /// Checks if a file with the specified name and folder type exists.
    ///
    /// - Parameters:
    ///   - name: The name of the file.
    ///   - folderType: The folder type in which the file is located (optional).
    /// - Returns: A Boolean value indicating whether the file exists.
    /// - Throws: An error if the URL for the file cannot be constructed.
    ///
    /// # Example:
    /// ``` swift
    /// let fileExists = try localFileManager.doesFileExist(with: "example.png")
    /// ```
    public func doesFileExist(with name: String, in folderType: FolderTypeProtocol? = nil) throws -> Bool {
        let fileUrl = try fileUrl(withName: name, in: folderType)
        return fileManager.fileExists(atPath: fileUrl.path)
    }

    /// Removes a file with the specified name and folder type.
    ///
    /// - Parameters:
    ///   - name: The name of the file.
    ///   - folderType: The folder type in which the file is located (optional).
    /// - Throws: An error if the file cannot be found or removed.
    ///
    /// # Example:
    /// ``` swift
    /// try localFileManager.removeFile(withName: "example.png")
    /// ```
    public func removeFile(withName name: String, in folderType: FolderTypeProtocol? = nil) throws {
        let fileUrl = try fileUrl(withName: name, in: folderType)
        if fileManager.fileExists(atPath: fileUrl.path) {
            try fileManager.removeItem(at: fileUrl)
        }
    }
}
