//  Created by Andrew Steellson on 03.05.2025.

import AVFoundation

public final class Recorder {
    public var file: File?
    public var isRecording: Bool { engine.isRunning }

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
        case small  = 256
        case medium = 512
        case large  = 1024
    }

    enum SampleRate: Int32 {
        case low    = 16000
        case medium = 44100
        case high   = 48000
    }

    enum BitDepth: Int16 {
        case low    = 8
        case medium = 16
        case high   = 32
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

    func stop() async throws -> File {
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
        let defaultFormat = Format.wav
        let createdFile = (name ?? createNewRecord(defaultFormat)) as NSString

        let format = Format(rawValue: createdFile.pathExtension) ?? defaultFormat
        let name = createdFile.deletingPathExtension
        let url = baseURL.appending(path: createdFile as String)

        try? fileManager.removeItem(at: url)
        file = File(url: url, name: name, format: format)
    }

    func prepareNode() throws {
        guard let file else { throw Errors.cantPrepare }

        let bus: AVAudioNodeBus = .zero
        let node = engine.inputNode
        let format = node.inputFormat(forBus: bus)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: SampleRate.medium.rawValue,
            AVLinearPCMBitDepthKey: BitDepth.medium.rawValue,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        let audioFile = try AVAudioFile(
            forWriting: file.url,
            settings: settings,
            commonFormat: .pcmFormatFloat32,
            interleaved: true
        )

        engine.inputNode.installTap(
            onBus: bus,
            bufferSize: BufferSize.medium.rawValue,
            format: format
        ) { buffer, _ in
            do {
                try audioFile.write(from: buffer)
            } catch {
                Log.critical("Audio engine write in buffer error: \(error)")
            }
        }
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

        Log.info("Recording started")
    }

    func endRecording() async throws -> File {
        engine.stop()
        guard !isRecording else {
            throw Errors.cantStop
        }

        Log.info("Recording stopped")
        return try await export()
    }

    func export() async throws -> File {
        guard let file else {
            throw Errors.cantExport
        }

        Log.success("Exported file: \(file.url)")
        return file
    }
}

// MARK: - Tools
private extension Recorder {
    func createNewRecord(_ format: Format) -> String {
        var name = ""
        var prefix = "Record_"

        let records = searchRecords(with: prefix)
        records.enumerated().forEach { index, record in
            guard name.isEmpty else { return }

            let number = index + 1
            let newName = "\(prefix)\(number).\(format.rawValue)"
            let newPath = baseURL.appending(path: newName).path()

            guard !fileManager.fileExists(atPath: newPath) else { return }
            name = newName
        }

        let defaultName = "\(prefix)\(records.count + 1).\(format.rawValue)"
        return name.isEmpty ? defaultName : name
    }

    func searchRecords(with prefix: String) -> [String] {
        guard let storedFiles = try? fileManager.contentsOfDirectory(
            atPath: baseURL.path()
        ) else { return [] }

        let formats = Format.allCases.compactMap { $0.rawValue }

        return storedFiles.filter { file in
            let isUnnamedRecord = file.hasPrefix(prefix)
            let hasExistingFormat = formats
                .compactMap { file.hasSuffix($0) }
                .first != nil

            return isUnnamedRecord && hasExistingFormat
        } ?? []
    }
}
