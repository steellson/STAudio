//
//  Filer.swift
//  STAudio
//
//  Created by Andrew Steellson on 04.05.2025.
//

import Foundation

public struct Filer {
    public enum Errors: Error {
        case existingFile
        case cantCreateFile
        case cantCreateURL
    }

    public let url: URL

    /// ** TO CREATE FILE **
    /// - Parameters:
    ///   - directory: When file will be created
    ///   - file: File name included format `Unknown - Untitled.mp3`
    public init(_ directory: String, file: String) throws {
        let filePath = directory + file
        let fileManager = FileManager.default

        guard !fileManager.fileExists(atPath: filePath) else {
            throw Errors.existingFile
        }
        guard fileManager.createFile(atPath: filePath, contents: nil) else {
            throw Errors.cantCreateFile
        }
        guard let safeURL = URL(string: filePath) else {
            throw Errors.cantCreateURL
        }

        url = safeURL
    }
}
