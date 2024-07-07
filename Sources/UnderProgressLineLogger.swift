import Foundation

final class UnderProgressLineLogger: Sendable {
    private let printers: PrintersHolder

    init(printers: PrintersHolder) {
        self.printers = printers
    }

    func log(_ text: String) async {
        await printers.withPrinter { printer in
            await log(printer: printer, text: text)
        }
    }

    func logError(_ text: String) async {
        await printers.withErrorsPrinter { errorsPrinter in
            await log(printer: errorsPrinter, text: text)
        }
    }

    private func log(printer: Printer, text: String) async {
        if printer.wasWritten {
            printer
                .cursorUp()
                .eraseLine()
        }
        printer
            .writeln(text)
            .writeln("") // Add an empty line after the message for delete it by progress line controller
            .flush()
    }
}
