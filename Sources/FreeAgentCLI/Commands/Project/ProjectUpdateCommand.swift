import ArgumentParser
import Foundation
import FreeAgentAPI

struct ProjectUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a project",
        discussion: "Fields left out are kept, and an empty --contract-po-reference, --starts-on or --ends-on removes it."
    )

    @Argument(help: "Project ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Contact ID or URL to bill for the project")
    var contact: ResourceID?

    @Option(name: .long, help: "Project name")
    var name: String?

    @Option(name: .long, help: "Status")
    var status: Components.Schemas.ProjectStatus?

    @Option(name: .long, help: "Currency, e.g. USD")
    var currency: String?

    @Option(name: .long, help: "Units of the budget")
    var budgetUnits: Components.Schemas.ProjectBudgetUnits?

    @OptionGroup var project: ProjectOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ProjectResponse {
        let projectPayload = project.updatePayload(
            contact: contact?.value,
            name: name,
            status: status,
            currency: currency,
            budgetUnits: budgetUnits
        )

        let input = Operations.UpdateProject.Input(
            path: .init(id: id.value),
            body: .json(.init(project: projectPayload))
        )

        return try await client.updateProject(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.ProjectResponse) -> String {
        "Updated project \(id)"
    }
}
