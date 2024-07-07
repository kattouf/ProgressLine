import Foundation

// "Lock" access to printers to prevent write conflicts
final actor PrintersHolder {
    private let printer: Printer
    private let errorsPrinter: Printer

    init(printer: Printer, errorsPrinter: Printer) {
        self.printer = printer
        self.errorsPrinter = errorsPrinter
    }

    func withPrinter<T: Sendable>(_ body: @Sendable (Printer) async throws -> T) async rethrows -> T {
        try await body(printer)
    }

    func withErrorsPrinter<T: Sendable>(_ body: @Sendable (Printer) async throws -> T) async rethrows -> T {
        try await body(errorsPrinter)
    }
}
