import Noora

extension Noorable {
    static func pageCount(totalCount: Int?, pageSize: Int) -> Int {
        guard let totalCount else {
            return 1
        }

        return max(1, (totalCount + pageSize - 1) / pageSize)
    }

    func paginatedTable<Item>(
        noun: String,
        headers: [String],
        page: Int,
        pageSize: Int,
        firstPage: (items: [Item], totalCount: Int?),
        row: @escaping (Item) -> [String],
        fetch: @escaping (_ page: Int) async throws -> [Item]
    ) async throws {
        guard !firstPage.items.isEmpty else {
            passthrough(page == 1 ? "No \(noun) found\n" : "No \(noun) found on page \(page)\n")
            return
        }

        let startPage = page - 1
        let firstRows = firstPage.items.map(row)

        try await paginatedTable(
            headers: headers,
            pageSize: pageSize,
            totalPages: Self.pageCount(totalCount: firstPage.totalCount, pageSize: pageSize),
            startPage: startPage
        ) { index in
            index == startPage ? firstRows : try await fetch(index + 1).map(row)
        }
    }

    func paginatedTable(noun: String, headers: [String], rows: [[String]], pageSize: Int) throws {
        guard !rows.isEmpty else {
            passthrough("No \(noun) found\n")
            return
        }

        try paginatedTable(headers: headers, rows: rows, pageSize: pageSize)
    }
}
