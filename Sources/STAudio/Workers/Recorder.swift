//
//  Recorder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import AVFoundation

public final class Recorder {
    public var isRecording: Bool { engine.isRunning }

    private(set) var exportURL: URL?
    private let baseURL: URL = {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "STAudio")
    }()

    private var isFirstRecord: Bool {
        var isDir : ObjCBool = true
        return fileManager.fileExists(
            atPath: baseURL.absoluteString,
            isDirectory: &isDir
        )
    }

    private let engine: AVAudioEngine
    private let fileManager: FileManager

    public init() {
        self.engine = AVAudioEngine()
        self.fileManager = FileManager.default
    }
}

// MARK: - Types
public extension Recorder {
    enum BufferSize: AVAudioFrameCount {
        case small  = 256
        case medium = 512
        case large  = 1024
    }

    enum Errors: Error {
        case alreadyRecording
        case alreadyStopped
        case cantPrepare
        case cantRecord
        case cantStop
        case cantExport
        case cantCreateFile
    }
}

// MARK: - Public
public extension Recorder {
    func start(
        _ name: String,
        _ format: String? = nil
    ) async throws {
        guard !isRecording else {
            throw Errors.alreadyRecording
        }

        try prepareFolder()
        try prepareExport(name, format)
        try prepareNode()
        try startRecording()
    }

    func stop() async throws -> URL {
        guard isRecording else {
            throw Errors.alreadyStopped
        }

        return try await endRecording()
    }
}

// MARK: - Preparings
private extension Recorder {
    func prepareFolder() throws {
        guard isFirstRecord else { return }

        try fileManager.createDirectory(
            at: baseURL,
            withIntermediateDirectories: false
        )
    }

    func prepareExport(
        _ name: String,
        _ format: String? = nil
    ) throws {
        guard let createdURL = {
            let base = baseURL.appending(path: name)

            return if let format {
                base.appendingPathExtension(format)
            } else {
                base
            }
        }() else {
            throw Errors.cantCreateFile
        }

        exportURL = createdURL

        if fileManager.fileExists(atPath: createdURL.absoluteString) {
            try fileManager.removeItem(at: createdURL)
        }
    }

    func prepareNode() throws {
        guard let exportURL else {
            throw Errors.cantPrepare
        }

        let bus: AVAudioNodeBus = .zero
        let node: AVAudioInputNode = engine.inputNode
        let format: AVAudioFormat = node.inputFormat(forBus: bus)
//        guard let format: AVAudioFormat = AVAudioFormat(
//            commonFormat: .pcmFormatInt16,
//            sampleRate: 44100,
//            channels: AVAudioChannelCount(2),
//            interleaved: false
//        ) else {
//            throw Errors.cantStart
//        }
        let bufferSize: AVAudioFrameCount = BufferSize.medium.rawValue
        let file: AVAudioFile = try AVAudioFile(
            forWriting: exportURL,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )
        let writeFromBuffer: (AVAudioPCMBuffer, AVAudioTime) -> Void = { buffer, time in
            try? file.write(from: buffer)
        }

        node.installTap(
            onBus: bus,
            bufferSize: bufferSize,
            format: format,
            block: writeFromBuffer
        )
    }
}

// MARK: - Process
private extension Recorder {
    func startRecording() throws {
        engine.prepare()
        try engine.start()

        guard isRecording else {
            throw Errors.cantRecord
        }

        Log.info("Recording started! URL: \(exportURL)")
    }

    func endRecording() async throws -> URL {
        engine.stop()
        guard !isRecording else {
            throw Errors.cantStop
        }

        Log.info("Recording stopped")
        return try await export()
    }

    func export() async throws -> URL {
        guard let exportURL else {
            throw Errors.cantExport
        }
        return exportURL
    }
}
