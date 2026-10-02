import ArgumentParser
import FreeAgentAPI

struct UserOptions: ParsableArguments {
    @Option(name: .long, help: "User ID or URL, e.g. 32382 - defaults to the logged-in user")
    var user: ResourceID?

    func id(client: Client) async throws -> String {
        if let user {
            return user.value
        }

        return try await ResourceID(client.showCurrentUser(.init()).ok.body.json.user.url).value
    }
}
