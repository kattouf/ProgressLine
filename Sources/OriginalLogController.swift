import Foundation

final actor OriginalLogController {
    private let logger: UnderProgressLineLogger
    let path: String
    private var buffer = ""

    init(logger: UnderProgressLineLogger, path: String) {
        self.logger = logger
        self.path = path
    }

    func didGetStdinDataChunk(_ data: Data) async {
        let text = String(data: data, encoding: .utf8)
        guard let text else {
            await logger.logError(ErrorMessage.canNotDecodeData)
            return
        }
        buffer.append(text)
    }

    func didReachEndOfStdin() throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try buffer.write(to: url, atomically: true, encoding: .utf8)
    }
}
