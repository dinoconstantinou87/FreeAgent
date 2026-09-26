import ArgumentParser
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct APIErrorCommandErrorTests {

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
        #expect(APIError(kind: kind).exitCode == ExitCode(code))
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
        let codes = kinds.map { APIError(kind: $0).exitCode }

        #expect(Set(codes).count == kinds.count)
        #expect(!codes.contains(.failure))
        #expect(!codes.contains(.success))
        #expect(!codes.contains(.validationFailure))
    }

    @Test("renders the status and the message from FreeAgent")
    func rendersStatusAndMessage() {
        let error = APIError(status: 400, messages: ["Invalid date supplied: not-a-date"])

        #expect(error.errorDescription == "FreeAgent rejected the request (HTTP 400): Invalid date supplied: not-a-date")
    }

    @Test("omits the status when there is none")
    func omitsAbsentStatus() {
        #expect(APIError(kind: .unauthenticated).errorDescription == "Not authenticated with FreeAgent")
    }

    @Test("lists several messages from FreeAgent as takeaways")
    func listsSeveralMessages() {
        let error = APIError(status: 422, messages: ["Contact can't be blank", "Dated on can't be blank"])

        #expect(error.errorDescription == "FreeAgent rejected the request (HTTP 422)")
        #expect(error.takeaways.map { $0.plain() } == ["Contact can't be blank", "Dated on can't be blank"])
    }

    @Test("tells an unauthenticated user how to log in")
    func signpostsLogin() {
        #expect(APIError(kind: .unauthenticated).takeaways.map { $0.plain() } == ["Run 'freeagent auth login'"])
    }

    @Test("warns against blind retries when the outcome is unknown")
    func warnsOnUnknownOutcome() {
        #expect(APIError(kind: .unknownOutcome).takeaways.isEmpty == false)
    }

}
