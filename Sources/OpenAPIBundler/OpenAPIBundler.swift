import ArgumentParser
import Foundation
import Yams

// MARK: - BundleContext

final class BundleContext {
    /// Maps canonical file paths to their component name in #/components/schemas/
    var schemaFileToName = [String: String]()

    /// Collected schemas to merge into components/schemas after the walk
    var collectedSchemas = [(String, Node)]()

    /// Tracks which files have already been processed to avoid infinite recursion
    var processedFiles = Set<String>()
}

// MARK: - OpenAPIBundler

@main
struct OpenAPIBundler: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Bundle a multi-file OpenAPI spec into a single YAML file"
    )

    @Argument(help: "Path to the root OpenAPI YAML file")
    var input: String

    @Argument(help: "Path to write the bundled output")
    var output: String

    static func loadNode(at url: URL) throws -> Node {
        let contents = try String(contentsOf: url, encoding: .utf8)
        guard let node = try Yams.compose(yaml: contents) else {
            throw BundlerError.emptyDocument(url.path)
        }
        return node
    }

    /// Pre-scan the root document's components/schemas to build a mapping
    /// from external file paths to their component names.
    static func buildSchemaMapping(root: Node, baseURL: URL) -> [String: String] {
        var mapping = [String: String]()

        guard
            case .mapping(let rootMapping) = root,
            let components = rootMapping[Node("components")],
            case .mapping(let componentsMapping) = components,
            let schemas = componentsMapping[Node("schemas")],
            case .mapping(let schemasMapping) = schemas
        else {
            return mapping
        }

        for (key, value) in schemasMapping {
            guard
                case .scalar(let nameScalar) = key,
                case .mapping(let refMapping) = value,
                let refValue = refMapping[Node("$ref")],
                case .scalar(let refScalar) = refValue,
                isExternalRef(refScalar.string)
            else {
                continue
            }

            let fileURL = refFileURL(refScalar.string, relativeTo: baseURL)
            mapping[fileURL.path] = nameScalar.string
        }

        return mapping
    }

    static func resolveRefs(in node: Node, baseURL: URL, context: BundleContext) throws -> Node {
        switch node {
        case .mapping(let mapping):
            if
                let refValue = mapping[Node("$ref")],
                case .scalar(let scalar) = refValue,
                isExternalRef(scalar.string)
            {
                let fileURL = refFileURL(scalar.string, relativeTo: baseURL)
                let canonicalPath = fileURL.path

                // If this file is a known component schema, rewrite to internal $ref
                if let componentName = context.schemaFileToName[canonicalPath] {
                    // Ensure the schema is collected (only process once)
                    if !context.processedFiles.contains(canonicalPath) {
                        context.processedFiles.insert(canonicalPath)
                        let resolved = try resolveExternalRef(scalar.string, relativeTo: baseURL)
                        let bundled = try resolveRefs(in: resolved, baseURL: fileURL, context: context)
                        context.collectedSchemas.append((componentName, bundled))
                    }

                    return .mapping(.init(
                        [(Node("$ref"), Node("#/components/schemas/\(componentName)"))],
                        mapping.tag,
                        mapping.style
                    ))
                }

                // Not a component schema — inline as before (e.g. path files)
                let resolved = try resolveExternalRef(scalar.string, relativeTo: baseURL)
                let resolvedBaseURL = refFileURL(scalar.string, relativeTo: baseURL)
                return try resolveRefs(in: resolved, baseURL: resolvedBaseURL, context: context)
            }

            var pairs = [(Node, Node)]()
            for (key, value) in mapping {
                try pairs.append((key, resolveRefs(in: value, baseURL: baseURL, context: context)))
            }
            return .mapping(.init(pairs, mapping.tag, mapping.style))

        case .sequence(let sequence):
            let resolved = try sequence.map { try resolveRefs(in: $0, baseURL: baseURL, context: context) }
            return .sequence(.init(resolved, sequence.tag, sequence.style))

        case .scalar, .alias:
            return node
        }
    }

    /// Merge collected schemas into the components/schemas section of the resolved document.
    static func mergeCollectedSchemas(into root: Node, context: BundleContext) -> Node {
        guard case .mapping(let rootMapping) = root else { return root }

        // Find or create components
        var componentsPairs: [(Node, Node)] =
            if
                let componentsIndex = rootMapping.firstIndex(where: { $0.0 == Node("components") }),
                case .mapping(let existingComponents) = rootMapping[componentsIndex].1
            {
                existingComponents.map { ($0.0, $0.1) }
            } else {
                []
            }

        // Find or create schemas within components
        var schemaPairs: [(Node, Node)] =
            if
                let schemasIndex = componentsPairs.firstIndex(where: { $0.0 == Node("schemas") }),
                case .mapping(let existingSchemas) = componentsPairs[schemasIndex].1
            {
                existingSchemas.map { ($0.0, $0.1) }
            } else {
                []
            }

        // Add collected schemas
        for (name, node) in context.collectedSchemas {
            // Replace if already exists, otherwise append
            if let existingIndex = schemaPairs.firstIndex(where: { $0.0 == Node(name) }) {
                schemaPairs[existingIndex] = (Node(name), node)
            } else {
                schemaPairs.append((Node(name), node))
            }
        }

        // Rebuild the tree
        let schemasNode = Node.mapping(.init(schemaPairs))

        if let schemasIndex = componentsPairs.firstIndex(where: { $0.0 == Node("schemas") }) {
            componentsPairs[schemasIndex] = (Node("schemas"), schemasNode)
        } else {
            componentsPairs.append((Node("schemas"), schemasNode))
        }

        let componentsNode = Node.mapping(.init(componentsPairs))

        if let componentsIndex = rootMapping.firstIndex(where: { $0.0 == Node("components") }) {
            var pairs = rootMapping.map { ($0.0, $0.1) }
            pairs[componentsIndex] = (Node("components"), componentsNode)
            return .mapping(.init(pairs, rootMapping.tag, rootMapping.style))
        } else {
            var pairs = rootMapping.map { ($0.0, $0.1) }
            pairs.append((Node("components"), componentsNode))
            return .mapping(.init(pairs, rootMapping.tag, rootMapping.style))
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
            guard
                case .mapping(let mapping) = current,
                let next = mapping[Node(part)]
            else {
                throw BundlerError.pointerResolutionFailed(pointer)
            }
            current = next
        }
        return current
    }

    func run() throws {
        let inputURL = URL(fileURLWithPath: input).standardizedFileURL
        let root = try Self.loadNode(at: inputURL)

        // Build mapping of schema files to component names from the root spec
        let schemaMapping = Self.buildSchemaMapping(root: root, baseURL: inputURL)

        let context = BundleContext()
        context.schemaFileToName = schemaMapping

        let resolved = try Self.resolveRefs(in: root, baseURL: inputURL, context: context)
        let merged = Self.mergeCollectedSchemas(into: resolved, context: context)

        let yaml = try Yams.serialize(node: merged)
        try yaml.write(toFile: output, atomically: true, encoding: .utf8)
    }

}

// MARK: - BundlerError

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
