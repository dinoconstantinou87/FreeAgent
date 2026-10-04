import ArgumentParser
import Foundation
import FreeAgentAPI

struct PriceListItemListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List price list items"
    )

    static let noun = "price list items"

    static var columns: [Field<Components.Schemas.PriceListItem>] {
        Field("ID") { .id(url: $0.url) }
        Field("Code") { .text($0.code) }
        Field("Description") { .text($0.description) }
        Field("Item Type") { .text($0.itemType?.rawValue) }
        Field("Quantity") { .text($0.quantity) }
        Field("Price") { .currency($0.price, code: nil) }
        Field("VAT Status") { .text($0.vatStatus?.rawValue) }
    }

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListPriceListItems.Input.Query.SortPayload?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.PriceListItemListResponse, totalCount: Int?) {
        let ok = try await client.listPriceListItems(
            .init(query: .init(
                sort: sort,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.PriceListItemListResponse) -> [Components.Schemas.PriceListItem] {
        response.priceListItems
    }
}
