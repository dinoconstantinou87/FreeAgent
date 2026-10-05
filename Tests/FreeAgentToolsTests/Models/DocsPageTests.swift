import Testing

@testable import FreeAgentTools

struct DocsPageTests {

    // MARK: Internal

    @Test("reads the sidebar's page links in order, once each")
    func links() {
        let links = DocsPage.links(inIndex: Self.index)

        #expect(links.map(\.slug) == ["introduction", "bills", "profit_and_loss"])
        #expect(links.map(\.title) == ["Introduction", "Bills", "Profit & Loss"])
    }

    @Test("reads each endpoint at the start of a code block, without its query, once each")
    func endpoints() {
        let page = DocsPage(slug: "bills", title: "Bills", html: Self.bills)

        #expect(page.endpoints.map(\.description) == [
            "GET /v2/bills",
            "GET /v2/bills/:id",
            "POST /v2/bills",
            "DELETE /v2/bills/:id",
        ])
    }

    // MARK: Private

    private static let index = """
        <li class="active">
          <a href="/docs/index">Index</a>
        </li>
        <li>Learn more about <a href="/docs/oauth">OAuth 2.0</a></li>
        <li><a href="/docs/introduction">Introduction</a></li>
        <li><a href="/docs/bills">Bills</a></li>
        <li><a href="/docs/profit_and_loss">Profit &amp; Loss</a></li>
        <li><a href="/docs/bills">Bills</a></li>
        <li><a title="View the FreeAgent API terms of use" href="/docs/api_terms">API Terms</a></li>
        """

    private static let bills = """
        <h2>List all bills</h2><pre class=prettyprint><code class=>GET https://api.freeagent.com/v2/bills
        </code></pre><pre class=prettyprint><code class=>GET https://api.freeagent.com/v2/bills?view=open
        </code></pre><h2>Get a single bill</h2><pre class=prettyprint><code class=>GET  https://api.freeagent.com/v2/bills/:id
        </code></pre><h2>Create a bill</h2><pre class=prettyprint><code class=>POST https://api.sandbox.freeagent.com/v2/bills
        </code></pre><p>Send a GET https://api.freeagent.com/v2/contacts request first.</p>
        <h2>Delete a bill</h2><pre class=prettyprint><code class=>DELETE https://api.freeagent.com/v2/bills/:id
        </code></pre>
        """
}
