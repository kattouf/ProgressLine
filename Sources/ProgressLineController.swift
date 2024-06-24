import Foundation
import TaggedTime

final actor ProgressLineController {
    // Dependencies
    private let printer: Printer
    private let errorsPrinter: Printer
    private let progressLineFormatter: ProgressLineFormatter
    private let progressTracker: ProgressTracker
    // State
    private var renderLoopTask: Task<Never, any Error>?
    private var lastStdinLine: String?
    private var progress: Progress?

    private init(
        printer: Printer,
        errorsPrinter: Printer,
        progressLineFormatter: ProgressLineFormatter,
        progressTracker: ProgressTracker
    ) {
        self.printer = printer
        self.errorsPrinter = errorsPrinter
        self.progressLineFormatter = progressLineFormatter
        self.progressTracker = progressTracker
    }

    // MARK: - Public

    static func buildAndStart(activityIndicator: ActivityIndicator) async -> Self {
        let progressTracker = ProgressTracker.start()
        let printer = Printer(fileHandle: .standardOutput)
        let errorsPrinter = Printer(fileHandle: .standardError)
        let windowSizeObserver = WindowSizeObserver.startObserving()
        let progressLineFormatter = ProgressLineFormatter(
            activityIndicator: activityIndicator,
            windowSizeObserver: windowSizeObserver
        )

        let controller = Self(
            printer: printer,
            errorsPrinter: errorsPrinter,
            progressLineFormatter: progressLineFormatter,
            progressTracker: progressTracker
        )
        await controller.startAnimationLoop(refreshRate: activityIndicator.configuration.refreshRate)

        return controller
    }

    // MARK: - Input

    func didGetStdinDataChunk(_ data: Data) {
        let stdinText = String(data: data, encoding: .utf8)
        guard let stdinText else {
            printToStderrAboveProgressLine("\(ANSI.yellow)[!] progressline: Failed to decode stdin data as UTF-8\(ANSI.reset)")
            return
        }

        lastStdinLine = stdinText
            .split(whereSeparator: \.isNewline)
            .last { !$0.isEmpty }
            .map(String.init)

        redrawProgressLine()
    }

    func didReachEndOfStdin() {
        stopAnimationLoop()

        let progressLine = progressLineFormatter.finished(progress: progress)
        if progress != nil {
            printer
                .cursorUp()
                .eraseLine()
        }
        printer
            .writeln(progressLine)
            .flush()
    }

    // MARK: - Private

    private func startAnimationLoop(refreshRate: Milliseconds<UInt64>) {
        renderLoopTask = Task.periodic(interval: refreshRate) { [weak self] in
            guard !Task.isCancelled else {
                return
            }
            await self?.redrawProgressLine()
        }
    }

    private func stopAnimationLoop() {
        renderLoopTask?.cancel()
    }

    private func redrawProgressLine() {
        if self.progress != nil {
            printer
                .cursorUp()
                .eraseLine()
        }
        let progress = progressTracker.moveForward(lastStdinLine)
        let progressLine = progressLineFormatter.inProgress(progress: progress)
        self.progress = progress
        printer.writeln(progressLine)
        printer.flush()
    }

    private func printToStderrAboveProgressLine(_ message: String) {
        errorsPrinter
            .cursorUp()
            .eraseLine()
            .writeln(message)
            .writeln("")
            .flush()
    }
}
