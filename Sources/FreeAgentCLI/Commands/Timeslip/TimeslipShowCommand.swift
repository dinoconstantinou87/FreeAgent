import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show timeslip details"
    )

    static let title = "Timeslip"

    static var sections: [FieldSection<Components.Schemas.Timeslip>] {
        FieldSection("Details") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Hours") { .hours($0.hours) }
            Field("Comment") { .text($0.comment) }
        }
        FieldSection("Timer") {
            Field("Running") { .flag($0.timer?.running) }
            Field("Effective Start") { .timestamp($0.timer?.startFrom) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Timeslip") { .id(url: $0.url) }
            Field("User") { .id(url: $0.user) }
            Field("Project") { .id(url: $0.project) }
            Field("Task") { .id(url: $0.task) }
            Field("Billed On Invoice") { .id(url: $0.billedOnInvoice) }
        }
    }

    @Argument(help: "Timeslip ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.TimeslipResponse {
        try await client.showTimeslip(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.TimeslipResponse) -> Components.Schemas.Timeslip {
        response.timeslip
    }
}
