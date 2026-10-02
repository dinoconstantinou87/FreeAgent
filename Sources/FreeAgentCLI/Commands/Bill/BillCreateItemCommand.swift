import ArgumentParser
import Foundation
import FreeAgentAPI

struct BillCreateItemCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-item",
        abstract: "Create bill item"
    )

    @Argument(help: "Bill ID or URL")
    var bill: ResourceID

    @Option(name: .long, help: "Category ID or URL, e.g. 285")
    var category: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String

    @Option(name: .long, help: "Total value including sales tax")
    var totalValue: String

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 (default: the standard rate)")
    var salesTaxRate: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.BillResponse {
        let itemPayload = Components.Schemas.BillItemPayload(
            url: "",
            category: category.value,
            description: description,
            totalValue: totalValue,
            salesTaxRate: salesTaxRate
        )

        let input = Operations.UpdateBill.Input(
            path: .init(id: bill.value),
            body: .json(.init(bill: .init(billItems: [itemPayload])))
        )

        return try await client.updateBill(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.BillResponse) -> String {
        guard let item = response.bill.billItems?.last else {
            return "Created item on bill \(bill)"
        }

        return "Created item \(item.url) on bill \(bill)"
    }
}
