import ArgumentParser
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct AuthErrorCommandErrorTests {

    @Test("reports a login FreeAgent refused with its reason")
    func reportsRefusedLogin() {
        let error = AuthError.declined(error: "access_denied", description: "The user denied access")

        #expect(error.exitCode == ExitCode(4))
        #expect(
            error.errorDescription == "FreeAgent rejected the authorization request: access_denied: The user denied access"
        )
    }

    @Test("reports a missing login like the API does")
    func matchesUnauthenticatedAPIError() {
        let error = AuthError.unauthenticated
        let api = APIError(kind: .unauthenticated)

        #expect(error.exitCode == api.exitCode)
        #expect(error.errorDescription == api.errorDescription)
        #expect(error.takeaways.map { $0.plain() } == api.takeaways.map { $0.plain() })
    }

}
