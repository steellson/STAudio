//
//  Recorder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import AVFoundation

public final class Recorder: Worker<Recorder.Tasks> {
    private var isRunning: Bool { engine.isRunning }

    private let url: URL
    private let engine: AVAudioEngine

    public init(_ url: URL) throws {
        self.url = url
        self.engine = AVAudioEngine()
    }

    // MARK: - Process
    override public func start() throws {
        guard !isRunning else {
            throw Errors.alreadyRecording
        }

        try prepareNode()
        try startRecording()
    }

    override public func stop() throws {
        guard isRunning else {
            throw Errors.alreadyStopped
        }

        try endRecording()
    }
}

// MARK: - Types
public extension Recorder {
    enum Tasks: String {
        case startRecordingAtPath
        case stopRecording
    }

    enum Errors: Error {
        case alreadyRecording
        case alreadyStopped
        case cantRecord
        case cantStop
    }

    enum BufferSize: AVAudioFrameCount {
        case small  = 256
        case medium = 512
        case large  = 1024
    }
}

// MARK: - Private
private extension Recorder {
    func prepareNode() throws {
        let bus: AVAudioNodeBus = .zero
        let node: AVAudioInputNode = engine.inputNode
        let format: AVAudioFormat = node.inputFormat(forBus: bus)
        let bufferSize: AVAudioFrameCount = BufferSize.medium.rawValue

        let file: AVAudioFile = try AVAudioFile(
            forWriting: url,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )
        let writeFromBuffer: (AVAudioPCMBuffer, AVAudioTime) -> Void = { buffer, _ in
            try? file.write(from: buffer)
        }

        node.installTap(
            onBus: bus,
            bufferSize: bufferSize,
            format: format,
            block: writeFromBuffer
        )
    }

    func startRecording() throws {
        engine.prepare()
        try engine.start()

        guard isRunning else { throw Errors.cantRecord }

        log(.startRecordingAtPath, url.absoluteString)
        try autoStop()
    }

    func endRecording() throws {
        engine.stop()
        guard !isRunning else { throw Errors.cantStop }

        log(.stopRecording)
    }
}
