import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct AttachmentDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an attachment"
    )

    @Argument(help: "Attachment ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete attachment \(id)?"
    }

    func run(client: Client) async throws -> OpenAPIValueContainer? {
        let input = Operations.DeleteAttachment.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteAttachment(input).ok
        return nil
    }
}
