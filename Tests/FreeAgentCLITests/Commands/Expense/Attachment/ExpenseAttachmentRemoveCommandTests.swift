import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ExpenseAttachmentRemoveCommandTests {

    // MARK: Internal

    @Test("removes the attachment from an expense with one")
    func removes() async throws {
        let transport = transport(
            showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140","attachment":{"url":"https://api.freeagent.com/v2/attachments/183146"}}}"#
        )
        let command = try ExpenseAttachmentRemoveCommand.parse(["577140", "--yes"])

        let response = try await command.perform(client: client(transport))

        #expect(command.success(for: response) == "Removed the attachment from expense 577140")
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateExpense")).called(1)
    }

    @Test("refuses an expense with no attachment as not found")
    func noAttachment() async throws {
        let transport = transport(showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140"}}"#)
        let command = try ExpenseAttachmentRemoveCommand.parse(["577140", "--yes"])

        let error = await #expect(throws: ExpenseAttachmentRemoveCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Expense 577140 has no attachment")
        #expect(error?.exitCode == ExitCode(3))
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateExpense")).called(0)
    }

    // MARK: Private

    private func transport(showing body: String) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("getASingleExpense"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(body.utf8))
            ))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("updateExpense"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140"}}"#.utf8))
            ))

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport, middlewares: [.apiError()])
    }
}
