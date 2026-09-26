import ArgumentParser
import FreeAgentAPI
import Noora

extension AuthError: CommandError {

    // MARK: Public

    public var errorDescription: String? {
        let summary =
            switch self {
            case .unauthenticated: kind.summary
            case .denied, .declined: "FreeAgent rejected the authorization request"
            case .unexpected: "FreeAgent returned an unexpected response while authenticating"
            }

        return message.map { "\(summary): \($0)" } ?? summary
    }

    // MARK: Internal

    var exitCode: ExitCode {
        kind.exitCode
    }

    var takeaways: [TerminalText] {
        kind.takeaways
    }

    // MARK: Private

    private var kind: APIError.Kind {
        switch self {
        case .unauthenticated: .unauthenticated
        case .denied, .declined: .rejected
        case .unexpected: .unexpected
        }
    }
}
