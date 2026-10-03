import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct JournalSetUpdateCommandTests {

    // MARK: Internal

    @Test("updates without reading the set when no entry is given")
    func withoutEntries() async throws {
        let transport = transport()
        let command = try JournalSetUpdateCommand.parse(["89633", "--description", "Corrected"])

        let response = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showJournalSet")).called(0)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateJournalSet")).called(1)
        #expect(command.success(for: response) == "Updated journal set 89633")
    }

    @Test("reads the set's entries before replacing them")
    func withEntries() async throws {
        let transport = transport()
        let command = try JournalSetUpdateCommand.parse([
            "89633",
            "--entry",
            #"{"category": "250", "debit_value": 7}"#,
            "--entry",
            #"{"category": "999", "debit_value": -7}"#,
        ])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showJournalSet")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateJournalSet")).called(1)
    }

    // MARK: Private

    private static let journalSet = #"""
        {"journal_set":{"url":"https://api.freeagent.com/v2/journal_sets/89633","journal_entries":[
        {"url":"https://api.freeagent.com/v2/journal_sets/89633/journal_entries/366845","category":"https://api.freeagent.com/v2/categories/280","debit_value":"10.0"},
        {"url":"https://api.freeagent.com/v2/journal_sets/89633/journal_entries/366846","category":"https://api.freeagent.com/v2/categories/999","debit_value":"-10.0"}]}}
        """#

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        for operationID in ["showJournalSet", "updateJournalSet"] {
            given(transport)
                .send(.any, body: .any, baseURL: .any, operationID: .value(operationID))
                .willReturn((
                    HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                    HTTPBody(Data(Self.journalSet.utf8))
                ))
        }

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }

}
