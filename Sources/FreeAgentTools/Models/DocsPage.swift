import Foundation

struct DocsPage: Sendable {

    // MARK: Lifecycle

    init(slug: String, title: String, endpoints: [Endpoint]) {
        self.slug = slug
        self.title = title
        self.endpoints = endpoints
    }

    init(slug: String, title: String, html: String) {
        var seen = Set<String>()
        let endpoints = html.matches(of: Self.endpointPattern)
            .map { Endpoint(method: String($0.output.1), path: String($0.output.2)) }
            .filter { seen.insert($0.key).inserted }

        self.init(slug: slug, title: title, endpoints: endpoints)
    }

    // MARK: Internal

    let slug: String
    let title: String
    let endpoints: [Endpoint]

    static func links(inIndex html: String) -> [(slug: String, title: String)] {
        var seen = Set<String>()

        return html.matches(of: linkPattern)
            .map { (slug: String($0.output.1), title: String($0.output.2).replacingOccurrences(of: "&amp;", with: "&")) }
            .filter { seen.insert($0.slug).inserted }
    }

    // MARK: Private

    private static var linkPattern: Regex<(Substring, Substring, Substring)> {
        #/<li><a href="/docs/([^"#]+)">([^<]+)</a></li>/#
    }

    private static var endpointPattern: Regex<(Substring, Substring, Substring)> {
        #/<code[^>]*>(GET|POST|PUT|PATCH|DELETE)\s+https://api(?:\.sandbox)?\.freeagent\.com(/v2/[^\s?<"]*)/#
    }
}
