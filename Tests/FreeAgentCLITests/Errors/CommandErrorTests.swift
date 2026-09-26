import ArgumentParser
import FreeAgentAPI
import OpenAPIRuntime
import Testing

@testable import FreeAgentCLI

struct CommandErrorTests {

    @Test("unwraps the error that the runtime wrapped in a ClientError")
    func unwrapsClientError() {
        let wrapped = ClientError(
            operationID: "showInvoice",
            operationInput: "input",
            causeDescription: "Middleware threw an error.",
            underlyingError: APIError(status: 404, messages: ["Resource not found"])
        )

        let error = wrapped.commandError

        #expect(error.exitCode == ExitCode(3))
        #expect(error.errorDescription == "FreeAgent has no such record (HTTP 404): Resource not found")
    }

    @Test("falls back to a generic failure for errors it does not know")
    func fallsBackForOtherErrors() {
        struct Boom: Error { }

        let error = Boom().commandError

        #expect(error.exitCode == .failure)
        #expect(error.errorDescription?.hasPrefix("Failed to execute command:") == true)
    }

    @Test("shows the description and takeaways in the alert")
    func buildsAlert() {
        let alert = APIError(kind: .unauthenticated).alert

        #expect(alert.message.plain() == "Not authenticated with FreeAgent")
        #expect(alert.takeaways.map { $0.plain() } == ["Run 'freeagent auth login'"])
    }

}
