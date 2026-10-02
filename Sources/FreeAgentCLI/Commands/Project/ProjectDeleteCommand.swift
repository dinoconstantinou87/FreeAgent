import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ProjectDeleteCommand

struct ProjectDeleteCommand: DestructiveCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a project",
        discussion: "A project with tasks, timeslips, invoices, credit notes, estimates, expenses, bills or rebilled bank explanations cannot be deleted, but can be marked Completed or Hidden instead."
    )

    @Argument(help: "Project ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete project \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteProject.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteProject(input).ok
        } catch where APIError.from(error)?.status == 409 {
            async let records = records(client: client)
            async let isDeletable = try? client.showProject(.init(path: .init(id: id.value)))
                .ok.body.json.project.isDeletable

            let found = await records

            guard found.isEmpty else {
                throw ProjectDeleteCommandError.hasRecords(id: id.value, records: found)
            }

            guard await isDeletable != false else {
                throw ProjectDeleteCommandError.inUse(id: id.value)
            }

            throw error
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted project \(id)"
    }

    // MARK: Private

    private func records(client: Client) async -> [String] {
        async let tasks = try? client.listTasks(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.tasks.isEmpty
        async let timeslips = try? client.listTimeslips(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.timeslips.isEmpty
        async let invoices = try? client.listInvoices(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.invoices.isEmpty
        async let estimates = try? client.listEstimates(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.estimates.isEmpty
        async let expenses = try? client.listAllExpenses(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.expenses.isEmpty
        async let bills = try? client.listBills(.init(query: .init(project: id.value, perPage: 1)))
            .ok.body.json.bills.isEmpty

        return await [
            ("tasks", tasks),
            ("timeslips", timeslips),
            ("invoices", invoices),
            ("estimates", estimates),
            ("expenses", expenses),
            ("bills", bills),
        ]
        .filter { $0.1 == false }
        .map(\.0)
    }
}

// MARK: - ProjectDeleteCommandError

enum ProjectDeleteCommandError: CommandError {
    case hasRecords(id: String, records: [String])
    case inUse(id: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .hasRecords(let id, let records):
            "Project \(id) has \(records.formatted(.list(type: .and))), so it cannot be deleted"
        case .inUse(let id):
            "Project \(id) has records, so it cannot be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .hasRecords(let id, _), .inUse(let id):
            ["Mark it finished instead with \(.command("freeagent project update \(id) --status Completed"))"]
        }
    }
}
