import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ExpenseAttachmentAddCommandTests {

    // MARK: Internal

    @Test("adds the attachment to an expense without one")
    func adds() async throws {
        let transport = transport(showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140"}}"#)
        let command = try ExpenseAttachmentAddCommand.parse(["577140", "--file", Self.receipt()])

        let response = try await command.perform(client: client(transport))

        #expect(command.success(for: response) == "Added the attachment to expense 577140")
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateExpense")).called(1)
    }

    @Test("refuses an expense that already has an attachment, naming its file")
    func alreadyAttached() async throws {
        let transport = transport(
            showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140","attachment":{"url":"https://api.freeagent.com/v2/attachments/183146","file_name":"receipt.png"}}}"#
        )
        let command = try ExpenseAttachmentAddCommand.parse(["577140", "--file", Self.receipt()])

        let error = await #expect(throws: ExpenseAttachmentAddCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Expense 577140 already has an attachment, receipt.png")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Run 'freeagent expense attachment remove 577140' first to replace it"
        ])
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateExpense")).called(0)
    }

    @Test("rejects an unsupported file before reading the expense")
    func unsupportedFile() async throws {
        let transport = transport(showing: #"{"expense":{"url":"https://api.freeagent.com/v2/expenses/577140"}}"#)
        let command = try ExpenseAttachmentAddCommand.parse(["577140", "--file", "notes.txt"])

        await #expect(throws: AttachmentFileError.self) {
            try await command.perform(client: client(transport))
        }

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("getASingleExpense")).called(0)
    }

    // MARK: Private

    private static func receipt() throws -> String {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf").path
        try Data("%PDF".utf8).write(to: URL(fileURLWithPath: path))
        return path
    }

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
