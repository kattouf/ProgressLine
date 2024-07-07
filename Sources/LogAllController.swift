import Foundation

final class LogAllController {
    private let logger: UnderProgressLineLogger

    init(logger: UnderProgressLineLogger) {
        self.logger = logger
    }

    func didGetStdinDataChunk(_ data: Data) async {
        let text = String(data: data, encoding: .utf8)
        guard let text else {
            await logger.logError(ErrorMessage.canNotDecodeData)
            return
        }
        // we control newlines and whitespaces in the logger
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        await logger.log(trimmedText)
    }
}
