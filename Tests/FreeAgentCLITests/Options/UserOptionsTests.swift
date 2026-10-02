import Foundation
import FreeAgentAPI
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct UserOptionsTests {

    // MARK: Internal

    @Test("uses --user without asking FreeAgent")
    func explicitUser() async throws {
        let transport = MockClientTransportInterface()
        let options = try UserOptions.parse(["--user", "119"])

        let id = try await options.id(client: client(transport))

        #expect(id == "119")
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .any).called(0)
    }

    @Test("takes a user URL as its ID without asking FreeAgent")
    func explicitUserURL() async throws {
        let transport = MockClientTransportInterface()
        let options = try UserOptions.parse(["--user", "https://api.freeagent.com/v2/users/119"])

        let id = try await options.id(client: client(transport))

        #expect(id == "119")
        verify(transport).send(.any, body: .any, baseURL: .any, operationID: .any).called(0)
    }

    @Test("falls back to the ID of the logged-in user")
    func currentUser() async throws {
        let transport = MockClientTransportInterface()
        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .value("showCurrentUser"))
            .willReturn((
                HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]),
                HTTPBody(Data(#"{"user":{"url":"https://api.sandbox.freeagent.com/v2/users/32382"}}"#.utf8))
            ))
        let options = try UserOptions.parse([])

        let id = try await options.id(client: client(transport))

        #expect(id == "32382")
    }

    // MARK: Private

    private func client(_ transport: MockClientTransportInterface) -> Client {
        Client(serverURL: Environment.sandbox.baseURL, transport: transport)
    }
}
