//  Created by Andrew Steellson on 15.05.2025.

import AVFoundation

public class File: AVAudioFile {
    public let name: String
    public let format: Format
    public let settings: Settings

    public init(
        url: URL,
        name: String? = nil,
        format: Format = .wav,
        pcmFormat: PCMFormat = .pcmFloat32,
        settings: [String: Any]? = nil
    ) throws {
        self.name = name ?? url.lastPathComponent
        self.format = format

        let settings = settings ?? Settings.build()
        self.settings = Settings(settings)

        let pcmFormat = AVAudioCommonFormat(
            rawValue: pcmFormat.rawValue
        )

        try super.init(
            forWriting: url,
            settings: settings,
            commonFormat: pcmFormat ?? .pcmFormatFloat32,
            interleaved: false
        )
    }
}
