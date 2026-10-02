import ArgumentParser
import Foundation
import FreeAgentAPI

struct ProjectShowCommand: ShowCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show project details"
    )

    static let title = "Project"

    static var sections: [FieldSection<Components.Schemas.Project>] {
        FieldSection("Details") {
            Field("Name") { .text($0.name) }
            Field("Contact") { .text($0.contactName) }
            Field("Status") { .status($0.status?.rawValue) }
            Field("PO Reference") { .text($0.contractPoReference) }
            Field("IR35") { .flag($0.isIr35) }
            Field("Deletable") { .flag($0.isDeletable) }
        }
        FieldSection("Billing") {
            Field("Currency") { .text($0.currency) }
            Field("Normal Billing Rate") { .currency($0.normalBillingRate, code: $0.currency) }
            Field("Billing Period") { .text($0.billingPeriod?.rawValue) }
            Field("Hours Per Day") { .hours($0.hoursPerDay) }
            Field("Own Invoice Sequence") { .flag($0.usesProjectInvoiceSequence) }
        }
        FieldSection("Budget") {
            Field("Budget") { budget(of: $0) }
            Field("Budget Units") { .text($0.budgetUnits?.rawValue) }
            Field("Unbilled Time In Profitability") { .flag($0.includeUnbilledTimeInProfitability) }
        }
        FieldSection("Dates") {
            Field("Starts On") { .date($0.startsOn) }
            Field("Ends On") { .date($0.endsOn) }
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Project") { .id(url: $0.url) }
            Field("Contact") { .id(url: $0.contact) }
        }
    }

    @Argument(help: "Project ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.ProjectResponse {
        try await client.showProject(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.ProjectResponse) -> Components.Schemas.Project {
        response.project
    }

    // MARK: Private

    private static func budget(of project: Components.Schemas.Project) -> FieldValue {
        guard project.budgetUnits == .monetary else {
            return .number(project.budget)
        }

        return .currency(project.budget.map(String.init), code: project.currency)
    }
}
