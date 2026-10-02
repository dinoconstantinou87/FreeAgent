import ArgumentParser
import Foundation
import FreeAgentAPI

struct BillCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new bill"
    )

    @Option(name: .long, help: "Contact ID or URL")
    var contact: ResourceID

    @Option(name: .long, help: "Date of the bill (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String

    @Option(name: .long, help: "Bill reference")
    var reference: String

    @Option(name: .long, help: "Comments")
    var comments: String?

    @Option(name: .long, help: "Category ID or URL for the bill item, e.g. 285")
    var category: ResourceID

    @Option(name: .long, help: "Description of the bill item")
    var description: String

    @Option(name: .long, help: "Total value including VAT")
    var totalValue: String

    @Option(name: .long, help: "Sales tax rate (e.g. 20.0)")
    var salesTaxRate: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.BillResponse {
        let billItem = Components.Schemas.BillItemPayload(
            category: category.value,
            description: description,
            totalValue: totalValue,
            salesTaxRate: salesTaxRate
        )

        let billPayload = Components.Schemas.BillCreatePayload(
            contact: contact.value,
            reference: reference,
            datedOn: datedOn,
            dueOn: dueOn,
            comments: comments,
            billItems: [billItem]
        )

        let input = Operations.CreateBill.Input(
            body: .json(.init(bill: billPayload))
        )

        return try await client.createBill(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.BillResponse) -> String {
        "Created bill \(response.bill.url)"
    }
}
