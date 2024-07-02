//
//  LocalFileManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import PDFKit
import AVFoundation

public protocol FolderTypeProtocol {
    var rawValue: String { get }
}

public class LocalFileManager {

    public enum FileManagerError: Error {
        case directoryNotFound, notFound, invalidExtension, missingExtension
    }

    public enum FileType: String {
        case image, pdf, video

        var extensions: [String] {
            switch self {
            case .image: return ["jpg", "jpeg", "png", "gif", "tiff", "raw", "heic", "heif"]
            case .pdf: return ["pdf"]
            case .video: return ["mov", "mp4"]
            }
        }
    }

    private let fileManager = FileManager.default

    private func documentDirectoryUrl() throws -> URL {
        return try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    private func validateExtension(ofFileName fileName: String, for type: FileType) throws {
        if NSString(string: fileName).pathExtension.isEmpty {
            throw FileManagerError.missingExtension
        }

        if !type.extensions.contains(NSString(string: fileName).pathExtension) {
            throw FileManagerError.invalidExtension
        }
    }

    private func createFolder(with folderType: FolderTypeProtocol) throws {
        let directory = try documentDirectoryUrl().appendingPathComponent(folderType.rawValue)
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

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

    public func image(withName name: String, in folderType: FolderTypeProtocol? = nil) throws -> UIImage? {
        try validateExtension(ofFileName: name, for: .image)

        let fileUrl = try fileUrl(withName: name, in: folderType).absoluteString.drop(prefix: "file://")
        guard let image = UIImage(contentsOfFile: fileUrl) else {
            throw FileManagerError.notFound
        }
        return image
    }

    public func pdf(withName name: String) throws -> PDFDocument? {
        try validateExtension(ofFileName: name, for: .pdf)

        let fileUrl = try fileUrl(withName: name)
        guard let pdf = PDFDocument(url: fileUrl) else {
            throw FileManagerError.notFound
        }
        return pdf
    }

    public func video(withName name: String) throws -> AVAsset? {
        try validateExtension(ofFileName: name, for: .video)
        return try AVAsset(url: fileUrl(withName: name))
    }

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

    public func doesFileExist(with name: String, in folderType: FolderTypeProtocol? = nil) throws -> Bool {
        let fileUrl = try fileUrl(withName: name, in: folderType)
        return fileManager.fileExists(atPath: fileUrl.path)
    }

    public func removeFile(withName name: String, in folderType: FolderTypeProtocol? = nil) throws {
        let fileUrl = try fileUrl(withName: name, in: folderType)
        if fileManager.fileExists(atPath: fileUrl.path) {
            try fileManager.removeItem(at: fileUrl)
        }
    }
}
