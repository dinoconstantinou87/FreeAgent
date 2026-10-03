import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ProjectCreateCommand

struct ProjectCreateCommand: MutatingCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a project"
    )

    @Option(name: .long, help: "Contact ID or URL to bill for the project")
    var contact: ResourceID

    @Option(name: .long, help: "Project name")
    var name: String

    @Option(name: .long, help: "Status")
    var status = Components.Schemas.ProjectStatus.active

    @Option(name: .long, help: "Currency, e.g. USD - defaults to the company's currency")
    var currency: Components.Schemas.Currency?

    @Option(name: .long, help: "Units of the budget")
    var budgetUnits = Components.Schemas.ProjectBudgetUnits.hours

    @OptionGroup var project: ProjectOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ProjectResponse {
        let projectPayload = try await project.createPayload(
            contact: contact.value,
            name: name,
            status: status,
            currency: currency(client: client),
            budgetUnits: budgetUnits
        )

        let input = Operations.CreateProject.Input(
            body: .json(.init(project: projectPayload))
        )

        return try await client.createProject(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.ProjectResponse) -> String {
        "Created project \(response.project.url)"
    }

    // MARK: Private

    private func currency(client: Client) async throws -> Components.Schemas.Currency {
        if let currency {
            return currency
        }

        let code = try await client.companyDetails().ok.body.json.company.currency

        guard let currency = Components.Schemas.Currency(rawValue: code) else {
            throw ProjectCreateCommandError.unsupportedCompanyCurrency(code)
        }

        return currency
    }
}

// MARK: - ProjectCreateCommandError

enum ProjectCreateCommandError: CommandError {
    case unsupportedCompanyCurrency(String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .unsupportedCompanyCurrency(let code):
            "The company's currency, \(code), is not one a project can use"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        ["Pass \(.command("--currency"))"]
    }
}
