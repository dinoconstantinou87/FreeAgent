import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

struct CompanyCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "company",
        abstract: "Get company details from FreeAgent"
    )
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.CompanyDetails.Input()
        let response = try await client.companyDetails(input)
        let okResponse = try response.ok
        return try okResponse.body.json.additionalProperties
    }
}