//
//  ZipManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

public enum ZipManagerError: Error {
    case urlNotADirectory(URL)
    case failedToCreateZIP(Swift.Error)
    case failedToPrepareFiles(Swift.Error)
}

public class ZipManager {

    public enum FileToZip {
        case data(Data, filename: String)
        case existingFile(URL)
        case renamedFile(URL, toFilename: String)
    }

    private static func prepareFiles(_ files: [FileToZip], in directoryURL: URL) throws {
        for file in files {
            switch file {
            case .data(let data, filename: let filename):
                let fileURL = directoryURL.appendingPathComponent(filename)
                try data.write(to: fileURL)
            case .existingFile(let existingFileURL):
                let filename = existingFileURL.lastPathComponent
                let destinationURL = directoryURL.appendingPathComponent(filename)
                try FileManager.default.copyItem(at: existingFileURL, to: destinationURL)
            case .renamedFile(let existingFileURL, toFilename: let filename):
                let destinationURL = directoryURL.appendingPathComponent(filename)
                try FileManager.default.copyItem(at: existingFileURL, to: destinationURL)
            }
        }
    }

    public static func createZip(zipFinalURL: URL, fromDirectory directoryURL: URL) throws -> URL {
        guard directoryURL.isDirectory else { throw ZipManagerError.urlNotADirectory(directoryURL) }

        var fileManagerError: Swift.Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: .forUploading,
            error: &coordinatorError
        ) { zipCreatedURL in
            do {
                try FileManager.default.moveItem(at: zipCreatedURL, to: zipFinalURL)
            } catch {
                fileManagerError = error
            }
        }
        if let error = coordinatorError ?? fileManagerError {
            throw ZipManagerError.failedToCreateZIP(error)
        }
        return zipFinalURL
    }

    public static func createZip(
        zipFilename: String,
        zipExtension: String = "zip",
        filesToZip: [FileToZip]
    ) throws -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let uniqueDirectoryName = UUID().uuidString
        let directoryToZipURL = temporaryDirectory
            .appendingPathComponent(uniqueDirectoryName)
            .appendingPathComponent(zipFilename)

        try FileManager.default.createDirectory(at: directoryToZipURL, withIntermediateDirectories: true)

        do {
            try prepareFiles(filesToZip, in: directoryToZipURL)
        } catch {
            throw ZipManagerError.failedToPrepareFiles(error)
        }

        let finalZipURL = temporaryDirectory.appendingPathComponent("\(zipFilename).\(zipExtension)")

        return try createZip(zipFinalURL: finalZipURL, fromDirectory: directoryToZipURL)
    }
}
