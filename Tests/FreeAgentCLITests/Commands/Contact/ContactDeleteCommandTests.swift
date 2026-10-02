import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ContactDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 403 by naming the records the contact has")
    func hasRecords() async throws {
        let transport = transport(
            deleting: .forbidden,
            listing: [
                "listInvoices": #"{"invoices":[]}"#,
                "listBills": #"{"bills":[{"url":"https://api.freeagent.com/v2/bills/348117"}]}"#,
                "listEstimates": #"{"estimates":[]}"#,
                "listProjects": #"{"projects":[{"url":"https://api.freeagent.com/v2/projects/51583"}]}"#,
            ]
        )
        let command = try ContactDeleteCommand.parse(["259824", "--yes"])

        let error = await #expect(throws: ContactDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Contact 259824 has bills and projects, so it cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Hide it instead with 'freeagent contact update 259824 --status Hidden'"
        ])
    }

    @Test("leaves a 403 alone when the contact has no records")
    func forbiddenWithoutRecords() async throws {
        let transport = transport(
            deleting: .forbidden,
            listing: [
                "listInvoices": #"{"invoices":[]}"#,
                "listBills": #"{"bills":[]}"#,
                "listEstimates": #"{"estimates":[]}"#,
                "listProjects": #"{"projects":[]}"#,
            ]
        )
        let command = try ContactDeleteCommand.parse(["259824", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .forbidden)
    }

    @Test("leaves other API errors alone without listing records")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, listing: [:])
        let command = try ContactDeleteCommand.parse(["259824", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        for operation in ["listInvoices", "listBills", "listEstimates", "listProjects"] {
            verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value(operation)).called(0)
        }
    }

    // MARK: Private

    private func transport(
        deleting status: HTTPResponse.Status,
        listing bodies: [String: String]
    ) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteContact"))
            .willReturn((HTTPResponse(status: status), nil))

        for (operation, body) in bodies {
            given(transport)
                .send(.any, body: .any, baseURL: .any, operationID: .value(operation))
                .willReturn((
                    HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                    HTTPBody(Data(body.utf8))
                ))
        }

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport, middlewares: [.apiError()])
    }
}
