import Foundation

let workingDirectory = "/Users/steellson/Desktop/"

final class MainFlow {
    private let recorder: Worker<Recorder.Tasks>
    private let player: Worker<Player.Tasks>

    init() throws {
        let toRecord = try Filer(workingDirectory, file: "2.wav")
        recorder = try Recorder(toRecord.url)

        let toPlay = try Finder(workingDirectory + "1.wav")
        player = try Player(toPlay.url)
    }

    func start() throws {
        let seconds = 5.0

        recorder.duration = seconds
        player.duration = seconds

        try recorder.start()
        try player.start()
    }
}

// MARK: - Run
@MainActor
func main() {
    do { try MainFlow().start() }
    catch let error { Log.critical(error.localizedDescription) }
}

main()
