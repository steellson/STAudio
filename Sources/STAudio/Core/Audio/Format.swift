//  Created by Andrew Steellson on 24.05.2025.

import AVFoundation

public enum Format: String,
                    Sendable,
                    CaseIterable {
    case mp3
    case wav
    case flac
    case aac

    func buildID() -> AudioFormatID {
        switch self {
        case .flac: kAudioFormatFLAC
        case .aac:  kAudioFormatMPEG4AAC
        case .wav:  kAudioFormatLinearPCM
        case .mp3:  kAudioFormatMPEGLayer3
        }
    }
}

public enum PCMFormat: UInt {
    case other      = 0
    case pcmFloat32 = 1
    case pcmFloat64 = 2
    case pcmInt16   = 3
    case pcmInt32   = 4
}
