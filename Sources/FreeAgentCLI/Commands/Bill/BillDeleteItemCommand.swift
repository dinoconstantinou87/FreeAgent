import ArgumentParser
import Foundation
import FreeAgentAPI

struct BillDeleteItemCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-item",
        abstract: "Delete a bill item",
        discussion: "A bill with payments cannot lose its items."
    )

    @Argument(help: "Bill ID or URL")
    var bill: ResourceID

    @Argument(help: "Bill item ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    var confirmation: String {
        "Delete bill item \(id)?"
    }

    func perform(client: Client) async throws -> Components.Schemas.BillResponse {
        let itemPayload = Components.Schemas.BillItemPayload(
            url: id.value,
            _destroy: 1
        )

        let input = Operations.UpdateBill.Input(
            path: .init(id: bill.value),
            body: .json(.init(bill: .init(billItems: [itemPayload])))
        )

        return try await client.updateBill(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.BillResponse) -> String {
        "Deleted bill item \(id)"
    }
}
