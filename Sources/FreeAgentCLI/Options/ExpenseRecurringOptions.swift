import ArgumentParser
import FreeAgentAPI

struct ExpenseRecurringOptions: ParsableArguments {
    @Option(name: .long, help: "How often the expense recurs")
    var recurring: Components.Schemas.ExpenseRecurringPeriod?

    @Option(name: .long, help: "When the expense stops recurring (YYYY-MM-DD) - needs --recurring")
    var recurringEndDate: String?

    func validate() throws {
        if recurringEndDate != nil, recurring == nil {
            throw ValidationError("--recurring-end-date needs --recurring, or FreeAgent ignores it")
        }
    }
}
