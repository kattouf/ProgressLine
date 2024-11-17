enum ErrorMessage {
    static let canNotDecodeData = "\(ANSI.yellow)[!] progressline: Failed to decode stdin data as UTF-8\(ANSI.reset)"
    static func canNotCompileRegex(_ regex: String) -> String {
        "\(ANSI.yellow)[!] progressline: Failed to compile regular expression: \(regex)\(ANSI.reset)"
    }

    static func canNotOpenFile(_ path: String) -> String {
        "\(ANSI.yellow)[!] progressline: Failed to open file at path: \(path)\(ANSI.reset)"
    }
}
