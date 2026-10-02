import Foundation
import Testing
import Yams

@testable import FreeAgentTools

// MARK: - SpecGraphTests

struct SpecGraphTests {

    // MARK: Lifecycle

    init() throws {
        directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        for (path, contents) in Self.files {
            try write(contents, to: path)
        }
    }

    // MARK: Internal

    @Test("a changed path file selects its own suite")
    func pathFile() throws {
        #expect(try selection(changing: "paths/bills.yaml") == .suites(["bills"]))
    }

    @Test("a changed schema selects the suites whose paths use it through other schemas")
    func nestedSchema() throws {
        #expect(try selection(changing: "components/schemas/BillItem.yaml") == .suites(["bills"]))
    }

    @Test("a changed parameter selects the suites whose paths use it")
    func parameter() throws {
        #expect(try selection(changing: "components/parameters/Page.yaml") == .suites(["contacts"]))
    }

    @Test("a changed schema behind a response defined in the root selects every suite using that response")
    func sharedResponseSchema() throws {
        #expect(try selection(changing: "components/schemas/Errors.yaml") == .suites(["bills", "contacts"]))
    }

    @Test("a schema no path uses selects nothing")
    func unusedSchema() throws {
        #expect(try selection(changing: "components/schemas/Unused.yaml") == .suites([]))
    }

    @Test("several changed files select the union of their suites")
    func severalFiles() throws {
        let selection = try selection(changing: "components/schemas/Contact.yaml", "components/schemas/Bill.yaml")

        #expect(selection == .suites(["bills", "contacts"]))
    }

    @Test("registering a schema in the root selects nothing")
    func rootRegistration() throws {
        let base = Self.root.replacingOccurrences(of: Self.unusedRegistration, with: "")

        #expect(try selection(changing: "openapi.yaml", base: base) == .suites([]))
    }

    @Test("changing a response defined in the root selects every suite using it")
    func rootResponse() throws {
        let base = Self.root.replacingOccurrences(of: "description: Error response", with: "description: Error")

        #expect(try selection(changing: "openapi.yaml", base: base) == .suites(["bills", "contacts"]))
    }

    @Test("changing the API version selects every suite")
    func version() throws {
        let base = Self.root.replacingOccurrences(of: "'2026-09-01'", with: "'2024-10-01'")

        #expect(try selection(changing: "openapi.yaml", base: base) == .all)
    }

    @Test("a changed root without a base selects nothing")
    func rootWithoutBase() throws {
        #expect(try selection(changing: "openapi.yaml") == .suites([]))
    }

    @Test("prints all, the suites separated by commas, or nothing")
    func description() {
        #expect(SuiteSelection.all.description == "all")
        #expect(SuiteSelection.suites(["bills", "contacts"]).description == "bills,contacts")
        #expect(SuiteSelection.suites([]).description == "")
    }

    // MARK: Private

    private static let unusedRegistration = """
            Unused:
              $ref: 'components/schemas/Unused.yaml'

        """

    private static let root = """
        openapi: 3.0.3
        info:
          title: Test
          version: '2026-09-01'
        paths:
          /v2/bills:
            $ref: 'paths/bills.yaml#/list'
          /v2/bills/{id}:
            $ref: 'paths/bills.yaml#/show'
          /v2/contacts:
            $ref: 'paths/contacts.yaml#/list'
        components:
          schemas:
            Bill:
              $ref: 'components/schemas/Bill.yaml'
            BillItem:
              $ref: 'components/schemas/BillItem.yaml'
            BillResponse:
              $ref: 'components/schemas/BillResponse.yaml'
            Contact:
              $ref: 'components/schemas/Contact.yaml'
            Errors:
              $ref: 'components/schemas/Errors.yaml'
        \(unusedRegistration)  parameters:
            Page:
              $ref: 'components/parameters/Page.yaml'
          responses:
            ErrorResponse:
              description: Error response
              content:
                application/json:
                  schema:
                    $ref: '#/components/schemas/Errors'

        """

    private static let files = [
        "openapi.yaml": root,
        "paths/bills.yaml": """
            list:
              get:
                responses:
                  '200':
                    content:
                      application/json:
                        schema:
                          $ref: '#/components/schemas/BillResponse'
                  default:
                    $ref: '#/components/responses/ErrorResponse'
            show:
              get:
                responses:
                  '200':
                    content:
                      application/json:
                        schema:
                          $ref: '#/components/schemas/BillResponse'

            """,
        "paths/contacts.yaml": """
            list:
              get:
                parameters:
                - $ref: '#/components/parameters/Page'
                responses:
                  '200':
                    content:
                      application/json:
                        schema:
                          $ref: '#/components/schemas/Contact'
                  default:
                    $ref: '#/components/responses/ErrorResponse'

            """,
        "components/schemas/Bill.yaml": """
            type: object
            properties:
              bill_items:
                type: array
                items:
                  $ref: 'BillItem.yaml'

            """,
        "components/schemas/BillItem.yaml": "type: object\n",
        "components/schemas/BillResponse.yaml": """
            type: object
            properties:
              bill:
                $ref: 'Bill.yaml'

            """,
        "components/schemas/Contact.yaml": "type: object\n",
        "components/schemas/Errors.yaml": "type: object\n",
        "components/schemas/Unused.yaml": "type: object\n",
        "components/parameters/Page.yaml": "name: page\nin: query\n",
    ]

    private let directory: URL

    private func write(_ contents: String, to path: String) throws {
        let url = directory.appending(path: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    private func selection(changing paths: String..., base: String? = nil) throws -> SuiteSelection {
        let graph = try SpecGraph(rootURL: directory.appending(path: "openapi.yaml"))

        return try graph.selection(
            changedFiles: paths.map { directory.appending(path: $0) },
            baseRoot: base.map { try #require(try Yams.compose(yaml: $0)) }
        )
    }

}
