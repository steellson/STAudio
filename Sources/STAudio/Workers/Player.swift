//
//  Player.swift
//  STAudio
//
//  Created by Andrew Steellson on 02.05.2025.
//

import AVFoundation

public final class Player {
    public var isPlaying: Bool { player.isPlaying }

    private let url: URL
    private let player: AVAudioPlayer

    public init(_ url: URL) throws {
        self.url = url
        self.player = try AVAudioPlayer(contentsOf: url)
    }
}

// MARK: - Types
public extension Player {
    enum Errors: Error {
        case alreadyPlaying
        case alreadyStopped
        case cantPreparePlaying
        case cantPlay
        case cantStop
    }
}

// MARK: - Public
public extension Player {
    func start() async throws {
        guard !isPlaying else {
            throw Errors.alreadyPlaying
        }

        try preparePlayer()
        try startPlay()
    }

    func stop() async throws {
        guard isPlaying else {
            throw Errors.alreadyStopped
        }

        try endPlay()
    }
}

// MARK: - Preparings
private extension Player {
    func preparePlayer() throws {
        guard player.prepareToPlay() else {
            throw Errors.cantPreparePlaying
        }
    }
}

// MARK: - Process
private extension Player {
    func startPlay() throws {
        player.play()
        guard isPlaying else {
            throw Errors.cantPlay
        }

        Log.success("Playing started! URL: \(url)")
    }

    func endPlay() throws {
        player.stop()
        guard !isPlaying else {
            throw Errors.cantStop
        }

        Log.info("Stop playing")
    }
}
