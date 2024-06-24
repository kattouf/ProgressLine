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

    @Option(name: [.customLong("activity-style"), .customShort("s")])
    var activityIndicatorStyle: ActivityIndicatorStyle = .dots

    mutating func run() async throws {
        let progressLineController = await ProgressLineController.buildAndStart(
            activityIndicator: .make(style: activityIndicatorStyle)
        )

        for await data in FileHandle.standardInput.asyncStream {
            await progressLineController.didGetStdinDataChunk(data)
        }

        await progressLineController.didReachEndOfStdin()
    }
}
