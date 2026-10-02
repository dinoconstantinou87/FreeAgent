import ArgumentParser

struct TimeslipCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "timeslip",
        abstract: "Manage timeslips",
        subcommands: [
            TimeslipListCommand.self,
            TimeslipCreateCommand.self,
            TimeslipShowCommand.self,
            TimeslipUpdateCommand.self,
            TimeslipDeleteCommand.self,
            TimeslipStartTimerCommand.self,
            TimeslipStopTimerCommand.self,
        ]
    )
}
