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
    static let red = "\u{1B}[31m"
    static let green = "\u{1B}[32m"
    static let yellow = "\u{1B}[33m"
    static let blue = "\u{1B}[34m"
    static let magenta = "\u{1B}[35m"
    static let bold = "\u{1B}[1m"
    static let reset = "\u{1B}[0m"
}
