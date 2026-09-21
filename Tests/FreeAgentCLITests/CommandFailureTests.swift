import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct CommandFailureTests {

    @Test(
        "maps each error kind onto its documented exit code",
        arguments: [
            (APIError.Kind.unauthenticated, Int32(2)),
            (.notFound, 3),
            (.rejected, 4),
            (.forbidden, 5),
            (.rateLimited, 6),
            (.serverError, 7),
            (.unknownOutcome, 8),
            (.unexpected, 1),
        ]
    )
    func mapsKindToExitCode(kind: APIError.Kind, code: Int32) {
        #expect(CommandFailure(APIError(kind: kind)).exitCode == ExitCode(code))
    }

    @Test("every kind gets a distinct exit code except the catch-all")
    func exitCodesAreDistinct() {
        let kinds: [APIError.Kind] = [
            .unauthenticated,
            .notFound,
            .rejected,
            .forbidden,
            .rateLimited,
            .serverError,
            .unknownOutcome,
        ]
        let codes = kinds.map { CommandFailure(APIError(kind: $0)).exitCode }

        #expect(Set(codes).count == kinds.count)
        #expect(!codes.contains(.failure))
        #expect(!codes.contains(.success))
        #expect(!codes.contains(.validationFailure))
    }

    @Test("renders the status and the message from FreeAgent")
    func rendersStatusAndMessage() {
        let failure = CommandFailure(APIError(status: 400, messages: ["Invalid date supplied: not-a-date"]))

        #expect(
            failure.alert.message.plain()
                == "FreeAgent rejected the request (HTTP 400): Invalid date supplied: not-a-date"
        )
    }

    @Test("omits the status when there is none")
    func omitsAbsentStatus() {
        let failure = CommandFailure(APIError(kind: .unauthenticated))

        #expect(failure.alert.message.plain() == "Not authenticated with FreeAgent")
    }

    @Test("tells an unauthenticated user how to log in")
    func signpostsLogin() {
        let failure = CommandFailure(APIError(kind: .unauthenticated))

        #expect(failure.alert.takeaways.map { $0.plain() } == ["Run 'freeagent auth login'"])
    }

    @Test("warns against blind retries when the outcome is unknown")
    func warnsOnUnknownOutcome() {
        let failure = CommandFailure(APIError(kind: .unknownOutcome))

        #expect(failure.alert.takeaways.isEmpty == false)
    }

    @Test("unwraps the APIError that the runtime wrapped in a ClientError")
    func unwrapsClientError() {
        let wrapped = ClientError(
            operationID: "showInvoice",
            operationInput: "input",
            causeDescription: "Middleware threw an error.",
            underlyingError: APIError(status: 404, messages: ["Resource not found"])
        )

        let failure = CommandFailure(wrapped)

        #expect(failure.exitCode == ExitCode(3))
        #expect(failure.alert.message.plain() == "FreeAgent has no such record (HTTP 404): Resource not found")
    }

    @Test("refuses an unconfirmed destructive command as a usage error")
    func refusesWithoutConfirmation() {
        let failure = CommandFailure(CommandRefusal.notInteractive)

        #expect(failure.exitCode == .validationFailure)
        #expect(failure.alert.message.plain() == "Confirmation required when not running interactively")
        #expect(
            failure.alert.takeaways.map { $0.plain() } == [
                "Pass '--yes' to confirm",
                "Pass '--dry-run' to preview the request instead",
            ]
        )
    }

    @Test("reports a command that declined to run as a plain failure")
    func reportsDeclinedCommand() {
        let failure = CommandFailure(CommandRefusal.declined)

        #expect(failure.exitCode == .failure)
        #expect(failure.alert.message.plain() == "Cancelled, nothing was changed")
    }

    @Test("falls back to a generic failure for errors that are not from the API")
    func fallsBackForOtherErrors() {
        struct Boom: Error { }

        let failure = CommandFailure(Boom())

        #expect(failure.exitCode == .failure)
        #expect(failure.alert.message.plain().hasPrefix("Failed to execute command:"))
    }

}
