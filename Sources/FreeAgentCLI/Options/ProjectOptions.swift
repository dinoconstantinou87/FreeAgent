import ArgumentParser
import FreeAgentAPI

struct ProjectOptions: ParsableArguments {
    @Option(name: .long, help: "Contract or purchase order reference")
    var contractPoReference: String?

    @Option(name: .long, help: "Number the project's invoices in their own sequence")
    var usesProjectInvoiceSequence: Bool?

    @Option(name: .long, help: "Budget in budget units, whole numbers only - 0 for no budget")
    var budget: Int?

    @Option(name: .long, help: "Hours in a working day, more than 0 and at most 24, e.g. 7.5")
    var hoursPerDay: Double?

    @Option(name: .long, help: "Normal billing rate per billing period, e.g. 95")
    var normalBillingRate: Double?

    @Option(name: .long, help: "Unit of the normal billing rate")
    var billingPeriod: Components.Schemas.ProjectBillingPeriod?

    @Option(name: .long, help: "Whether the project comes under IR35 as de facto employment")
    var isIr35: Bool?

    @Option(name: .long, help: "Start date (YYYY-MM-DD)")
    var startsOn: String?

    @Option(name: .long, help: "End date (YYYY-MM-DD), later than the start date")
    var endsOn: String?

    @Option(name: .long, help: "Whether the profitability report includes unbilled time")
    var includeUnbilledTimeInProfitability: Bool?

    func createPayload(
        contact: String,
        name: String,
        status: Components.Schemas.ProjectStatus,
        currency: String,
        budgetUnits: Components.Schemas.ProjectBudgetUnits
    ) -> Components.Schemas.ProjectCreatePayload {
        .init(
            contact: contact,
            name: name,
            status: status,
            contractPoReference: contractPoReference,
            usesProjectInvoiceSequence: usesProjectInvoiceSequence,
            currency: currency,
            budget: budget,
            budgetUnits: budgetUnits,
            hoursPerDay: hoursPerDay,
            normalBillingRate: normalBillingRate,
            billingPeriod: billingPeriod,
            isIr35: isIr35,
            startsOn: startsOn,
            endsOn: endsOn,
            includeUnbilledTimeInProfitability: includeUnbilledTimeInProfitability
        )
    }

    func updatePayload(
        contact: String?,
        name: String?,
        status: Components.Schemas.ProjectStatus?,
        currency: String?,
        budgetUnits: Components.Schemas.ProjectBudgetUnits?
    ) -> Components.Schemas.ProjectUpdatePayload {
        .init(
            contact: contact,
            name: name,
            status: status,
            contractPoReference: contractPoReference,
            usesProjectInvoiceSequence: usesProjectInvoiceSequence,
            currency: currency,
            budget: budget,
            budgetUnits: budgetUnits,
            hoursPerDay: hoursPerDay,
            normalBillingRate: normalBillingRate,
            billingPeriod: billingPeriod,
            isIr35: isIr35,
            startsOn: startsOn,
            endsOn: endsOn,
            includeUnbilledTimeInProfitability: includeUnbilledTimeInProfitability
        )
    }
}
