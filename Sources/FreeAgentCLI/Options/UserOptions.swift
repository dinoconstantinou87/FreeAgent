import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserOptions: ParsableArguments {
    @Option(name: .long, help: "User ID, e.g. 32382 - defaults to the logged-in user")
    var user: String?

    func id(client: Client) async throws -> String {
        if let user {
            return user
        }

        let url = try await client.showCurrentUser(.init()).ok.body.json.user.url
        return URL(string: url)?.lastPathComponent ?? url
    }
}
