import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateDeleteItemCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-item",
        abstract: "Delete an estimate item"
    )

    @Argument(help: "Estimate item ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete estimate item \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteEstimateItem.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deleteEstimateItem(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted estimate item \(id)"
    }
}
