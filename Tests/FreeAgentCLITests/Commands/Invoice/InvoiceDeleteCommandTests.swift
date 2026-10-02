import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct InvoiceDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 on an invoice with payments")
    func hasPayments() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"invoice":{"url":"https://api.freeagent.com/v2/invoices/779246","status":"Paid","paid_value":"120.0"}}"#
        )
        let command = try InvoiceDeleteCommand.parse(["779246", "--yes"])

        let error = await #expect(throws: InvoiceDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Invoice 779246 has payments, and only a draft can be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Delete the bank transaction explanations that pay it",
            "Then run 'freeagent invoice mark-draft 779246' and try again",
        ])
    }

    @Test("explains a 409 on a written-off invoice")
    func writtenOff() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"invoice":{"url":"https://api.freeagent.com/v2/invoices/779251","status":"Written-off","paid_value":"0.0"}}"#
        )
        let command = try InvoiceDeleteCommand.parse(["779251", "--yes"])

        let error = await #expect(throws: InvoiceDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Invoice 779251 is written off, and only a draft can be deleted")
        #expect(error?.takeaways.map { $0.plain() } == [
            "Run 'freeagent invoice mark-sent 779251' to re-open it",
            "Then run 'freeagent invoice mark-draft 779251' and try again",
        ])
    }

    @Test("explains a 409 on an invoice that is not a draft")
    func notDraft() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"invoice":{"url":"https://api.freeagent.com/v2/invoices/779244","status":"Open","paid_value":"0.0"}}"#
        )
        let command = try InvoiceDeleteCommand.parse(["779244", "--yes"])

        let error = await #expect(throws: InvoiceDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Invoice 779244 is not a draft, and only a draft can be deleted")
        #expect(error?.takeaways.map { $0.plain() } == ["Run 'freeagent invoice mark-draft 779244' first"])
    }

    @Test("leaves a 409 alone when the invoice is a draft")
    func conflictOnDraft() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"invoice":{"url":"https://api.freeagent.com/v2/invoices/779243","status":"Draft","paid_value":"0.0"}}"#
        )
        let command = try InvoiceDeleteCommand.parse(["779243", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.status == 409)
    }

    @Test("leaves other API errors alone without reading the invoice")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, showing: "{}")
        let command = try InvoiceDeleteCommand.parse(["779243", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showInvoice")).called(0)
    }

    // MARK: Private

    private func transport(deleting status: HTTPResponse.Status, showing body: String) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteInvoice"))
            .willReturn((HTTPResponse(status: status), nil))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("showInvoice"))
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
