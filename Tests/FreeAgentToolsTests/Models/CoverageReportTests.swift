import Foundation
import Testing

@testable import FreeAgentTools

struct CoverageReportTests {

    // MARK: Internal

    @Test("splits each page's endpoints into covered and missing")
    func sections() {
        let report = report()

        #expect(report.sections.map(\.slug) == ["bills", "tasks"])
        #expect(report.sections[0].covered.map(\.description) == ["GET /v2/bills", "GET /v2/bills/:id"])
        #expect(report.sections[0].missing.map(\.description) == ["DELETE /v2/bills/:id"])
    }

    @Test("lists an endpoint documented on several pages under the page documenting the most")
    func owner() {
        let report = report()

        #expect(report.sections.allSatisfy { $0.slug != "introduction" })
        #expect(report.sections[1].covered.map(\.description) == ["GET /v2/tasks"])
    }

    @Test("lists the spec endpoints no page documents")
    func undocumented() {
        #expect(report().undocumented.map(\.description) == ["POST /v2/invoice_items", "DELETE /v2/tasks/{id}"])
    }

    @Test("writes a Markdown summary, the missing endpoints and the undocumented ones")
    func markdown() {
        #expect(report().description == """
            # FreeAgent API Coverage

            The spec covers 3 of the 4 endpoints documented at https://dev.freeagent.com/docs (75%).

            | Page | Documented | Covered | Missing |
            | --- | ---: | ---: | ---: |
            | [Bills](https://dev.freeagent.com/docs/bills) | 3 | 2 | 1 |
            | [Tasks](https://dev.freeagent.com/docs/tasks) | 1 | 1 | 0 |

            ## Missing Endpoints

            ### Bills

            - `DELETE /v2/bills/:id`

            ## Spec Endpoints Not In The Docs

            - `POST /v2/invoice_items`
            - `DELETE /v2/tasks/{id}`

            """)
    }

    // MARK: Private

    private func report() -> CoverageReport {
        let pages = [
            DocsPage(slug: "introduction", title: "Introduction", endpoints: [
                Endpoint(method: "GET", path: "/v2/bills")
            ]),
            DocsPage(slug: "bills", title: "Bills", endpoints: [
                Endpoint(method: "GET", path: "/v2/bills"),
                Endpoint(method: "GET", path: "/v2/bills/:id"),
                Endpoint(method: "DELETE", path: "/v2/bills/:id"),
            ]),
            DocsPage(slug: "tasks", title: "Tasks", endpoints: [
                Endpoint(method: "GET", path: "/v2/tasks")
            ]),
            DocsPage(slug: "currencies", title: "Currencies", endpoints: []),
        ]
        let spec = [
            Endpoint(method: "GET", path: "/v2/bills"),
            Endpoint(method: "GET", path: "/v2/bills/{id}"),
            Endpoint(method: "GET", path: "/v2/tasks"),
            Endpoint(method: "DELETE", path: "/v2/tasks/{id}"),
            Endpoint(method: "POST", path: "/v2/invoice_items"),
        ]

        return CoverageReport(docsURL: URL(string: "https://dev.freeagent.com/docs")!, pages: pages, spec: spec)
    }
}
