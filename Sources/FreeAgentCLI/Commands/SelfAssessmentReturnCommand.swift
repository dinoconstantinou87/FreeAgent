import ArgumentParser

struct SelfAssessmentReturnCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "self-assessment-return",
        abstract: "Manage self assessment returns",
        subcommands: [
            SelfAssessmentReturnListCommand.self,
            SelfAssessmentReturnShowCommand.self,
            SelfAssessmentReturnMarkFiledCommand.self,
            SelfAssessmentReturnMarkUnfiledCommand.self,
            SelfAssessmentReturnMarkPaidCommand.self,
            SelfAssessmentReturnMarkUnpaidCommand.self,
        ]
    )
}
