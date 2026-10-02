import ArgumentParser
import FreeAgentAPI

struct ExpenseEngineOptions: ParsableArguments {
    @Option(
        name: .customLong("engine-type"),
        help: "Engine of a car or motorcycle mileage claim, as listed by 'expense mileage-settings' (default: Petrol)"
    )
    var type: Components.Schemas.ExpenseEngineType?

    @Option(
        name: .customLong("engine-size"),
        help: "Engine size of a mileage claim, as listed by 'expense mileage-settings' - an unknown size becomes the first"
    )
    var size: String?
}
