import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show user details"
    )

    static let title = "User"

    static var sections: [FieldSection<Components.Schemas.User>] {
        FieldSection("Details") {
            Field("First Name") { .text($0.firstName) }
            Field("Last Name") { .text($0.lastName) }
            Field("Email") { .text($0.email) }
            Field("Role") { .text($0.role) }
            Field("Permission") { .text($0.permissionLevel?.description) }
            Field("Hidden") { .flag($0.hidden) }
        }
        FieldSection("Tax") {
            Field("NI Number") { .text($0.niNumber) }
            Field("Unique Tax Reference") { .text($0.uniqueTaxReference) }
            Field("Opening Mileage") { .text($0.openingMileage) }
        }
        FieldSection("Previous Employment") {
            Field("Total Pay") { .currency($0.currentPayrollProfile?.totalPayInPreviousEmployment, code: nil) }
            Field("Total Tax") { .currency($0.currentPayrollProfile?.totalTaxInPreviousEmployment, code: nil) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("User") { .id(url: $0.url) }
        }
    }

    @Argument(help: "User ID or URL - defaults to the logged-in user")
    var id: ResourceID?

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.UserResponse {
        guard let id else {
            return try await client.showCurrentUser(.init()).ok.body.json
        }

        return try await client.showUser(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.UserResponse) -> Components.Schemas.User {
        response.user
    }
}
