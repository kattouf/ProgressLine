import Foundation

final actor OriginalLogController {
    let path: String
    private var buffer = ""

    init(path: String) {
        self.path = path
    }

    func didGetStdinDataChunk(_ data: Data) {
        // TODO: handle decoding error
        buffer.append(String(data: data, encoding: .utf8)!)
    }

    func didReachEndOfStdin() throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try buffer.write(to: url, atomically: true, encoding: .utf8)
    }
}
