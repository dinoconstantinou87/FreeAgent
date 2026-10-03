import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct UserShowCommandTests {

    // MARK: Internal

    @Test("shows the logged-in user when no ID is given")
    func currentUser() async throws {
        let transport = transport()
        let command = try UserShowCommand.parse([])

        _ = try await command.fetch(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showUser")).called(0)
    }

    @Test("shows the user with the given ID")
    func userByID() async throws {
        let transport = transport()
        let command = try UserShowCommand.parse(["43088"])

        _ = try await command.fetch(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showUser")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser")).called(0)
    }

    // MARK: Private

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        for operationID in ["showCurrentUser", "showUser"] {
            given(transport)
                .send(.any, body: .any, baseURL: .any, operationID: .value(operationID))
                .willReturn((
                    HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                    HTTPBody(Data(#"{"user":{"url":"https://api.freeagent.com/v2/users/32382"}}"#.utf8))
                ))
        }

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }
}
