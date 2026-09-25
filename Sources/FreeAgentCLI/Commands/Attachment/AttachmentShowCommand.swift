import ArgumentParser
import Foundation
import FreeAgentAPI

struct AttachmentShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show attachment details"
    )

    static let title = "Attachment"

    static let sections: [FieldSection<Components.Schemas.Attachment>] = [
        FieldSection("Details", fields: [
            Field("File Name") { .text($0.fileName) },
            Field("Content Type") { .text($0.contentType) },
            Field("Size") { .bytes($0.fileSize) },
            Field("Description") { .text($0.description) },
        ]),
        FieldSection("Content", fields: [
            Field("URL") { .text($0.contentSrc) },
            Field("Medium") { .text($0.contentSrcMedium) },
            Field("Small") { .text($0.contentSrcSmall) },
            Field("Expires") { .timestamp($0.expiresAt) },
        ]),
        FieldSection("IDs", fields: [
            Field("Attachment") { .id(url: $0.url) }
        ]),
    ]

    @Argument(help: "Attachment ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.AttachmentResponse {
        try await client.showAttachment(.init(path: .init(id: id))).ok.body.json
    }

    func record(in response: Components.Schemas.AttachmentResponse) -> Components.Schemas.Attachment {
        response.attachment
    }
}
