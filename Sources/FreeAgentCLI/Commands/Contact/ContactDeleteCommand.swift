import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ContactDeleteCommand

struct ContactDeleteCommand: DestructiveCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a contact",
        discussion: "A contact with invoices, credit notes, bills, estimates or projects cannot be deleted, but can be hidden instead."
    )

    @Argument(help: "Contact ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete contact \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteContact.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteContact(input).ok
        } catch where APIError.from(error)?.status == 403 {
            let records = await records(client: client)

            guard !records.isEmpty else {
                throw error
            }

            throw ContactDeleteCommandError.hasRecords(id: id.value, records: records)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted contact \(id)"
    }

    // MARK: Private

    private func records(client: Client) async -> [String] {
        async let invoices = try? client.listInvoices(.init(query: .init(contact: id.value, perPage: 1)))
            .ok.body.json.invoices.isEmpty
        async let bills = try? client.listBills(.init(query: .init(contact: id.value, perPage: 1)))
            .ok.body.json.bills.isEmpty
        async let estimates = try? client.listEstimates(.init(query: .init(contact: id.value, perPage: 1)))
            .ok.body.json.estimates.isEmpty
        async let projects = try? client.listProjects(.init(query: .init(contact: id.value, perPage: 1)))
            .ok.body.json.projects.isEmpty

        return await [
            ("invoices", invoices),
            ("bills", bills),
            ("estimates", estimates),
            ("projects", projects),
        ]
        .filter { $0.1 == false }
        .map(\.0)
    }
}

// MARK: - ContactDeleteCommandError

enum ContactDeleteCommandError: CommandError {
    case hasRecords(id: String, records: [String])

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .hasRecords(let id, let records):
            "Contact \(id) has \(records.formatted(.list(type: .and))), so it cannot be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .hasRecords(let id, _):
            ["Hide it instead with \(.command("freeagent contact update \(id) --status Hidden"))"]
        }
    }
}
