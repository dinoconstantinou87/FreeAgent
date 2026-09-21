import Testing

@testable import FreeAgentAPI

struct PaginatorTests {
    @Test("asks for exactly the limit when the result fits in one page")
    func singleRequestWithinLimit() async throws {
        var calls = [[Int]]()

        let listing = try await Paginator.collect(limit: 5) { page, perPage in
            calls.append([page, perPage])
            return ([1, 2, 3], 3)
        }

        #expect(calls == [[1, 5]])
        #expect(listing == [1, 2, 3])
    }

    @Test("walks full pages of one hundred and cuts the last page at the limit")
    func spansPagesAtMaximumPageSize() async throws {
        var calls = [[Int]]()

        let listing = try await Paginator.collect(limit: 250) { page, perPage in
            calls.append([page, perPage])
            return (Array((page - 1) * 100 + 1 ... page * 100), 1000)
        }

        #expect(calls == [[1, 100], [2, 100], [3, 100]])
        #expect(listing.count == 250)
        #expect(listing.last == 250)
    }

    @Test("does not fetch another page once the limit is met, even if more exist")
    func stopsAtLimit() async throws {
        var calls = 0

        let listing = try await Paginator.collect(limit: 6) { _, _ in
            calls += 1
            return ([1, 2, 3, 4, 5, 6], 20)
        }

        #expect(calls == 1)
        #expect(listing.count == 6)
    }

    @Test("stops once every record the server counted has arrived")
    func stopsAtTotalCount() async throws {
        var calls = 0

        let listing = try await Paginator.collect(limit: 100) { _, _ in
            calls += 1
            return (Array(1 ... 40), 40)
        }

        #expect(calls == 1)
        #expect(listing.count == 40)
    }

    @Test("does not request a page past the end when the total is an exact multiple of the page size")
    func stopsAtExactMultipleOfPageSize() async throws {
        var calls = 0

        let listing = try await Paginator.collect(limit: 250) { page, _ in
            calls += 1
            return (Array((page - 1) * 100 + 1 ... min(page * 100, 250)), 250)
        }

        #expect(calls == 3)
        #expect(listing.count == 250)
    }

    @Test("treats a response without a total count as the only page")
    func truncatesUnpaginatedResponse() async throws {
        var calls = 0

        let listing = try await Paginator.collect(limit: 3) { _, _ in
            calls += 1
            return (Array(1 ... 10), nil)
        }

        #expect(calls == 1)
        #expect(listing == [1, 2, 3])
    }

    @Test("stops on an empty page even when the total count promised more")
    func stopsOnEmptyPage() async throws {
        var calls = 0

        let listing = try await Paginator.collect(limit: 300) { page, _ in
            calls += 1
            return (page == 1 ? Array(1 ... 100) : [], 300)
        }

        #expect(calls == 2)
        #expect(listing.count == 100)
    }
}
