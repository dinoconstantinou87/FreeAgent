import ArgumentParser
import Foundation

struct UnexpectedError: CommandError {
    let underlying: any Error

    var errorDescription: String? {
        "Failed to execute command: \((underlying as? LocalizedError)?.errorDescription ?? String(describing: underlying))"
    }

    var exitCode: ExitCode {
        .failure
    }
}
