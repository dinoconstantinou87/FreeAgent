import FreeAgentAPI
import Noora

// MARK: - PaginatedListCommand

protocol PaginatedListCommand: ClientCommand {
    associatedtype Response
    associatedtype Item

    static var noun: String { get }
    @FieldBuilder<Item>
    static var columns: [Field<Item>] { get }

    var json: Bool { get }

    func fetch(client: Client) async throws -> Response
    func items(in response: Response) -> [Item]
}

extension PaginatedListCommand {
    func run(client: Client) async throws -> Response? {
        let response = try await fetch(client: client)

        if json {
            return response
        }

        let columns = Self.columns

        try Noora().paginatedTable(
            noun: Self.noun,
            headers: columns.map(\.label),
            rows: items(in: response).map { item in columns.map { $0.cell(item) } },
            pageSize: 10
        )

        return nil
    }
}
