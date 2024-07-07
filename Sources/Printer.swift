import ConcurrencyExtras
#if os(Linux)
// Linux implementation of FileHandle not Sendable
@preconcurrency import Foundation
#else
import Foundation
#endif

final class Printer: Sendable {
    private let fileHandle: LockIsolated<FileHandle>
    private let buffer = LockIsolated(String())
    private let _wasWritten = LockIsolated(false)

    var wasWritten: Bool {
        _wasWritten.value
    }

    init(fileHandle: FileHandle) {
        self.fileHandle = .init(fileHandle)
    }

    @discardableResult
    func writeln(_ text: String) -> Self {
        buffer.withValue { $0 += text + "\n" }
        return self
    }

    @discardableResult
    func write(_ text: String) -> Self {
        buffer.withValue { $0 += text }
        return self
    }

    @discardableResult
    func cursorToColumn(_ column: Int) -> Self {
        buffer.withValue { $0 += ANSI.cursorToColumn(column) }
        return self
    }

    @discardableResult
    func cursorUp(_ count: Int = 1) -> Self {
        buffer.withValue { $0 += ANSI.cursorUp(count) }
        return self
    }

    @discardableResult
    func eraseLine() -> Self {
        buffer.withValue { $0 += ANSI.eraseLine }
        return self
    }

    func flush() {
        fileHandle.withValue {
            $0.write(buffer.value.data(using: .utf8)!)
            try? $0.synchronize()
        }
        if !_wasWritten.value {
            _wasWritten.setValue(true)
        }
        buffer.setValue(String())
    }
}
