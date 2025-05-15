//
//  Recorder.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import AVFoundation

public final class Recorder {
    public var isRecording: Bool { engine.isRunning }
    private(set) var file: AudioFile?

    private var isFirstRecord: Bool {
        var isDir: ObjCBool = true
        return fileManager.fileExists(
            atPath: baseURL.absoluteString,
            isDirectory: &isDir
        )
    }

    private let baseURL: URL = {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "STAudio")
    }()

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
        case cantReadFormat
    }
}

// MARK: - Public
public extension Recorder {
    func start(_ file: String) async throws {
        guard !isRecording else {
            throw Errors.alreadyRecording
        }

        try prepareFile(file)
        try prepareFolder()
        try prepareNode()
        try startRecording()
    }

    func stop() async throws -> AudioFile {
        guard isRecording else {
            throw Errors.alreadyStopped
        }

        return try await endRecording()
    }
}

// MARK: - Preparings
private extension Recorder {
    func prepareFile(_ file: String) throws {
        let source = file.split(separator: ".")
        let name = String(source.first ?? "")
        let ext = String(source.last ?? "")

        guard name != ext,
              let format = AudioFile.Format(rawValue: ext) else {
            throw Errors.cantReadFormat
        }

        let url = baseURL.appending(path: file)
        self.file = AudioFile(
            url: url,
            name: name,
            format: format
        )

        if fileManager.fileExists(atPath: url.absoluteString) {
            try fileManager.removeItem(at: url)
        }
    }

    func prepareFolder() throws {
        guard isFirstRecord else { return }

        try fileManager.createDirectory(
            at: baseURL,
            withIntermediateDirectories: false
        )
    }

    func prepareNode() throws {
        guard let file else {
            throw Errors.cantPrepare
        }

        let bus: AVAudioNodeBus = .zero
        let node: AVAudioInputNode = engine.inputNode
        let format: AVAudioFormat = node.inputFormat(forBus: bus)
        let bufferSize: AVAudioFrameCount = BufferSize.medium.rawValue
        let audioFile: AVAudioFile = try AVAudioFile(
            forWriting: file.url,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )
        let writeFromBuffer: (AVAudioPCMBuffer, AVAudioTime) -> Void = { buffer, time in
            try? audioFile.write(from: buffer)
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

        Log.info("Recording started!")
    }

    func endRecording() async throws -> AudioFile {
        engine.stop()
        guard !isRecording else {
            throw Errors.cantStop
        }

        Log.info("Recording stopped")
        return try await export()
    }

    func export() async throws -> AudioFile {
        guard let file else {
            throw Errors.cantExport
        }

        Log.success("Exported file: \(file.url)")
        return file
    }
}
