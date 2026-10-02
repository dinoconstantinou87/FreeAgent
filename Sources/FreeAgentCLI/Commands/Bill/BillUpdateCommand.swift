import ArgumentParser
import Foundation
import FreeAgentAPI

struct BillUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a bill",
        discussion: "A bill with payments cannot change its locked attributes, such as its contact, reference or date."
    )

    @Argument(help: "Bill ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Contact ID or URL")
    var contact: ResourceID?

    @Option(name: .long, help: "Bill reference")
    var reference: String?

    @Option(name: .long, help: "Date of the bill (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String?

    @Option(name: .long, help: "Comments, or an empty string to remove them")
    var comments: String?

    @Option(name: .long, help: "Project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "How often the bill recurs")
    var recurring: Components.Schemas.BillRecurringPeriod?

    @Option(name: .long, help: "Date the bill stops recurring (YYYY-MM-DD)")
    var recurringEndDate: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.BillResponse {
        let billPayload = Components.Schemas.BillUpdatePayload(
            contact: contact?.value,
            reference: reference,
            datedOn: datedOn,
            dueOn: dueOn,
            comments: comments,
            project: project?.value,
            recurring: recurring,
            recurringEndDate: recurringEndDate
        )

        let input = Operations.UpdateBill.Input(
            path: .init(id: id.value),
            body: .json(.init(bill: billPayload))
        )

        return try await client.updateBill(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.BillResponse) -> String {
        "Updated bill \(id)"
    }
}
