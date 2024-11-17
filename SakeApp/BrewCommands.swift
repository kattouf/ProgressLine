import Sake
import SwiftShell

@CommandGroup
struct BrewCommands {
    static var ensureGhInstalled: Command {
        Command(
            description: "Ensure gh is installed",
            skipIf: { _ in
                run("which", "gh").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "gh")
            }
        )
    }

    static var ensureGitCliffInstalled: Command {
        Command(
            description: "Ensure git-cliff is installed",
            skipIf: { _ in
                run("which", "git-cliff").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "git-cliff")
            }
        )
    }
}
