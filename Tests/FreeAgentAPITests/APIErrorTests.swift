import Foundation
import Testing

@testable import FreeAgentAPI

struct APIErrorTests {

    @Test(
        "maps HTTP status onto a kind",
        arguments: [
            (401, APIError.Kind.unauthenticated),
            (403, .forbidden),
            (404, .notFound),
            (429, .rateLimited),
            (400, .rejected),
            (409, .rejected),
            (422, .rejected),
            (410, .rejected),
            (500, .serverError),
            (503, .serverError),
            (302, .unexpected),
        ]
    )
    func mapsStatusToKind(status: Int, kind: APIError.Kind) {
        #expect(APIError(status: status).kind == kind)
    }

    @Test("decodes the message FreeAgent nests under errors.error")
    func decodesNestedObjectMessage() {
        let data = Data(#"{"errors":{"error":{"message":"Resource not found"}}}"#.utf8)

        #expect(APIError.messages(from: data) == ["Resource not found"])
    }

    @Test("decodes every message FreeAgent lists under errors")
    func decodesListedMessages() {
        let data = Data(#"{"errors":[{"message":"first_name can't be blank"},{"message":"bad email"}]}"#.utf8)

        #expect(APIError.messages(from: data) == ["first_name can't be blank", "bad email"])
    }

    @Test("decodes a single listed message")
    func decodesSingleListedMessage() {
        let data = Data(#"{"errors":[{"message":"Contact not found for this company"}]}"#.utf8)

        #expect(APIError.messages(from: data) == ["Contact not found for this company"])
    }

    @Test("returns no messages when the body does not match the spec", arguments: [
        #"{"errors":{}}"#,
        #"{"errors":{"error":{}}}"#,
        #"{"errors":[]}"#,
        #"{"something":"else"}"#,
        "not json at all",
        "",
    ])
    func returnsNoMessagesForUnrecognisedBody(body: String) {
        #expect(APIError.messages(from: Data(body.utf8)).isEmpty)
    }

    @Test("carries the status alongside the decoded messages")
    func carriesStatusAndMessages() {
        let error = APIError(status: 400, messages: ["Invalid date supplied: not-a-date"])

        #expect(error.kind == .rejected)
        #expect(error.status == 400)
        #expect(error.messages == ["Invalid date supplied: not-a-date"])
    }

    @Test("has no status when built from a kind alone")
    func hasNoStatusWhenBuiltFromKind() {
        let error = APIError(kind: .unauthenticated)

        #expect(error.status == nil)
        #expect(error.messages.isEmpty)
    }

}
