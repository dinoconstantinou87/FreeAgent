import ArgumentParser
import Foundation
import FreeAgentAPI

struct TaskShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show task details"
    )

    static let title = "Task"

    static var sections: [FieldSection<Components.Schemas.Task>] {
        FieldSection("Details") {
            Field("Name") { .text($0.name) }
            Field("Status") { .status($0.status?.rawValue) }
            Field("Deletable") { .flag($0.isDeletable) }
        }
        FieldSection("Billing") {
            Field("Billable") { .flag($0.isBillable) }
            Field("Currency") { .text($0.currency) }
            Field("Billing Rate") { .currency($0.billingRate, code: $0.currency) }
            Field("Billing Period") { .text($0.billingPeriod?.rawValue) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Task") { .id(url: $0.url) }
            Field("Project") { .id(url: $0.project) }
        }
    }

    @Argument(help: "Task ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.TaskResponse {
        try await client.showTask(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.TaskResponse) -> Components.Schemas.Task {
        response.task
    }
}
