import Foundation
import TaggedTime

final actor ProgressLineController {
    enum TextMode {
        case staticText(String)
        case stdin
    }

    // Dependencies
    private let textMode: TextMode
    private let printers: PrintersHolder
    private let logger: AboveProgressLineLogger
    private let progressLineFormatter: ProgressLineFormatter
    private let progressTracker: ProgressTracker
    // State
    private var renderLoopTask: Task<Never, any Error>?
    private var lastStdinLine: String?
    private var progress: Progress?

    private init(
        textMode: TextMode,
        printers: PrintersHolder,
        logger: AboveProgressLineLogger,
        progressLineFormatter: ProgressLineFormatter,
        progressTracker: ProgressTracker
    ) {
        self.textMode = textMode
        self.printers = printers
        self.logger = logger
        self.progressLineFormatter = progressLineFormatter
        self.progressTracker = progressTracker
    }

    // MARK: - Public

    static func buildAndStart(
        textMode: TextMode,
        printers: PrintersHolder,
        logger: AboveProgressLineLogger,
        activityIndicator: ActivityIndicator,
        mockActivityAndDuration: Bool = false
    ) async -> Self {
        let progressTracker = ProgressTracker.start()
        let windowSizeObserver = WindowSizeObserver.startObserving()
        let progressLineFormatter = ProgressLineFormatter(
            activityIndicator: activityIndicator,
            windowSizeObserver: windowSizeObserver,
            mockActivityAndDuration: mockActivityAndDuration
        )

        let controller = Self(
            textMode: textMode,
            printers: printers,
            logger: logger,
            progressLineFormatter: progressLineFormatter,
            progressTracker: progressTracker
        )
        await controller.startAnimationLoop(refreshRate: activityIndicator.configuration.refreshRate)

        return controller
    }

    // MARK: - Input

    func didGetStdinDataChunk(_ data: Data) async {
        guard case .stdin = textMode else {
            // we will redraw anyway to sync (prevent flickering) with other log controllers
            await redrawProgressLine()
            return
        }

        let stdinText = String(data: data, encoding: .utf8)
        guard let stdinText else {
            await logger.logError(ErrorMessage.canNotDecodeData)
            return
        }

        lastStdinLine = stdinText
            .split(whereSeparator: \.isNewline)
            .last { !$0.isEmpty }
            .map(String.init)

        await redrawProgressLine()
    }

    func didReachEndOfStdin() async {
        stopAnimationLoop()

        let progressLine = progressLineFormatter.finished(progress: progress)
        await printers.withPrinter { printer in
            if printer.wasWritten {
                printer
                    .cursorUp()
                    .eraseLine()
            }
            printer
                .writeln(progressLine)
                .flush()
        }
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

    private func redrawProgressLine() async {
        let lineText: String? = switch textMode {
        case .staticText(let text):
            text
        case .stdin:
            lastStdinLine
        }
        let progress = progressTracker.moveForward(lineText)
        let progressLine = progressLineFormatter.inProgress(progress: progress)
        self.progress = progress
        await printers.withPrinter { printer in
            if printer.wasWritten {
                printer
                    .cursorUp()
                    .eraseLine()
            }
            printer
                .writeln(progressLine)
                .flush()
        }
    }
}
