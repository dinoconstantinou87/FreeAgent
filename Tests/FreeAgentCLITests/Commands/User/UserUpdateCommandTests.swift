import ArgumentParser
import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct UserUpdateCommandTests {

    // MARK: Internal

    @Test("updates the logged-in user when no ID is given")
    func currentUser() async throws {
        let transport = transport()
        let command = try UserUpdateCommand.parse(["--first-name", "Jane"])

        let response = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateCurrentUser")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateUser")).called(0)
        #expect(command.success(for: response) == "Updated user 32382")
    }

    @Test("updates the user with the given ID")
    func userByID() async throws {
        let transport = transport()
        let command = try UserUpdateCommand.parse(["43088", "--first-name", "Jane"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateUser")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("updateCurrentUser")).called(0)
    }

    // MARK: Private

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        for operationID in ["updateCurrentUser", "updateUser"] {
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
