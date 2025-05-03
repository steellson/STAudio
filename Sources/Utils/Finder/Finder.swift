//
//  Finder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

public final class Finder {
    public enum Errors: Error {
        case emptyPath
        case cantCreateURL
    }

    public let url: URL

    public init(_ path: String?) throws {
        guard let path else { throw Errors.emptyPath }
        guard let url = URL(string: path) else { throw Errors.cantCreateURL }

        self.url = url
    }
}
