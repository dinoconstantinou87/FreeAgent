import ArgumentParser
import FreeAgentAPI

struct UserOptions: ParsableArguments {
    @Option(name: .customLong("user"), help: "User ID or URL, e.g. 32382 - defaults to the logged-in user")
    var id: ResourceID?

    func id(client: Client) async throws -> String {
        if let id {
            return id.value
        }

        return try await ResourceID(client.showCurrentUser(.init()).ok.body.json.user.url).value
    }
}
