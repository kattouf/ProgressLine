enum ANSI {
    // Cursor controls
    static func cursorUp(_ count: Int) -> String {
        "\u{1B}[\(count)A"
    }

    static func cursorToColumn(_ column: Int) -> String {
        "\u{1B}[\(column)G"
    }

    static let eraseLine = "\u{1B}[2K"

    // Colors and styles
    static let noStyleMode = !isTTY
    static var red: String {
        noStyleMode ? "" : "\u{1B}[31m"
    }

    static var green: String {
        noStyleMode ? "" : "\u{1B}[32m"
    }

    static var yellow: String {
        noStyleMode ? "" : "\u{1B}[33m"
    }

    static var blue: String {
        noStyleMode ? "" : "\u{1B}[34m"
    }

    static var magenta: String {
        noStyleMode ? "" : "\u{1B}[35m"
    }

    static var bold: String {
        noStyleMode ? "" : "\u{1B}[1m"
    }

    static var reset: String {
        noStyleMode ? "" : "\u{1B}[0m"
    }
}
