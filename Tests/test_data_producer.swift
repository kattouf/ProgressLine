/*
 Generates test data for the app.
 Features:
 - iterates over the given number and prints the iteration number
 - prints with a delay if the delay is greater than 0
 - can produce a given number of lines per iteration
 Usage:
    test_data_producer.swift <iterations> [<delay in ms>] [<lines>]
 */

import Foundation

struct Configuration: Decodable {
    let chunkCount: Int
    let chunkSize: Int
    let writeDelay: TimeInterval

    enum CodingKeys: String, CodingKey {
        case chunkCount = "chunk_count"
        case chunkSize = "chunk_size"
        case writeDelay = "write_delay"
    }
}

let arguments = CommandLine.arguments.dropFirst()
guard arguments.count >= 1 else {
    print("Usage: \(CommandLine.arguments.first!) <configuration file path>")
    exit(1)
}

let filePath = arguments.first!
let configuration = try JSONDecoder().decode(Configuration.self, from: try Data(contentsOf: URL(fileURLWithPath: filePath)))

for i in 0 ..< configuration.chunkCount {
    let data = (0 ..< configuration.chunkSize)
        .map { "Chunk number: \(i + 1), Chunk Line: \($0 + 1)" }
        .joined(separator: "\n")
    print(data)
    fflush(stdout)
    if configuration.writeDelay > 0 {
        usleep(useconds_t(configuration.writeDelay * 1000))
    }
}
