import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct PaginationOptionsTests {

    // MARK: Internal

    @Test("defaults to the first page of ten")
    func defaults() throws {
        let options = try PaginationOptions.parse([])

        #expect(options.page == 1)
        #expect(options.size == 10)
    }

    @Test("accepts every page size FreeAgent allows", arguments: [1, 100])
    func acceptsPageSize(pageSize: Int) throws {
        #expect(try PaginationOptions.parse(["--page-size=\(pageSize)"]).size == pageSize)
    }

    @Test("rejects a page before the first", arguments: [0, -1])
    func rejectsPage(page: Int) {
        #expect(message(for: ["--page=\(page)"]) == "--page must be at least 1")
    }

    @Test("rejects a page size FreeAgent would refuse", arguments: [0, 101])
    func rejectsPageSize(pageSize: Int) {
        #expect(message(for: ["--page-size=\(pageSize)"]) == "--page-size must be between 1 and 100")
    }

    // MARK: Private

    private func message(for arguments: [String]) -> String? {
        do {
            _ = try PaginationOptions.parse(arguments)
            return nil
        } catch {
            return PaginationOptions.message(for: error)
        }
    }
}
