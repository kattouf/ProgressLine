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

    @Flag(name: [.customLong("log-all"), .customShort("a")], help: "Log all lines above the progress line.")
    var shouldLogAll: Bool = false

    mutating func run() async throws {
        try validateConfiguration()

        let printers = PrintersHolder(
            printer: Printer(fileHandle: .standardOutput),
            errorsPrinter: Printer(fileHandle: .standardError)
        )
        let logger = AboveProgressLineLogger(printers: printers)

        let progressLineController = await ProgressLineController.buildAndStart(
            printers: printers,
            logger: logger,
            activityIndicator: .make(style: activityIndicatorStyle)
        )
        let originalLogController = if let originalLogPath {
            await OriginalLogController(logger: logger, path: originalLogPath)
        } else {
            OriginalLogController?.none
        }
        let matchesController = await MatchesController(logger: logger, regexps: matchesToLog)
        let logAllController = shouldLogAll ? LogAllController(logger: logger) : nil

        for await data in FileHandle.standardInput.asyncStream {
            await logAllController?.didGetStdinDataChunk(data)
            await matchesController?.didGetStdinDataChunk(data)
            await progressLineController.didGetStdinDataChunk(data)
            await originalLogController?.didGetStdinDataChunk(data)
        }

        await progressLineController.didReachEndOfStdin()
    }

    private func validateConfiguration() throws {
        guard !shouldLogAll || matchesToLog.isEmpty else {
            throw ValidationError("The --log-all and --log-matches options are mutually exclusive.")
        }
    }
}
