public enum Paginator {
    public static let maximumPerPage = 100

    public static func collect<Item: Sendable>(
        limit: Int,
        fetch: (_ page: Int, _ perPage: Int) async throws -> (items: [Item], totalCount: Int?)
    ) async throws -> [Item] {
        precondition(limit >= 1, "limit must be at least 1")
        let perPage = min(limit, maximumPerPage)
        var items = [Item]()
        var page = 1

        while true {
            let fetched = try await fetch(page, perPage)
            items.append(contentsOf: fetched.items.prefix(limit - items.count))

            guard
                let totalCount = fetched.totalCount,
                items.count < min(limit, totalCount),
                !fetched.items.isEmpty
            else {
                break
            }

            page += 1
        }

        return items
    }
}
