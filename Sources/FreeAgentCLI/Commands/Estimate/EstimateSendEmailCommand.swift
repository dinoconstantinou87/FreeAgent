import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateSendEmailCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "send-email",
        abstract: "Send estimate via email"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Recipient email address")
    var to: String

    @Option(name: .long, help: "Sender email address, must be verified on the FreeAgent account")
    var from: String?

    @Option(name: .long, help: "Email body")
    var body: String?

    @Option(name: .long, help: "Email subject")
    var subject: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func perform(client: Client) async throws -> EmptyResponse {
        let emailPayload = Components.Schemas.EmailPayload(
            body: body,
            from: from,
            subject: subject,
            to: to
        )

        let estimatePayload = Operations.SendEstimateEmail.Input.Body.JsonPayload.EstimatePayload(
            email: emailPayload
        )

        let input = Operations.SendEstimateEmail.Input(
            path: .init(id: id.value),
            body: .json(.init(estimate: estimatePayload))
        )

        _ = try await client.sendEstimateEmail(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Sent estimate \(id) to \(to)"
    }
}
