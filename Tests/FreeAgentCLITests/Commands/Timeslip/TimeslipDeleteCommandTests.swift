import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct TimeslipDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 as a timeslip billed on an invoice, naming the invoice")
    func billed() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"timeslip":{"url":"https://api.freeagent.com/v2/timeslips/166917","billed_on_invoice":"https://api.freeagent.com/v2/invoices/779182"}}"#
        )
        let command = try TimeslipDeleteCommand.parse(["166917", "--yes"])

        let error = await #expect(throws: TimeslipDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Timeslip 166917 is billed on invoice 779182, and a billed timeslip cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Remove the timeslip's line from invoice 779182 in FreeAgent",
            "Or run 'freeagent invoice delete 779182', which unbills every timeslip on it",
        ])
    }

    @Test("leaves a 409 alone when the timeslip is not billed")
    func conflictWithoutInvoice() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"timeslip":{"url":"https://api.freeagent.com/v2/timeslips/166917"}}"#
        )
        let command = try TimeslipDeleteCommand.parse(["166917", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.status == 409)
    }

    @Test("leaves other API errors alone without reading the timeslip")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, showing: "{}")
        let command = try TimeslipDeleteCommand.parse(["166917", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showTimeslip")).called(0)
    }

    // MARK: Private

    private func transport(deleting status: HTTPResponse.Status, showing body: String) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteTimeslip"))
            .willReturn((HTTPResponse(status: status), nil))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("showTimeslip"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(body.utf8))
            ))

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport, middlewares: [.apiError()])
    }
}
