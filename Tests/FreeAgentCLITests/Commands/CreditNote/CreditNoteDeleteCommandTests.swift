import ArgumentParser
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct CreditNoteDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 as a credit note that is not a draft")
    func notDraft() async throws {
        let command = try CreditNoteDeleteCommand.parse(["779164", "--yes"])

        let error = await #expect(throws: CreditNoteDeleteCommandError.self) {
            try await command.perform(client: client(responding: .conflict))
        }

        #expect(error?.errorDescription == "Credit note 779164 is not a draft, and only a draft can be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == ["Run 'freeagent credit-note mark-draft 779164' first"])
    }

    @Test("leaves other API errors alone")
    func otherErrors() async throws {
        let command = try CreditNoteDeleteCommand.parse(["779164", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(responding: .notFound))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
    }

    // MARK: Private

    private func client(responding status: HTTPResponse.Status) -> Client {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteCreditNote"))
            .willReturn((HTTPResponse(status: status), nil))

        return Client(serverURL: Environment.sandbox.baseURL, transport: transport, middlewares: [.apiError()])
    }
}
