import ArgumentParser
import Foundation
import Noora
import OpenAPIRuntime

// MARK: - CommandError

protocol CommandError: LocalizedError {
    var exitCode: ExitCode { get }
    var takeaways: [TerminalText] { get }
}

extension CommandError {
    var takeaways: [TerminalText] {
        []
    }

    var alert: ErrorAlert {
        .alert(TerminalText(stringLiteral: errorDescription ?? localizedDescription), takeaways: takeaways)
    }
}

extension Error {
    var commandError: any CommandError {
        switch self {
        case let error as any CommandError: error
        case let error as ClientError: error.underlyingError.commandError
        default: UnexpectedError(underlying: self)
        }
    }
}
