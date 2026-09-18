import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct AttachmentDeleteCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an attachment"
    )

    @Argument(help: "Attachment ID")
    var id: String

    func run(client: Client) async throws -> OpenAPIValueContainer? {
        let input = Operations.DeleteAttachment.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteAttachment(input).ok
        return nil
    }
}
