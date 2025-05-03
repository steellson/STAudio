//
//  Recorder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import AVFoundation

public final class Recorder: Worker<Recorder.Logs> {
    private var isRunning: Bool { engine.isRunning }

    private let url: URL
    private let engine: AVAudioEngine

    public init(_ url: URL) throws {
        self.url = url
        self.engine = AVAudioEngine()
    }

    // MARK: - Process
    override public func start() throws {
        guard !isRunning else { throw Errors.alreadyRecording }

        let bus: AVAudioNodeBus = .zero
        let input: AVAudioInputNode = engine.inputNode
        let format: AVAudioFormat = input.inputFormat(forBus: bus)
        let bufferSize: AVAudioFrameCount = 512

        let file = try AVAudioFile(
            forWriting: url,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )
        input.installTap(
            onBus: bus,
            bufferSize: bufferSize,
            format: format
        ) { buffer, time in
            try? file.write(from: buffer)
        }

        engine.prepare()
        try engine.start()
        guard isRunning else { throw Errors.cantRecord }

        log(.startRecordingAtPath, url.absoluteString)
        try autoStop()
    }

    override public func stop() throws {
        guard isRunning else { throw Errors.alreadyStopped }

        engine.stop()
        guard !isRunning else { throw Errors.cantStop }

        log(.stopRecording)
    }
}

// MARK: - Types
public extension Recorder {
    enum Logs: String {
        case startRecordingAtPath
        case stopRecording
    }

    enum Errors: Error {
        case alreadyRecording
        case alreadyStopped
        case cantRecord
        case cantStop
    }
}
