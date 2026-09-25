import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentListCommand: PaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List attachments on a bank transaction explanation"
    )

    static let noun = "attachments"

    static var columns: [Field<Components.Schemas.Attachment>] {
        Field("ID") { .id(url: $0.url) }
        Field("File Name") { .text($0.fileName) }
        Field("Content Type") { .text($0.contentType) }
        Field("Size") { .bytes($0.fileSize) }
        Field("Description") { .text($0.description) }
    }

    @Argument(help: "Explanation ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.AttachmentListResponse {
        try await client.listBankTransactionExplanationAttachments(.init(path: .init(id: id))).ok.body.json
    }

    func items(in response: Components.Schemas.AttachmentListResponse) -> [Components.Schemas.Attachment] {
        response.attachments
    }
}
