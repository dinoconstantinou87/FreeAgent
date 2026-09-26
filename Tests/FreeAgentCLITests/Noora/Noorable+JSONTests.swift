import Noora
import Synchronization
import Testing

@testable import FreeAgentCLI

// MARK: - NoorableJSONTests

struct NoorableJSONTests {
    @Test("ends the JSON with the terminator")
    func endsWithTerminator() throws {
        let output = RecordingPipeline()

        try Noora(standardPipelines: StandardPipelines(output: output)).json(["id": 1], terminator: "\n")

        #expect(output.content == "{\n  \"id\" : 1\n}\n")
    }
}

// MARK: - RecordingPipeline

private final class RecordingPipeline: StandardPipelining {

    // MARK: Internal

    var content: String {
        recorded.withLock { $0 }
    }

    func write(content: String) {
        recorded.withLock { $0 += content }
    }

    // MARK: Private

    private let recorded = Mutex("")

}
