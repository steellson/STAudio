//
//  Finder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

public struct Finder {
    public enum Errors: Error {
        case emptyPath
        case cantFindFile
        case cantCreateURL
    }

    public let url: URL

    /// ** TO FIND FILE**
    /// - Parameter path: Absolute path to wanted file
    public init(_ path: String?) throws {
        guard let path else {
            throw Errors.emptyPath
        }
        guard FileManager.default.fileExists(atPath: path) else {
            throw Errors.cantFindFile
        }
        guard let safeURL = URL(string: path) else {
            throw Errors.cantCreateURL
        }

        url = safeURL
    }
}
