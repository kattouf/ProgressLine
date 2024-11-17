import ArgumentParser
import ConcurrencyExtras
import Foundation
import TaggedTime

@main
struct ProgressLine: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progressline",
        abstract: "A command-line tool for compactly tracking the progress of piped commands.",
        usage: "some-command | progressline",
        version: progressLineVersion
    )

    @Option(name: [.long, .customShort("t")], help: "The static text to display instead of the latest stdin data.")
    var staticText: String?

    @Option(name: [.customLong("activity-style"), .customShort("s")], help: "The style of the activity indicator.")
    var activityIndicatorStyle: ActivityIndicatorStyle = .dots

    @Option(name: [.customLong("original-log-path"), .customShort("l")], help: "Save the original log to a file.")
    var originalLogPath: String?

    @Option(
        name: [.customLong("log-matches"), .customShort("m")],
        help: "Log above progress line lines matching the given regular expressions."
    )
    var matchesToLog: [String] = []

    @Flag(name: [.customLong("log-all"), .customShort("a")], help: "Log all lines above the progress line.")
    var shouldLogAll: Bool = false

    #if DEBUG
        @Flag(name: [.customLong("test-mode")], help: "Enable test mode. Activity indicator will be replaced with a static string.")
        var testMode: Bool = false
    #endif

    mutating func run() async throws {
        try validateConfiguration()

        let printers = PrintersHolder(
            printer: Printer(fileHandle: .standardOutput),
            errorsPrinter: Printer(fileHandle: .standardError)
        )
        let logger = AboveProgressLineLogger(printers: printers)

        #if DEBUG
            let activityIndicator: ActivityIndicator = testMode ? .disabled() : .make(style: activityIndicatorStyle)
        #else
            let testMode = false
            let activityIndicator: ActivityIndicator = .make(style: activityIndicatorStyle)
        #endif
        let progressLineController = await ProgressLineController.buildAndStart(
            textMode: staticText.map { .staticText($0) } ?? .stdin,
            printers: printers,
            logger: logger,
            activityIndicator: activityIndicator,
            mockActivityAndDuration: testMode
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
