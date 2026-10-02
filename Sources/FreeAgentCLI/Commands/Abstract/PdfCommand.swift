import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - PdfCommand

protocol PdfCommand: ClientCommand where Response == Components.Schemas.PdfResponse {
    static var noun: String { get }

    var id: ResourceID { get }
    var output: String? { get }
    var clobber: Bool { get }
    var json: Bool { get }

    func fetch(client: Client) async throws -> Components.Schemas.PdfResponse
}

extension PdfCommand {
    var path: String {
        output ?? "\(Self.noun.replacingOccurrences(of: " ", with: "-"))-\(id).pdf"
    }

    func canRun() throws -> Bool {
        guard !json, FileManager.default.fileExists(atPath: path) else {
            return true
        }

        return switch ConfirmationDecision(yes: clobber, dryRun: false, isInteractive: Terminal.canPrompt()) {
        case .proceed:
            true
        case .refuse:
            throw PdfCommandError.fileExists(path: path)
        case .prompt:
            Noora().yesOrNoChoicePrompt(question: "Overwrite \(path)?", defaultAnswer: false)
        }
    }

    func run(client: Client) async throws -> Components.Schemas.PdfResponse? {
        let response = try await fetch(client: client)

        if json {
            return response
        }

        guard
            let content = response.pdf.content,
            let data = Data(base64Encoded: content, options: .ignoreUnknownCharacters)
        else {
            throw APIError(kind: .unexpected)
        }

        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        Noora().success(.alert("Saved \(Self.noun) \(id) to \(path)"))

        return nil
    }
}

// MARK: - PdfCommandError

enum PdfCommandError: CommandError {
    case fileExists(path: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .fileExists(let path):
            "\(path) already exists"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .fileExists:
            [
                "Pass \(.command("--clobber")) to overwrite it",
                "Pass \(.command("--output")) to save somewhere else",
            ]
        }
    }
}
