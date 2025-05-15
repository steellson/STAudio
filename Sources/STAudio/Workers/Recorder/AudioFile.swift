//
//  AudioFile.swift
//  STAudio
//
//  Created by Andrew Steellson on 15.05.2025.
//

import Foundation

public struct AudioFile {
    public enum Format: String {
        case mp3, wav, flac, aac
    }

    public let url: URL
    public let name: String
    public let format: Format
}


