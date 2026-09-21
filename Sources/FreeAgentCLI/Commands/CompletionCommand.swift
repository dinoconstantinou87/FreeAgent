import ArgumentParser
import Noora

struct CompletionCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "completion",
        abstract: "Print the shell completion script"
    )

    @Argument(help: "Shell to print the completion script for")
    var shell: CompletionShell

    func run() {
        StandardOutputPipeline().write(content: FreeAgentCLI.completionScript(for: shell) + "\n")
    }
}
