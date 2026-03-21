import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime
import OpenAPIURLSession

struct CompanyCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "company",
        abstract: "Get company details"
    )

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        try await client.companyDetails().ok.body.json.additionalProperties
    }
}
