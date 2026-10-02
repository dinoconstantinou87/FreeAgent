import ArgumentParser
import Foundation
import FreeAgentAPI

struct SelfAssessmentReturnMarkFiledCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-filed",
        abstract: "Mark self assessment return as filed"
    )

    @Argument(help: "Period end date, e.g. 2025-04-05")
    var periodEndsOn: String

    @OptionGroup var user: UserOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.SelfAssessmentReturnResponse {
        let userId = try await user.id(client: client)
        let input = Operations.MarkSelfAssessmentReturnAsFiled.Input(
            path: .init(userId: userId, periodEndsOn: periodEndsOn)
        )

        return try await client.markSelfAssessmentReturnAsFiled(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.SelfAssessmentReturnResponse) -> String {
        "Marked self assessment return \(periodEndsOn) as filed"
    }
}
