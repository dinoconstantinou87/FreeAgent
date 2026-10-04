import ArgumentParser
import Foundation
import FreeAgentAPI

struct PriceListItemDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a price list item"
    )

    @Argument(help: "Price list item ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete price list item \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeletePriceListItem.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deletePriceListItem(input).ok

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted price list item \(id)"
    }
}
