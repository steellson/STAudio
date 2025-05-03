import Foundation

let workingDirectory = "/Users/steellson/Desktop/"

final class MainFlow {
    private let player: Player
    private let recorder: Recorder
    private let toPlay, toRecord: Finder

    init() throws {
        toPlay = try Finder(workingDirectory + "1.wav")
        toRecord = try Finder(workingDirectory + "2.wav")

        player = try Player(toPlay.url)
        recorder = try Recorder(toRecord.url)
    }

    func start() throws {
        player.time = 5
        recorder.time = 5

        try player.start()
        try recorder.start()
    }
}

// MARK: - Run
@MainActor
func main() {
    do { try MainFlow().start() }
    catch let error { Log.critical(error.localizedDescription) }
}

main()
