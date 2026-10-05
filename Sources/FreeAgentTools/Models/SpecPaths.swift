import Foundation
import Yams

enum SpecPaths {

    // MARK: Internal

    static func endpoints(rootURL: URL) throws -> [Endpoint] {
        let root = try SpecGraph.load(rootURL)
        var endpoints = [Endpoint]()
        for (path, item) in root["paths"]?.mapping ?? [:] {
            guard let path = path.string else {
                continue
            }

            let operations = try item["$ref"]?.string.map { try node(at: $0, relativeTo: rootURL) } ?? item
            for method in methods where operations[method] != nil {
                endpoints.append(Endpoint(method: method.uppercased(), path: path))
            }
        }

        return endpoints
    }

    // MARK: Private

    private static let methods = ["get", "post", "put", "patch", "delete"]

    private static func node(at ref: String, relativeTo rootURL: URL) throws -> Node {
        let parts = ref.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let file = URL(fileURLWithPath: String(parts[0]), relativeTo: rootURL.deletingLastPathComponent())
        let document = try SpecGraph.load(file)

        guard parts.count == 2 else {
            return document
        }

        return try SpecGraph.node(at: "#\(parts[1])", in: document)
    }
}
