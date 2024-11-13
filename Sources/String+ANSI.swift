import Foundation

extension String {
    private static let ansiRegex = try! NSRegularExpression(pattern: "\u{1B}(?:[@-Z\\-_]|\\[[0-?]*[ -/]*[@-~])")

    func withoutANSI() -> String {
        let range = NSRange(startIndex ..< endIndex, in: self)
        return Self.ansiRegex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
}
