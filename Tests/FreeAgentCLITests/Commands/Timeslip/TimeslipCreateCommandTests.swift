import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct TimeslipCreateCommandTests {

    // MARK: Internal

    @Test("looks up the logged-in user when no user is given")
    func currentUser() async throws {
        let transport = transport()
        let command = try TimeslipCreateCommand.parse(["--task", "36215", "--dated-on", "2026-10-02"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser")).called(1)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("createTimeslip")).called(1)
    }

    @Test("uses --user without looking up the logged-in user")
    func explicitUser() async throws {
        let transport = transport()
        let command = try TimeslipCreateCommand.parse(["--task", "36215", "--dated-on", "2026-10-02", "--user", "32382"])

        _ = try await command.perform(client: client(transport))

        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser")).called(0)
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .value("createTimeslip")).called(1)
    }

    // MARK: Private

    private func transport() -> MockClientTransportInterface {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"{"user":{"url":"https://api.freeagent.com/v2/users/32382"}}"#.utf8))
            ))
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("createTimeslip"))
            .willReturn((
                HTTPResponse(status: .created, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"{"timeslip":{"url":"https://api.freeagent.com/v2/timeslips/166910"}}"#.utf8))
            ))

        return transport
    }

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }
}
