import Foundation
import TaggedTime

private enum Symbol {
    static let checkmark = "✓"
    static let prompt = "❯"
}

final class ProgressLineFormatter: Sendable {
    // Linux doesn't support DateComponentsFormatter
    #if os(macOS)
        private let durationFormatter: DateComponentsFormatter = {
            let durationFormatter = DateComponentsFormatter()
            durationFormatter.unitsStyle = .abbreviated
            durationFormatter.allowedUnits = [.hour, .minute, .second]
            durationFormatter.maximumUnitCount = 2
            return durationFormatter
        }()
    #endif

    private let activityIndicator: ActivityIndicator
    private let windowSizeObserver: WindowSizeObserver

    init(
        activityIndicator: ActivityIndicator,
        windowSizeObserver: WindowSizeObserver
    ) {
        self.activityIndicator = activityIndicator
        self.windowSizeObserver = windowSizeObserver
    }

    func inProgress(progress: Progress) -> String {
        let activityIndicator = activityIndicator.state(forDuration: progress.duration)
        let formattedDuration = formatDuration(from: progress.duration)

        let styledActivityIndicator = ANSI.blue + activityIndicator + ANSI.reset
        let styledDuration = ANSI.bold + formattedDuration + ANSI.reset
        let styledPrompt = ANSI.blue + Symbol.prompt + ANSI.reset

        return buildResultString(
            styledActivityIndicator: styledActivityIndicator,
            styledDuration: styledDuration,
            styledPrompt: styledPrompt,
            progressLine: progress.line
        )
    }

    func finished(progress: Progress?) -> String {
        let formattedDuration = progress.map { formatDuration(from: $0.duration) }

        let styledActivityIndicator = ANSI.green + Symbol.checkmark + ANSI.reset
        let styledDuration = formattedDuration.map { ANSI.bold + $0 + ANSI.reset }
        let styledPrompt = ANSI.green + Symbol.prompt + ANSI.reset

        return buildResultString(
            styledActivityIndicator: styledActivityIndicator,
            styledDuration: styledDuration,
            styledPrompt: styledPrompt,
            progressLine: progress?.line
        )
    }

    private func buildResultString(
        styledActivityIndicator: String,
        styledDuration: String?,
        styledPrompt: String,
        progressLine: String?
    ) -> String {
        let buildResultWithProgressLine = { (progressLine: String?) -> String in
            [styledActivityIndicator, styledDuration, styledPrompt, progressLine]
                .compactMap { $0 }
                .joined(separator: " ")
        }
        let result = buildResultWithProgressLine(progressLine)

        let notFittedToWindowLength = calculateStringNotFittedToWindowLength(result)
        if let progressLine, notFittedToWindowLength > 0 {
            let fittedProgressLine = String(progressLine.prefix(progressLine.count - notFittedToWindowLength))
            return buildResultWithProgressLine(fittedProgressLine)
        } else {
            return result
        }
    }

    private func calculateStringNotFittedToWindowLength(_ string: String) -> Int {
        let stringWithoutANSI = string.withoutANSI()
        let windowWidth = windowSizeObserver.size.width
        return max(stringWithoutANSI.count - windowWidth, 0)
    }

    private func formatDuration(from duration: Seconds<TimeInterval>) -> String {
        #if os(Linux)
            duration.rawValue.formattedDuration()
        #else
            durationFormatter.string(from: duration.rawValue)!
        #endif
    }
}

#if os(Linux)
    extension TimeInterval {
        func formattedDuration() -> String {
            let totalSeconds = Int(self)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60

            if hours >= 1 {
                return "\(hours)h \(minutes)m"
            } else if minutes >= 1 {
                return "\(minutes)m \(seconds)s"
            } else {
                return "\(seconds)s"
            }
        }
    }
#endif
