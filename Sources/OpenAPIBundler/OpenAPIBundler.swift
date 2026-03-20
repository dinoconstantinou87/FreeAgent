import ArgumentParser
import Foundation
import Yams

@main
struct OpenAPIBundler: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Bundle a multi-file OpenAPI spec into a single YAML file"
    )

    @Argument(help: "Path to the root OpenAPI YAML file")
    var input: String

    @Argument(help: "Path to write the bundled output")
    var output: String

    func run() throws {
        let inputURL = URL(fileURLWithPath: input).standardizedFileURL
        let root = try Self.loadNode(at: inputURL)
        let resolved = try Self.resolveRefs(in: root, baseURL: inputURL)

        let yaml = try Yams.serialize(node: resolved)
        try yaml.write(toFile: output, atomically: true, encoding: .utf8)
    }

    static func loadNode(at url: URL) throws -> Node {
        let contents = try String(contentsOf: url, encoding: .utf8)
        guard let node = try Yams.compose(yaml: contents) else {
            throw BundlerError.emptyDocument(url.path)
        }
        return node
    }

    static func resolveRefs(in node: Node, baseURL: URL) throws -> Node {
        switch node {
        case .mapping(let mapping):
            if let refValue = mapping[Node("$ref")],
               case .scalar(let scalar) = refValue,
               isExternalRef(scalar.string) {
                let resolved = try resolveExternalRef(scalar.string, relativeTo: baseURL)
                let resolvedBaseURL = refFileURL(scalar.string, relativeTo: baseURL)
                return try resolveRefs(in: resolved, baseURL: resolvedBaseURL)
            }

            var pairs: [(Node, Node)] = []
            for (key, value) in mapping {
                pairs.append((key, try resolveRefs(in: value, baseURL: baseURL)))
            }
            return .mapping(.init(pairs, mapping.tag, mapping.style))

        case .sequence(let sequence):
            let resolved = try sequence.map { try resolveRefs(in: $0, baseURL: baseURL) }
            return .sequence(.init(resolved, sequence.tag, sequence.style))

        case .scalar, .alias:
            return node
        }
    }

    static func isExternalRef(_ ref: String) -> Bool {
        !ref.hasPrefix("#")
    }

    static func refFileURL(_ ref: String, relativeTo baseURL: URL) -> URL {
        let filePart = ref.components(separatedBy: "#").first ?? ref
        return URL(fileURLWithPath: filePart, relativeTo: baseURL.deletingLastPathComponent())
            .standardizedFileURL
    }

    static func resolveExternalRef(_ ref: String, relativeTo baseURL: URL) throws -> Node {
        let parts = ref.components(separatedBy: "#")
        let filePath = parts[0]
        let fragment = parts.count > 1 ? parts[1] : nil

        let fileURL = URL(fileURLWithPath: filePath, relativeTo: baseURL.deletingLastPathComponent())
            .standardizedFileURL
        let document = try loadNode(at: fileURL)

        if let fragment, !fragment.isEmpty {
            return try resolveJSONPointer(fragment, in: document)
        }

        return document
    }

    static func resolveJSONPointer(_ pointer: String, in document: Node) throws -> Node {
        let parts = pointer
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .components(separatedBy: "/")
            .map { $0.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(of: "~0", with: "~") }

        var current = document
        for part in parts where !part.isEmpty {
            guard case .mapping(let mapping) = current,
                  let next = mapping[Node(part)] else {
                throw BundlerError.pointerResolutionFailed(pointer)
            }
            current = next
        }
        return current
    }
}

enum BundlerError: Error, CustomStringConvertible {
    case emptyDocument(String)
    case pointerResolutionFailed(String)

    var description: String {
        switch self {
        case .emptyDocument(let path): "Empty YAML document: \(path)"
        case .pointerResolutionFailed(let pointer): "Failed to resolve JSON pointer: \(pointer)"
        }
    }
}
