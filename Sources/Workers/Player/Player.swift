//
//  Player.swift
//  STAudio
//
//  Created by Andrew Steellson on 02.05.2025.
//

import AVFoundation

public final class Player: Worker<Player.Logs> {
    private var isPlaying: Bool { player.isPlaying }
    private let player: AVAudioPlayer

    public init(_ url: URL) throws {
        player = try AVAudioPlayer(contentsOf: url)
    }

    // MARK: - Process
    override public func start() throws {
        guard !isPlaying else { throw Errors.alreadyPlaying }
        guard player.prepareToPlay() else { throw Errors.cantPreparePlaying }

        player.play()
        guard isPlaying else { throw Errors.cantPlay }

        log(.playingStarted)
        try autoStop()
    }

    override public func stop() throws {
        guard isPlaying else { throw Errors.alreadyStopped }

        player.stop()
        guard !isPlaying else { throw Errors.cantStop }

        log(.playingStopped)
    }
}

// MARK: - Types
public extension Player {
    enum Logs: String {
        case playing
        case playingStarted
        case playingStopped
    }

    enum Errors: Error {
        case alreadyPlaying
        case alreadyStopped
        case cantPreparePlaying
        case cantPlay
        case cantStop
    }
}
