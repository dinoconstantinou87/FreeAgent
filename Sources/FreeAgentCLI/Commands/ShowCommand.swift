import FreeAgentAPI
import Noora

// MARK: - ShowCommand

protocol ShowCommand: ClientCommand {
    associatedtype Response
    associatedtype Record

    static var title: String { get }
    static var sections: [FieldSection<Record>] { get }
    static var tables: [FieldTable<Record>] { get }

    var json: Bool { get }

    func fetch(client: Client) async throws -> Response
    func record(in response: Response) -> Record
}

extension ShowCommand {
    static var tables: [FieldTable<Record>] {
        []
    }

    func run(client: Client) async throws -> Response? {
        let response = try await fetch(client: client)

        if json {
            return response
        }

        Noora().details(
            of: record(in: response),
            title: Self.title,
            sections: Self.sections,
            tables: Self.tables
        )

        return nil
    }
}
