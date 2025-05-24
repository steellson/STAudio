//  Created by Andrew Steellson on 24.05.2025.

import AVFoundation

public struct Settings: Sendable {
    static let `default` = Settings(
        bitDepth: BitDepth.medium.rawValue,
        formatID: kAudioFormatLinearPCM,
        sampleRate: SampleRate.medium.rawValue,
        audioQuality: AudioQuality.medium.rawValue
    )

    public let formatID: UInt32
    public let sampleRate: Int32
    public let bitDepth: Int16
    public let audioQuality: Int

    public init(
        bitDepth: Int16,
        formatID: UInt32,
        sampleRate: Int32,
        audioQuality: Int
    ) {
        self.bitDepth = bitDepth
        self.formatID = formatID
        self.sampleRate = sampleRate
        self.audioQuality = audioQuality
    }
}

// MARK: - Convert
public extension Settings {
    public init(_ source: [String: Any]) {
        let bitDepth = source["AVLinearPCMBitDepthKey"] as? Int16
        let formatID = source["AVFormatIDKey"] as? UInt32
        let sampleRate = source["AVSampleRateKey"] as? Int32
        let audioQuality = source["AVEncoderAudioQualityKey"] as? Int

        self.bitDepth = bitDepth ?? Self.default.bitDepth
        self.formatID = formatID ?? Self.default.formatID
        self.sampleRate = sampleRate ?? Self.default.sampleRate
        self.audioQuality = audioQuality ?? Self.default.audioQuality
    }
}

// MARK: - Build
public extension Settings {
    public enum Preset {
        case `default`
        case custom(Settings)
    }

    public static func build(_ preset: Preset = .default) -> [String: Any] {
        switch preset {
        case .default:
            [
                AVFormatIDKey: Self.default.formatID,
                AVSampleRateKey: Self.default.sampleRate,
                AVLinearPCMBitDepthKey: Self.default.bitDepth,
                AVEncoderAudioQualityKey: Self.default.audioQuality
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
