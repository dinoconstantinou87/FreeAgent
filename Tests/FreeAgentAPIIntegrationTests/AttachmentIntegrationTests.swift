import Foundation
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("bank_transaction_explanation_attachments")))
struct AttachmentIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("POST, GET then PUT _destroy on /v2/bank_transaction_explanations/:id/attachments")
    func attachmentLifecycle() async throws {
        let explanation = try await createExplanation()
        let id = Self.identifier(from: explanation)

        try await withCleanup(of: explanation) {
            let created = try await createAttachment(explanationID: id)
            #expect(created.count == 1)

            let attachment = try #require(created.first)
            #expect(attachment.fileName == "receipt.png")
            #expect(attachment.contentType == "image/png")
            #expect(attachment.url.contains("/v2/attachments/"))

            let listed = try await client.listBankTransactionExplanationAttachments(.init(path: .init(id: id)))
                .ok.body.json.attachments
            #expect(listed.count == 1)

            let output = try await client.updateBankTransactionExplanationAttachments(
                .init(
                    path: .init(id: id),
                    body: .json(.init(attachments: [.init(url: attachment.url, _destroy: "true")]))
                )
            )

            guard case .ok(let ok) = output else {
                Issue.record("PUT _destroy returned \(await Self.describe(output))")
                return
            }

            #expect(try ok.body.json.attachments.isEmpty)
        }
    }

    @Test("GET /v2/attachments/:id returns the attachment metadata")
    func showAttachment() async throws {
        let explanation = try await createExplanation()
        let id = Self.identifier(from: explanation)

        try await withCleanup(of: explanation) {
            let attachment = try #require(try await createAttachment(explanationID: id).first)

            let shown = try await client
                .showAttachment(.init(path: .init(id: Self.identifier(from: attachment.url))))
                .ok.body.json.attachment

            #expect(shown.url == attachment.url)
            #expect(shown.fileName == "receipt.png")
            #expect(shown.fileSize ?? 0 > 0)
            #expect(shown.contentSrc?.isEmpty == false)
        }
    }

    @Test("Inline attachment on create still attaches under API version 2026-09-01")
    func inlineAttachmentOnCreateStillAttaches() async throws {
        let transaction = try await unexplainedTransactionExcludingFirst()

        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            attachment: .init(data: Self.onePixelPNG, fileName: "receipt.png", contentType: .imagePng),
            bankAccount: transaction.bankAccount,
            bankTransaction: transaction.url,
            category: standardRatedCategoryURL(forMoneyIn: transaction.isMoneyIn),
            datedOn: transaction.datedOn,
            description: "Integration test inline attachment",
            grossValue: transaction.grossValue
        )

        let output = try await client.createABankTransactionExplanation(
            .init(body: .json(.init(bankTransactionExplanation: payload)))
        )

        guard case .created(let created) = output else {
            Issue.record("Inline attachment create returned \(await Self.describe(output))")
            return
        }

        let url = try created.body.json.bankTransactionExplanation.url

        try await withCleanup(of: url) {
            let attachments = try await client.listBankTransactionExplanationAttachments(
                .init(path: .init(id: Self.identifier(from: url)))
            )
            .ok.body.json.attachments

            #expect(attachments.count == 1)
            #expect(attachments.first?.fileName == "receipt.png")
        }
    }

    @Test("Inline attachment on update still attaches under API version 2026-09-01")
    func inlineAttachmentOnUpdateStillAttaches() async throws {
        let explanation = try await createExplanation()
        let id = Self.identifier(from: explanation)

        try await withCleanup(of: explanation) {
            _ = try await client.updateABankTransactionExplanation(
                .init(
                    path: .init(id: id),
                    body: .json(.init(bankTransactionExplanation: .init(
                        attachment: .init(data: Self.onePixelPNG, fileName: "receipt.png", contentType: .imagePng)
                    )))
                )
            )
            .ok

            let attachments = try await client.listBankTransactionExplanationAttachments(.init(path: .init(id: id)))
                .ok.body.json.attachments

            #expect(attachments.count == 1)
            #expect(attachments.first?.fileName == "receipt.png")
        }
    }

    @Test("GET /v2/attachments/:id reports the reason a missing attachment cannot be shown")
    func showMissingAttachmentReportsNotFound() async throws {
        do {
            _ = try await client.showAttachment(.init(path: .init(id: "99999999")))
            Issue.record("Expected FreeAgent to report a missing attachment")
        } catch {
            let error = try #require(APIError.from(error))

            #expect(error.kind == .notFound)
            #expect(error.status == 404)
            #expect(error.messages == ["Resource not found"])
        }
    }

    // MARK: Private

    private struct UnexplainedTransaction {
        let url: String
        let bankAccount: String
        let datedOn: String
        let grossValue: String

        var isMoneyIn: Bool {
            !grossValue.hasPrefix("-")
        }
    }

    private enum AttachmentTestFailure: Error {
        case explanationNotCreated
        case attachmentNotCreated
    }

    private static let onePixelPNG =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="

    private let client: Client
    private let salesCategoryCode = "001"
    private let accommodationCategoryCode = "285"

    private static func identifier(from url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

    private static func describe(_ output: some Sendable) async -> String {
        guard
            let child = Mirror(reflecting: output).children.first,
            let payload = child.value as? UndocumentedPayload,
            let body = payload.body,
            let text = try? await String(collecting: body, upTo: 8 * 1024)
        else {
            return String(describing: output).prefix(200).description
        }

        return text
    }

    private func standardRatedCategoryURL(forMoneyIn moneyIn: Bool) -> String {
        let code = moneyIn ? salesCategoryCode : accommodationCategoryCode
        return Environment.sandbox.baseURL.appending(path: "v2/categories/\(code)").absoluteString
    }

    private func unexplainedTransactionExcludingFirst() async throws -> UnexplainedTransaction {
        let account = try #require(try await firstBankAccountURL())

        let input = Operations.ListAllBankTransactionsUnderACertainBankAccount.Input(
            query: .init(bankAccount: account, view: "unexplained", perPage: 25)
        )
        let body = try await client.listAllBankTransactionsUnderACertainBankAccount(input)
            .ok.body.json.additionalProperties.value

        let transactions = try #require(body["bank_transactions"] as? [Any])
        let transaction = try #require(transactions.dropFirst().randomElement() as? [String: Any])

        return try UnexplainedTransaction(
            url: #require(transaction["url"] as? String),
            bankAccount: account,
            datedOn: #require(transaction["dated_on"] as? String),
            grossValue: #require(transaction["unexplained_amount"] as? String)
        )
    }

    private func firstBankAccountURL() async throws -> String? {
        let body = try await client.listBankAccounts(.init())
            .ok.body.json.additionalProperties.value
        let accounts = try #require(body["bank_accounts"] as? [Any])
        let account = try #require(accounts.first as? [String: Any])
        return account["url"] as? String
    }

    private func createExplanation() async throws -> String {
        let transaction = try await unexplainedTransactionExcludingFirst()

        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            bankAccount: transaction.bankAccount,
            bankTransaction: transaction.url,
            category: standardRatedCategoryURL(forMoneyIn: transaction.isMoneyIn),
            datedOn: transaction.datedOn,
            description: "Integration test attachment lifecycle",
            grossValue: transaction.grossValue
        )

        let output = try await client.createABankTransactionExplanation(
            .init(body: .json(.init(bankTransactionExplanation: payload)))
        )

        guard case .created(let created) = output else {
            Issue.record("Explanation create returned \(await Self.describe(output))")
            throw AttachmentTestFailure.explanationNotCreated
        }

        return try created.body.json.bankTransactionExplanation.url
    }

    private func createAttachment(explanationID: String) async throws -> [Components.Schemas.Attachment] {
        let output = try await client.createBankTransactionExplanationAttachments(
            .init(
                path: .init(id: explanationID),
                body: .json(.init(attachments: [
                    .init(
                        data: Self.onePixelPNG,
                        fileName: "receipt.png",
                        contentType: "image/png",
                        description: "Integration test receipt"
                    )
                ]))
            )
        )

        guard case .created(let created) = output else {
            Issue.record("Attachment create returned \(await Self.describe(output))")
            throw AttachmentTestFailure.attachmentNotCreated
        }

        return try created.body.json.attachments
    }

    private func deleteExplanation(_ url: String) async throws {
        let input = Operations.DeleteABankTransactionExplanation.Input(path: .init(id: Self.identifier(from: url)))
        _ = try await client.deleteABankTransactionExplanation(input)
    }

    private func withCleanup(of explanation: String, _ body: () async throws -> Void) async throws {
        do {
            try await body()
        } catch {
            try? await deleteExplanation(explanation)
            throw error
        }

        try await deleteExplanation(explanation)
    }

}
