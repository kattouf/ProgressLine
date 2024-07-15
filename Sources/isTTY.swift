import Foundation

let isTTY = isatty(STDOUT_FILENO) != 0
