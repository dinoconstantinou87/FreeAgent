import ArgumentParser
import FreeAgentAPI

struct ExpenseRecurringOptions: ParsableArguments {
    @Option(name: .customLong("recurring"), help: "How often the expense recurs")
    var period: Components.Schemas.ExpenseRecurringPeriod?

    @Option(name: .customLong("recurring-end-date"), help: "When the expense stops recurring (YYYY-MM-DD) - needs --recurring")
    var endDate: String?

    func validate() throws {
        if endDate != nil, period == nil {
            throw ValidationError("--recurring-end-date needs --recurring, or FreeAgent ignores it")
        }
    }
}
