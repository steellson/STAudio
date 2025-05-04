//
//  Player.swift
//  STAudio
//
//  Created by Andrew Steellson on 02.05.2025.
//

import AVFoundation

public final class Player: Worker<Player.Tasks> {
    private var isPlaying: Bool { player.isPlaying }
    private let player: AVAudioPlayer

    public init(_ url: URL) throws {
        player = try AVAudioPlayer(contentsOf: url)
    }

    // MARK: - Process
    override public func start() throws {
        try super.start()

        guard !isPlaying else {
            throw Errors.alreadyPlaying
        }

        try startPlay()
    }

    override public func stop() throws {
        try super.stop()

        guard isPlaying else {
            throw Errors.alreadyStopped
        }

        try endPlay()
    }
}

// MARK: - Types
public extension Player {
    enum Tasks: String {
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

// MARK: - Private
private extension Player {
    func startPlay() throws {
        guard player.prepareToPlay() else {
            throw Errors.cantPreparePlaying
        }

        player.play()
        guard isPlaying else {
            throw Errors.cantPlay
        }

        log(.playingStarted)
        try processPlaying()
    }

    func processPlaying() throws {
        while isPlaying {
            step()
            log(.playing)
            try autoStop(endPlay)
        }
    }

    func endPlay() throws {
        player.stop()
        guard !isPlaying else {
            throw Errors.cantStop
        }

        log(.playingStopped)
    }
}
