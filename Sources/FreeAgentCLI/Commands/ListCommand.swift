import FreeAgentAPI
import Noora

// MARK: - ListCommand

protocol ListCommand: ClientCommand {
    associatedtype Response
    associatedtype Item

    static var noun: String { get }
    static var columns: [Field<Item>] { get }

    var pagination: PaginationOptions { get }
    var json: Bool { get }

    func fetch(client: Client, page: Int) async throws -> (response: Response, totalCount: Int?)
    func items(in response: Response) -> [Item]
}

extension ListCommand {
    func run(client: Client) async throws -> Response? {
        let firstPage = try await fetch(client: client, page: pagination.page)

        if json {
            return firstPage.response
        }

        try await Noora().paginatedTable(
            noun: Self.noun,
            headers: Self.columns.map(\.label),
            page: pagination.page,
            pageSize: pagination.size,
            firstPage: (items(in: firstPage.response), firstPage.totalCount),
            row: { item in Self.columns.map { $0.cell(item) } },
            fetch: { try await items(in: fetch(client: client, page: $0).response) }
        )

        return nil
    }
}
