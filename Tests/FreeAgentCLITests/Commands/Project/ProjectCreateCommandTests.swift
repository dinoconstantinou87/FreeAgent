import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ProjectCreateCommandTests {

    // MARK: Internal

    @Test("looks up the company's currency when no currency is given")
    func companyCurrency() async throws {
        let transport = transport()
        let command = try ProjectCreateCommand.parse(["--contact", "215832", "--name", "Website"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("companyDetails")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("createProject")).called(1)
    }

    @Test("uses --currency without looking up the company")
    func explicitCurrency() async throws {
        let transport = transport()
        let command = try ProjectCreateCommand.parse(["--contact", "215832", "--name", "Website", "--currency", "USD"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("companyDetails")).called(0)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("createProject")).called(1)
    }

    // MARK: Private

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("companyDetails"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"""
                {"company":{"url":"https://api.freeagent.com/v2/company","name":"Acme Technologies Ltd",\#
                "subdomain":"acmetechnologiesltd","type":"UkLimitedCompany","currency":"GBP","mileage_units":"miles",\#
                "company_start_date":"2025-01-01","freeagent_start_date":"2025-01-01","first_accounting_year_end":"2026-01-31"}}
                """#.utf8))
            ))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("createProject"))
            .willReturn((
                HTTPResponse(status: .created, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"{"project":{"url":"https://api.freeagent.com/v2/projects/51622"}}"#.utf8))
            ))

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }
}
