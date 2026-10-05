import Foundation

// MARK: - CoverageReport

struct CoverageReport: CustomStringConvertible {

    // MARK: Lifecycle

    init(docsURL: URL, pages: [DocsPage], spec: [Endpoint]) {
        var owners = [String: String]()
        let largestFirst = pages.enumerated().sorted { lhs, rhs in
            lhs.element.endpoints.count != rhs.element.endpoints.count
                ? lhs.element.endpoints.count > rhs.element.endpoints.count
                : lhs.offset < rhs.offset
        }
        for (_, page) in largestFirst {
            for endpoint in page.endpoints where owners[endpoint.key] == nil {
                owners[endpoint.key] = page.slug
            }
        }

        let specKeys = Set(spec.map(\.key))
        self.docsURL = docsURL
        sections = pages.compactMap { page in
            let owned = page.endpoints.filter { owners[$0.key] == page.slug }
            guard !owned.isEmpty else {
                return nil
            }

            return CoverageSection(
                slug: page.slug,
                title: page.title,
                covered: owned.filter { specKeys.contains($0.key) },
                missing: owned.filter { !specKeys.contains($0.key) }
            )
        }
        undocumented = spec
            .filter { owners[$0.key] == nil }
            .sorted { ($0.path, $0.method) < ($1.path, $1.method) }
    }

    // MARK: Internal

    let docsURL: URL
    let sections: [CoverageSection]
    let undocumented: [Endpoint]

    var description: String {
        let documented = sections.reduce(0) { $0 + $1.covered.count + $1.missing.count }
        let covered = sections.reduce(0) { $0 + $1.covered.count }
        let percent = documented == 0 ? 0 : Int((Double(covered) / Double(documented) * 100).rounded())

        var lines = [
            "# FreeAgent API Coverage",
            "",
            "The spec covers \(covered) of the \(documented) endpoints documented at \(docsURL.absoluteString) (\(percent)%).",
            "",
            "| Page | Documented | Covered | Missing |",
            "| --- | ---: | ---: | ---: |",
        ]
        lines += sections.map { section in
            let link = "[\(section.title)](\(docsURL.appending(path: section.slug).absoluteString))"
            let documented = section.covered.count + section.missing.count

            return "| \(link) | \(documented) | \(section.covered.count) | \(section.missing.count) |"
        }

        let missing = sections.filter { !$0.missing.isEmpty }
        if !missing.isEmpty {
            lines += ["", "## Missing Endpoints"]
            for section in missing {
                lines += ["", "### \(section.title)", ""]
                lines += section.missing.map { "- `\($0)`" }
            }
        }

        if !undocumented.isEmpty {
            lines += ["", "## Spec Endpoints Not In The Docs", ""]
            lines += undocumented.map { "- `\($0)`" }
        }

        return lines.joined(separator: "\n") + "\n"
    }
}

// MARK: - CoverageSection

struct CoverageSection: Equatable {
    let slug: String
    let title: String
    let covered: [Endpoint]
    let missing: [Endpoint]
}
