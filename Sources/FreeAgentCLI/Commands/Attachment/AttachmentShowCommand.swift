import ArgumentParser
import Foundation
import FreeAgentAPI

struct AttachmentShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show attachment details"
    )

    @Argument(help: "Attachment ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.AttachmentResponse? {
        let input = Operations.ShowAttachment.Input(
            path: .init(id: id)
        )

        return try await client.showAttachment(input)
            .ok.body.json
    }
}
