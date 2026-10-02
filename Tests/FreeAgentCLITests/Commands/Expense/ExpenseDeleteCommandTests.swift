import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ExpenseDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 as an expense rebilled on an invoice, naming the invoice")
    func rebilled() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140","rebilled_on_invoice":"https://api.freeagent.com/v2/invoices/779271"}}"#
        )
        let command = try ExpenseDeleteCommand.parse(["577140", "--yes"])

        let error = await #expect(throws: ExpenseDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?
            .errorDescription == "Expense 577140 is rebilled on invoice 779271, and a rebilled expense cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Remove the expense's line from invoice 779271 in FreeAgent",
            "Or run 'freeagent invoice delete 779271', which unbills every expense on it",
        ])
    }

    @Test("leaves a 409 alone when the expense is not rebilled")
    func conflictWithoutInvoice() async throws {
        let transport = transport(
            deleting: .conflict,
            showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140"}}"#
        )
        let command = try ExpenseDeleteCommand.parse(["577140", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.status == 409)
    }

    @Test("leaves other API errors alone without reading the expense")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, showing: "{}")
        let command = try ExpenseDeleteCommand.parse(["577140", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("getASingleExpense")).called(0)
    }

    // MARK: Private

    private func transport(deleting status: HTTPResponse.Status, showing body: String) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteExpense"))
            .willReturn((HTTPResponse(status: status), nil))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("getASingleExpense"))
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
