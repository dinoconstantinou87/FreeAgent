import Foundation
import FreeAgentAPI
import Mockable
import Testing

@testable import FreeAgentCLI

struct InvoiceSendEmailCommandTests {
    @Test("refuses an unsupported attachment without sending the email")
    func unsupportedAttachment() async throws {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).txt").path
        try Data("timesheet".utf8).write(to: URL(fileURLWithPath: path))

        let transport = MockClientTransportInterface()
        let client = Client(serverURL: Environment.sandbox.baseURL, transport: transport)
        let command = try InvoiceSendEmailCommand.parse(["1234", "--to", "alice@example.com", "--attachment", path])

        await #expect(throws: AttachmentFileError.self) {
            try await command.perform(client: client)
        }

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("sendInvoiceEmail")).called(0)
    }
}
