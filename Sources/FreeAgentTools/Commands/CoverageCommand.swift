import ArgumentParser
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - CoverageCommand

struct CoverageCommand: AsyncParsableCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "coverage",
        abstract: "Write a report of the documented FreeAgent endpoints the OpenAPI spec covers",
        discussion: """
            Reads every page linked from the documentation index and lists, per page, the endpoints the spec \
            has and the ones it is missing, then the spec endpoints no page documents. An endpoint documented \
            on several pages is listed under the page that documents the most endpoints.
            """
    )

    @Option(name: .long, help: "Path to the root OpenAPI YAML file")
    var root = "openapi/openapi.yaml"

    @Option(name: .long, help: "URL of the FreeAgent API documentation index")
    var docs = "https://dev.freeagent.com/docs"

    @Option(name: .long, help: "Path to write the Markdown report to")
    var output: String

    func run() async throws {
        guard let docsURL = URL(string: docs) else {
            throw ValidationError("Not a URL: \(docs)")
        }

        let links = try await DocsPage.links(inIndex: Self.fetch(docsURL))
        let pages = try await withThrowingTaskGroup(of: (Int, DocsPage).self) { group in
            for (offset, link) in links.enumerated() {
                group.addTask {
                    let html = try await Self.fetch(docsURL.appending(path: link.slug))
                    return (offset, DocsPage(slug: link.slug, title: link.title, html: html))
                }
            }

            return try await group.reduce(into: [(Int, DocsPage)]()) { $0.append($1) }
                .sorted { $0.0 < $1.0 }
                .map(\.1)
        }

        let spec = try SpecPaths.endpoints(rootURL: URL(fileURLWithPath: root))
        let report = CoverageReport(docsURL: docsURL, pages: pages, spec: spec)

        try report.description.write(toFile: output, atomically: true, encoding: .utf8)
    }

    // MARK: Private

    private static func fetch(_ url: URL) async throws -> String {
        let (data, response) = try await URLSession.shared.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode

        guard status == 200 else {
            throw CoverageCommandError.unexpectedStatus(url, status)
        }

        return String(decoding: data, as: UTF8.self)
    }
}

// MARK: - CoverageCommandError

enum CoverageCommandError: Error, CustomStringConvertible {
    case unexpectedStatus(URL, Int?)

    var description: String {
        switch self {
        case .unexpectedStatus(let url, let status):
            "\(url.absoluteString) answered with status \(status.map(String.init) ?? "unknown")"
        }
    }
}
