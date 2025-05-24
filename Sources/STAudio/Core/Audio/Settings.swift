//  Created by Andrew Steellson on 24.05.2025.

import AVFoundation

public struct Settings: Sendable {
    static let `default` = Settings(
        formatID: .wav,
        bitDepth: .medium,
        sampleRate: .medium,
        audioQuality: .medium
    )

    public let formatID: UInt32
    public let bitDepth: Int16
    public let sampleRate: Int32
    public let audioQuality: Int

    public init(
        formatID: Format,
        bitDepth: BitDepth,
        sampleRate: SampleRate,
        audioQuality: AudioQuality
    ) {
        self.formatID = formatID.buildID()
        self.bitDepth = bitDepth.rawValue
        self.sampleRate = sampleRate.rawValue
        self.audioQuality = audioQuality.rawValue
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
        /// 32
        case low    = 32
        /// 64
        case medium = 64
        /// 96
        case high   = 96
    }

    public enum BitDepth: Int16 {
        /// 8
        case low    = 8
        /// 16
        case medium = 16
        /// 32
        case high   = 32
    }

    public enum BufferSize: AVAudioFrameCount {
        /// 256
        case low  = 256
        /// 512
        case medium = 512
        /// 1024
        case high   = 1024
    }

    public enum SampleRate: Int32 {
        /// 16000
        case low    = 16000
        /// 44100
        case medium = 44100
        /// 48000
        case high   = 48000
    }
}
