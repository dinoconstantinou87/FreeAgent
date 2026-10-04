import ArgumentParser
import FreeAgentAPI

struct PriceListItemOptions: ParsableArguments {
    @Option(name: .long, parsing: .unconditional, help: "Quantity, negative only for Hours")
    var quantity: Double?

    @Option(name: .long, parsing: .unconditional, help: "Unit price, e.g. 10.99")
    var price: Double?

    @Option(name: .long, help: "VAT status, for UK accounts")
    var vatStatus: Components.Schemas.VatStatus?

    @Option(name: .long, help: "Sales tax rate, for Universal and US accounts, e.g. 20")
    var salesTaxRate: Double?

    @Option(name: .long, help: "Second sales tax rate, for Universal accounts")
    var secondSalesTaxRate: Double?

    @Option(name: .long, help: "Category ID or URL, e.g. 001")
    var category: ResourceID?

    func createPayload(
        code: String,
        description: String,
        itemType: Components.Schemas.PriceListItemType
    ) -> Components.Schemas.PriceListItemCreatePayload {
        .init(
            code: code,
            description: description,
            itemType: itemType,
            quantity: quantity,
            price: price,
            vatStatus: vatStatus,
            salesTaxRate: salesTaxRate,
            secondSalesTaxRate: secondSalesTaxRate,
            category: category?.value
        )
    }

    func updatePayload(
        code: String?,
        description: String?,
        itemType: Components.Schemas.PriceListItemType?
    ) -> Components.Schemas.PriceListItemUpdatePayload {
        .init(
            code: code,
            description: description,
            itemType: itemType,
            quantity: quantity,
            price: price,
            vatStatus: vatStatus,
            salesTaxRate: salesTaxRate,
            secondSalesTaxRate: secondSalesTaxRate,
            category: category?.value
        )
    }
}
