import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct CreditNoteUpdateItemCommandTests {

    // MARK: Internal

    @Test("reads the credit note first when no type is given, so FreeAgent does not clear it")
    func readsCurrentItemType() async throws {
        let transport = transport()
        let command = try CreditNoteUpdateItemCommand.parse(["779164", "1390616", "--price", "-50"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCreditNote")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateCreditNote")).called(1)
    }

    @Test("uses --item-type without reading the credit note")
    func explicitItemType() async throws {
        let transport = transport()
        let command = try CreditNoteUpdateItemCommand.parse(["779164", "1390616", "--item-type", "Hours"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCreditNote")).called(0)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateCreditNote")).called(1)
    }

    // MARK: Private

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .any)
            .willProduce { _, _, _, _ in
                (
                    HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                    HTTPBody(Data(#"{"credit_note":{"url":"https://api.freeagent.com/v2/credit_notes/779164"}}"#.utf8))
                )
            }

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }
}
