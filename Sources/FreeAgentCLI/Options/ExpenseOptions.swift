import ArgumentParser
import FreeAgentAPI

struct ExpenseOptions: ParsableArguments {
    @Option(name: .long, parsing: .unconditional, help: "Gross value, negative for a payment to the claimant, e.g. -12.0")
    var grossValue: String?

    @Option(name: .long, help: "Currency")
    var currency: Components.Schemas.Currency?

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 - ignored while a manual sales tax amount is set")
    var salesTaxRate: String?

    @Option(
        name: .long,
        help: "Whether the expense is taxable, exempt or out of scope - exempt removes a manual sales tax amount"
    )
    var salesTaxStatus: Components.Schemas.ExpenseSalesTaxStatus?

    @Option(
        name: .long,
        help: "Sales tax amount in the company's currency, e.g. 0.12 - replaces the rate's, and can't be blanked once set"
    )
    var manualSalesTaxAmount: String?

    @Option(name: .long, help: "Receipt reference")
    var receiptReference: String?

    @Option(name: .long, help: "Project ID or URL to rebill the expense to")
    var project: ResourceID?

    @Option(name: .long, help: "How to rebill the expense to its project")
    var rebillType: Components.Schemas.ExpenseRebillType?

    @Option(name: .long, help: "How much to rebill for, needed with markup or price, e.g. 0.1")
    var rebillFactor: String?

    @OptionGroup var recurring: ExpenseRecurringOptions

    @Option(name: .long, help: "Miles travelled, for a mileage claim")
    var mileage: String?

    @Option(name: .long, help: "Vehicle of a mileage claim")
    var vehicleType: Components.Schemas.ExpenseVehicleType?

    @Option(name: .long, help: "Whether a mileage claim has a VAT receipt for its fuel")
    var haveVatReceipt: Bool?

    func createPayload(
        user: String,
        category: String,
        datedOn: String,
        description: String,
        engine: ExpenseEngineOptions
    ) -> Components.Schemas.ExpenseCreatePayload {
        .init(
            user: user,
            category: category,
            datedOn: datedOn,
            description: description,
            currency: currency,
            grossValue: grossValue,
            salesTaxRate: salesTaxRate,
            salesTaxStatus: salesTaxStatus,
            manualSalesTaxAmount: manualSalesTaxAmount,
            receiptReference: receiptReference,
            project: project?.value,
            rebillType: rebillType,
            rebillFactor: rebillFactor,
            recurring: recurring.period,
            recurringEndDate: recurring.endDate,
            mileage: mileage,
            vehicleType: vehicleType,
            engineType: engine.type,
            engineSize: engine.size,
            haveVatReceipt: haveVatReceipt
        )
    }

    func updatePayload(
        user: String?,
        category: String?,
        datedOn: String?,
        description: String?
    ) -> Components.Schemas.ExpenseUpdatePayload {
        .init(
            user: user,
            category: category,
            datedOn: datedOn,
            description: description,
            currency: currency,
            grossValue: grossValue,
            salesTaxRate: salesTaxRate,
            salesTaxStatus: salesTaxStatus,
            manualSalesTaxAmount: manualSalesTaxAmount,
            receiptReference: receiptReference,
            project: project?.value,
            rebillType: rebillType,
            rebillFactor: rebillFactor,
            recurring: recurring.period,
            recurringEndDate: recurring.endDate,
            mileage: mileage,
            vehicleType: vehicleType,
            haveVatReceipt: haveVatReceipt
        )
    }
}
