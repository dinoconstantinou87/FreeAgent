import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct BillCreateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new bill"
    )

    @Option(name: .long, help: "Contact URL (e.g. https://api.freeagent.com/v2/contacts/123)")
    var contact: String

    @Option(name: .long, help: "Date of the bill (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String

    @Option(name: .long, help: "Bill reference")
    var reference: String

    @Option(name: .long, help: "Comments")
    var comments: String?

    @Option(name: .long, help: "Category URL for the bill item")
    var category: String

    @Option(name: .long, help: "Description of the bill item")
    var description: String

    @Option(name: .long, help: "Total value including VAT")
    var totalValue: String

    @Option(name: .long, help: "Sales tax rate (e.g. 20.0)")
    var salesTaxRate: String?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let billItem = Components.Schemas.BillItemPayload(
            category: category,
            description: description,
            totalValue: totalValue,
            salesTaxRate: salesTaxRate
        )

        let billPayload = Components.Schemas.BillCreatePayload(
            contact: contact,
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
            .created.body.json.additionalProperties
    }
}
