import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - TimeslipDeleteCommand

struct TimeslipDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a timeslip"
    )

    @Argument(help: "Timeslip ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete timeslip \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteTimeslip.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteTimeslip(input).ok
        } catch where APIError.from(error)?.status == 409 {
            guard
                let invoice = try? await client.showTimeslip(.init(path: .init(id: id.value))).ok.body.json.timeslip
                    .billedOnInvoice
            else {
                throw error
            }

            throw TimeslipDeleteCommandError.billed(id: id.value, invoice: ResourceID(invoice).value)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted timeslip \(id)"
    }
}

// MARK: - TimeslipDeleteCommandError

enum TimeslipDeleteCommandError: CommandError {
    case billed(id: String, invoice: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .billed(let id, let invoice):
            "Timeslip \(id) is billed on invoice \(invoice), and a billed timeslip cannot be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .billed(_, let invoice):
            [
                "Remove the timeslip's line from invoice \(invoice) in FreeAgent",
                "Or run \(.command("freeagent invoice delete \(invoice)")), which unbills every timeslip on it",
            ]
        }
    }
}
