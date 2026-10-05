struct Endpoint: Hashable, Sendable, CustomStringConvertible {

    // MARK: Internal

    let method: String
    let path: String

    var key: String {
        let segments = path.split(separator: "/", omittingEmptySubsequences: false).map { segment in
            Self.isPlaceholder(segment) ? "{}" : String(segment)
        }

        return "\(method) \(segments.joined(separator: "/"))"
    }

    var description: String {
        "\(method) \(path)"
    }

    // MARK: Private

    private static func isPlaceholder(_ segment: Substring) -> Bool {
        segment.hasPrefix(":") || segment.hasPrefix("{") || (!segment.isEmpty && segment.allSatisfy(\.isNumber))
    }
}
