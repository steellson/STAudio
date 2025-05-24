//  Created by Andrew Steellson on 24.05.2025.

import AVFoundation

public struct Settings {
    public enum Preset {
        case `default`
        case custom(Settings)
    }

    public let formatID: Int32
    public let sampleRate: Int32
    public let bitDepth: Int16
    public let audioQuality: Int

    public init(
        formatID: Int32,
        sampleRate: Int32,
        bitDepth: Int16,
        audioQuality: Int
    ) {
        self.formatID = formatID
        self.sampleRate = sampleRate
        self.bitDepth = bitDepth
        self.audioQuality = audioQuality
    }
}

// MARK: - Build
public extension Settings {
    public static func build(_ preset: Preset = .default) -> [String: Any] {
        switch preset {
        case .default:
            [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: SampleRate.medium.rawValue,
                AVLinearPCMBitDepthKey: BitDepth.medium.rawValue,
                AVEncoderAudioQualityKey: AudioQuality.medium.rawValue
            ]
        case let .custom(settings):
            [
                AVFormatIDKey: settings.formatID,
                AVSampleRateKey: settings.sampleRate,
                AVLinearPCMBitDepthKey: settings.bitDepth,
                AVEncoderAudioQualityKey: settings.audioQuality
            ]
        }
    }
}

// MARK: - Selectable
public extension Settings {
    public enum AudioQuality: Int {
        case low    = 32
        case medium = 64
        case high   = 96
    }

    public enum BitDepth: Int16 {
        case low    = 8
        case medium = 16
        case high   = 32
    }

    public enum BufferSize: AVAudioFrameCount {
        case low  = 256
        case medium = 512
        case high   = 1024
    }

    public enum SampleRate: Int32 {
        case low    = 16000
        case medium = 44100
        case high   = 48000
    }
}
