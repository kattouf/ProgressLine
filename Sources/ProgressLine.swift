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

    @Option(name: [.customLong("log-matches"), .customShort("m")], help: "Log above progress line lines matching the given regular expressions.")
    var matchesToLog: [String] = []

    mutating func run() async throws {
        let printers = PrintersHolder(
            printer: Printer(fileHandle: .standardOutput),
            errorsPrinter: Printer(fileHandle: .standardError)
        )
        let logger = UnderProgressLineLogger(printers: printers)

        let progressLineController = await ProgressLineController.buildAndStart(
            printers: printers,
            logger: logger,
            activityIndicator: .make(style: activityIndicatorStyle)
        )
        let originalLogController = originalLogPath.map {
            OriginalLogController(logger: logger, path: $0)
        }
        let matchesController = await MatchesController(logger: logger, regexps: matchesToLog)

        for await data in FileHandle.standardInput.asyncStream {
            await matchesController?.didGetStdinDataChunk(data)
            await progressLineController.didGetStdinDataChunk(data)
            await originalLogController?.didGetStdinDataChunk(data)
        }

        await progressLineController.didReachEndOfStdin()
        try await originalLogController?.didReachEndOfStdin()
    }
}
