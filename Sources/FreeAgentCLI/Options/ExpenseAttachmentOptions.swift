import ArgumentParser
import FreeAgentAPI

struct ExpenseAttachmentOptions: ParsableArguments {
    @Option(name: .customLong("attachment"), help: "Path to a receipt to attach (pdf, png, jpg, jpeg or gif), up to 5MB")
    var path: String?

    @Option(name: .customLong("attachment-description"), help: "Description of the attached receipt - needs --attachment")
    var description: String?

    var createPayload: Components.Schemas.ExpenseAttachmentPayload? {
        get throws {
            guard let path else {
                return nil
            }

            let file = try AttachmentFile(path: path)
            return .init(data: file.data, fileName: file.fileName, contentType: file.contentType, description: description)
        }
    }

    var updatePayload: Components.Schemas.ExpenseAttachmentUpdatePayload? {
        get throws {
            guard let path else {
                return nil
            }

            let file = try AttachmentFile(path: path)
            return .init(data: file.data, fileName: file.fileName, contentType: file.contentType, description: description)
        }
    }

    func validate() throws {
        if description != nil, path == nil {
            throw ValidationError("--attachment-description needs --attachment")
        }
    }
}
