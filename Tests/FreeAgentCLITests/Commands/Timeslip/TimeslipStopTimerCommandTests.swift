import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct TimeslipStopTimerCommandTests {
    @Test("names the hours the timeslip now holds")
    func namesHours() throws {
        let command = try TimeslipStopTimerCommand.parse(["166910"])

        let message = command.success(for: .init(timeslip: .init(
            url: "https://api.freeagent.com/v2/timeslips/166910",
            hours: "1.01666667"
        )))

        #expect(message == "Stopped the timer on timeslip 166910 at 1:01")
    }

    @Test("names only the timeslip when FreeAgent returns no hours")
    func namesTimeslipWithoutHours() throws {
        let command = try TimeslipStopTimerCommand.parse(["166910"])

        let message = command.success(for: .init(timeslip: .init(url: "https://api.freeagent.com/v2/timeslips/166910")))

        #expect(message == "Stopped the timer on timeslip 166910")
    }
}
