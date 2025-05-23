//  Created by Andrew Steellson on 03.05.2025.

import AVFoundation

public final class Recorder {
    public var isRecording: Bool { engine.isRunning }

    private(set) var file: AudioFile?
    private var isFirstRecord: Bool {
        !fileManager.fileExists(atPath: baseURL.relativePath)
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
        case small = 256
        case medium = 512
        case large = 1024
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

// MARK: - Rec
public extension Recorder {
    func start(_ file: String? = nil) async throws {
        guard !isRecording else {
            throw Errors.alreadyRecording
        }

        try prepareFolder()
        prepareFile(file)
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

// MARK: - Erasing
public extension Recorder {
    func erase() throws {
        try fileManager.removeItem(at: baseURL)

        Log.debug("Recorder's storage erased!")
    }

    func eraseLast() throws {
        guard let lastRecordedFile = file?.url else { return }

        try fileManager.removeItem(at: lastRecordedFile)
        Log.debug("Last recorded file erased!")
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

    func prepareFile(_ name: String?) {
        let defaultFormat = AudioFormat.wav
        let createdFile = (name ?? createNewRecord(defaultFormat)) as NSString

        let format = AudioFormat(rawValue: createdFile.pathExtension) ?? defaultFormat
        let name = createdFile.deletingPathExtension
        let url = baseURL.appending(path: createdFile as String)

        try? fileManager.removeItem(at: url)
        file = AudioFile(url: url, name: name, format: format)
    }

    func prepareNode() throws {
        guard let file else { throw Errors.cantPrepare }

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
        let writeFromBuffer: (AVAudioPCMBuffer, AVAudioTime) -> Void = {
            buffer,
            time in
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

// MARK: - Tools
private extension Recorder {
    func createNewRecord(_ format: AudioFormat) -> String {
        var name = ""
        var prefix = "Record_"
        searchRecords(with: prefix)
            .enumerated()
            .forEach { index, record in
                guard name.isEmpty else { return }

                let number = index == .zero ? index + 1 : index
                let newName = "\(prefix)\(number).\(format.rawValue)"
                let newPath = baseURL.appending(path: newName).path()

                guard !fileManager.fileExists(atPath: newPath) else { return }
                name = newName
        }

        let defaultName = "\(prefix)1.\(format.rawValue)"
        return name.hasSuffix(format.rawValue) ? name : defaultName
    }

    func searchRecords(with prefix: String) -> [String] {
        guard let storedFiles = try? fileManager.contentsOfDirectory(
            atPath: baseURL.path()
        ) else { return [] }

        let formats = AudioFormat.allCases.compactMap { $0.rawValue }

        return storedFiles.filter { file in
            let isUnnamedRecord = file.hasPrefix(prefix)
            let hasExistingFormat = formats
                .compactMap { file.hasSuffix($0) }
                .first != nil

            return isUnnamedRecord && hasExistingFormat
        } ?? []
    }
}
