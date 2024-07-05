import ArgumentParser
import ConcurrencyExtras
import Foundation
import TaggedTime

@main
struct ProgressLine: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progressline",
        abstract: "A command-line tool for compactly tracking the progress of piped commands.",
        usage: "some-command | progressline"
    )

    @Option(name: [.customLong("activity-style"), .customShort("s")], help: "The style of the activity indicator.")
    var activityIndicatorStyle: ActivityIndicatorStyle = .dots

    @Option(name: [.customLong("original-log-path"), .customShort("l")], help: "Save the original log to a file.")
    var originalLogPath: String?

    mutating func run() async throws {
        let progressLineController = await ProgressLineController.buildAndStart(
            activityIndicator: .make(style: activityIndicatorStyle)
        )
        let originalLogController = originalLogPath.map(OriginalLogController.init)

        for await data in FileHandle.standardInput.asyncStream {
            await progressLineController.didGetStdinDataChunk(data)
            await originalLogController?.didGetStdinDataChunk(data)
        }

        await progressLineController.didReachEndOfStdin()
        try await originalLogController?.didReachEndOfStdin()
    }
}
