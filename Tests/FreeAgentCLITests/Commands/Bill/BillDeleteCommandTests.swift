import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct BillDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 as a bill with payments")
    func hasPayments() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"bill":{"url":"https://api.freeagent.com/v2/bills/348104","paid_value":"120.0"}}"#
        )
        let command = try BillDeleteCommand.parse(["348104", "--yes"])

        let error = await #expect(throws: BillDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Bill 348104 has payments, and a bill with payments cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Delete the bank transaction explanations that pay it, then try again"
        ])
    }

    @Test("leaves a 409 alone when the bill has no payments")
    func conflictWithoutPayments() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"bill":{"url":"https://api.freeagent.com/v2/bills/348104","paid_value":"0.0"}}"#
        )
        let command = try BillDeleteCommand.parse(["348104", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.status == 409)
    }

    @Test("leaves other API errors alone without reading the bill")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, showing: "{}")
        let command = try BillDeleteCommand.parse(["348104", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showBill")).called(0)
    }

    // MARK: Private

    private func transport(deleting status: HTTPResponse.Status, showing body: String) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteBill"))
            .willReturn((HTTPResponse(status: status), nil))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("showBill"))
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
