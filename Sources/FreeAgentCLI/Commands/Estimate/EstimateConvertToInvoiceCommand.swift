import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateConvertToInvoiceCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "convert-to-invoice",
        abstract: "Convert an estimate to an invoice"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let input = Operations.ConvertEstimateToInvoice.Input(
            path: .init(id: id.value)
        )

        return try await client.convertEstimateToInvoice(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.EstimateResponse) -> String {
        guard let invoice = response.estimate.invoice else {
            return "Converted estimate \(id) to an invoice"
        }

        return "Converted estimate \(id) to invoice \(invoice)"
    }
}
