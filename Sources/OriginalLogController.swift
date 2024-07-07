import Foundation

final actor OriginalLogController {
    private let logger: UnderProgressLineLogger
    let fileHandle: FileHandle

    init?(logger: UnderProgressLineLogger, path: String) async {
        self.logger = logger

        do {
            let url = URL(fileURLWithPath: path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: path, contents: nil)
            self.fileHandle = try FileHandle(forWritingTo: url)
            fileHandle.seekToEndOfFile()
        } catch {
            await logger.logError(ErrorMessage.canNotOpenFile(path))
            return nil
        }
    }

    deinit {
        fileHandle.closeFile()
    }

    func didGetStdinDataChunk(_ data: Data) async {
        fileHandle.write(data)
    }
}
