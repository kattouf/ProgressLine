import Foundation

final class MatchesController {
    private let logger: AboveProgressLineLogger
    let regexps: [NSRegularExpression]

    init?(logger: AboveProgressLineLogger, regexps: [String]) async {
        self.logger = logger
        guard !regexps.isEmpty else {
            return nil
        }
        var invalidRegexps = [String]()
        self.regexps = regexps.compactMap { regexp in
            do {
                return try NSRegularExpression(pattern: regexp)
            } catch {
                invalidRegexps.append(regexp)
                return nil
            }
        }
        for invalidRegexp in invalidRegexps {
            await logger.logError(ErrorMessage.canNotCompileRegex(invalidRegexp))
        }
    }

    func didGetStdinDataChunk(_ data: Data) async {
        let text = String(data: data, encoding: .utf8)
        guard let text else {
            await logger.logError(ErrorMessage.canNotDecodeData)
            return
        }
        for line in text.split(whereSeparator: \.isNewline) {
            let range = NSRange(location: 0, length: line.utf16.count)
            for regex in regexps {
                if regex.firstMatch(in: String(line), range: range) != nil {
                    await logger.log(String(line))
                    break
                }
            }
        }
    }
}
