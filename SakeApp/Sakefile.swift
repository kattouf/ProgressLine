import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {
    public static let configuration = SakeAppConfiguration(
        commandGroups: [
            TestCommands.self
        ]
    )
}

@CommandGroup
struct TestCommands {
    public static var test: Command {
        Command(
            description: "Run tests",
            dependencies: [ensureDebugBuildIsUpToDate],
            run: { context in
                try runAndPrint(bash: "\(context.projectRoot)/Tests/integration_tests.sh \(context.projectRoot)/.build/debug/progressline")
            }
        )
    }

    private static var ensureDebugBuildIsUpToDate: Command {
        Command(
            description: "Ensure debug build is up to date",
            run: { context in
                try runAndPrint(bash: "swift build --package-path \(context.projectRoot)")
            }
        )
    }
}

extension Command.Context {
    var projectRoot: String {
        "\(appDirectory)/.."
    }
}
