import ConcurrencyExtras
import Foundation

final class WindowSizeObserver: Sendable {
    struct Size {
        let width: Int
        let height: Int
    }

    private let signalHandler: LockIsolated<UncheckedSendable<DispatchSourceSignal>?> = .init(nil)
    private let _size: LockIsolated<Size> = .init(getTerminalSize())

    var size: Size {
        _size.value
    }

    static func startObserving() -> WindowSizeObserver {
        let observer = WindowSizeObserver()
        observer.setupSignalHandler()
        return observer
    }

    private func setupSignalHandler() {
        let sigwinch = SIGWINCH

        let signalHandler = DispatchSource.makeSignalSource(signal: sigwinch)
        signal(sigwinch, SIG_IGN)

        signalHandler.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.syncWindowSize()
        }
        signalHandler.resume()

        let uncheckedSendable = UncheckedSendable(signalHandler)
        self.signalHandler.setValue(uncheckedSendable)
    }

    private func syncWindowSize() {
        _size.setValue(Self.getTerminalSize())
    }

    private static func getTerminalSize() -> Size {
        var w = winsize()
        #if os(Linux)
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w)
        #else
        _ = ioctl(STDOUT_FILENO, TIOCGWINSZ, &w)
        #endif
        return Size(width: Int(w.ws_col), height: Int(w.ws_row))
    }
}
