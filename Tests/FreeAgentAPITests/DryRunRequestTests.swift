import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

struct DryRunRequestTests {

    // MARK: Internal

    @Test("unwraps the request that the runtime wrapped in a ClientError")
    func unwrapsClientError() async throws {
        let request = try await rendered()
        let wrapped = ClientError(
            operationID: "deleteInvoice",
            operationInput: "input",
            causeDescription: "Middleware threw an error.",
            underlyingError: request
        )

        #expect(DryRunRequest.from(wrapped) == request)
    }

    @Test("is absent for errors that are not a dry run")
    func absentForOtherErrors() {
        #expect(DryRunRequest.from(URLError(.badURL)) == nil)
    }

    // MARK: Private

    private func rendered() async throws -> DryRunRequest {
        try await DryRunRequest(
            HTTPRequest(method: .delete, scheme: "https", authority: "api.example.com", path: "/v2/invoices/1"),
            body: nil,
            baseURL: try #require(URL(string: "https://api.example.com"))
        )
    }

}
