import Foundation
import Sake

@main
@CommandGroup
struct Commands: SakeApp {
    public static var hello: Command {
        Command(
            run: { _ in
                print("Hello, world!")
            }
        )
    }
}