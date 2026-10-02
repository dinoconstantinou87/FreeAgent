import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct ProjectDeleteCommandTests {

    // MARK: Internal

    @Test("explains a 409 by naming the records the project has")
    func hasRecords() async throws {
        let transport = transport(
            deleting: .conflict,
            listing: Self.empty.merging([
                "listTasks": #"{"tasks":[{"url":"https://api.freeagent.com/v2/tasks/43314"}]}"#,
                "listTimeslips": #"{"timeslips":[{"url":"https://api.freeagent.com/v2/timeslips/166946"}]}"#,
            ]) { $1 },
            deletable: false
        )
        let command = try ProjectDeleteCommand.parse(["51614", "--yes"])

        let error = await #expect(throws: ProjectDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Project 51614 has tasks and timeslips, so it cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
        #expect(error?.takeaways.map { $0.plain() } == [
            "Mark it finished instead with 'freeagent project update 51614 --status Completed'"
        ])
    }

    @Test("falls back to is_deletable when no list finds the records")
    func notDeletable() async throws {
        let transport = transport(deleting: .conflict, listing: Self.empty, deletable: false)
        let command = try ProjectDeleteCommand.parse(["51621", "--yes"])

        let error = await #expect(throws: ProjectDeleteCommandError.self) {
            try await command.perform(client: client(transport))
        }

        #expect(error?.errorDescription == "Project 51621 has records, so it cannot be deleted")
        #expect(error?.exitCode == ExitCode(4))
    }

    @Test("leaves a 409 alone when the project is deletable")
    func conflictWhenDeletable() async throws {
        let transport = transport(deleting: .conflict, listing: Self.empty, deletable: true)
        let command = try ProjectDeleteCommand.parse(["51621", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.status == 409)
    }

    @Test("leaves other API errors alone without reading the project")
    func otherErrors() async throws {
        let transport = transport(deleting: .notFound, listing: [:], deletable: nil)
        let command = try ProjectDeleteCommand.parse(["51621", "--yes"])

        let error = await #expect(throws: (any Error).self) {
            try await command.perform(client: client(transport))
        }

        #expect(error.flatMap(APIError.from)?.kind == .notFound)
        for operation in Array(Self.empty.keys) + ["showProject"] {
            verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value(operation)).called(0)
        }
    }

    // MARK: Private

    private static let empty = [
        "listTasks": #"{"tasks":[]}"#,
        "listTimeslips": #"{"timeslips":[]}"#,
        "listInvoices": #"{"invoices":[]}"#,
        "listEstimates": #"{"estimates":[]}"#,
        "listAllExpenses": #"{"expenses":[]}"#,
        "listBills": #"{"bills":[]}"#,
    ]

    private func transport(
        deleting status: HTTPResponse.Status,
        listing bodies: [String: String],
        deletable: Bool?
    ) -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("deleteProject"))
            .willReturn((HTTPResponse(status: status), nil))

        var bodies = bodies
        if let deletable {
            bodies["showProject"] = #"{"project":{"url":"https://api.freeagent.com/v2/projects/1","is_deletable":\#(deletable)}}"#
        }

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
