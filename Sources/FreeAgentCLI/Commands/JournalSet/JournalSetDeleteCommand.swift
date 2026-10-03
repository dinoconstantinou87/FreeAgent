import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a journal set"
    )

    @Argument(help: "Journal set ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete journal set \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteJournalSet.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deleteJournalSet(input).ok

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted journal set \(id)"
    }
}
