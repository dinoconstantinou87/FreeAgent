import Foundation
import Yams

// MARK: - SpecGraph

struct SpecGraph {

    // MARK: Lifecycle

    init(rootURL: URL) throws {
        let root = try Self.load(rootURL)
        let rootLocation = SpecLocation(file: rootURL)
        let components = Self.components(in: root, at: rootLocation)
        let pathFiles = Self.pathFiles(in: root, at: rootLocation)

        var dependencies = [SpecLocation: Set<SpecLocation>]()
        var pending = pathFiles
        while let location = pending.popLast() {
            guard dependencies[location] == nil else {
                continue
            }

            let node = try location.pointer.map { try Self.node(at: $0, in: root) } ?? Self.load(location.file)
            let targets = Set(Self.references(in: node)
                .compactMap { Self.target(of: $0, from: location, components: components) })
            dependencies[location] = targets
            pending.append(contentsOf: targets)
        }

        self.root = root
        self.rootLocation = rootLocation
        self.components = components
        self.pathFiles = pathFiles
        self.dependencies = dependencies
    }

    // MARK: Internal

    static func load(_ url: URL) throws -> Node {
        guard let node = try Yams.compose(yaml: String(contentsOf: url, encoding: .utf8)) else {
            throw SpecGraphError.emptyDocument(url.path)
        }

        return node
    }

    func selection(changedFiles: [URL], baseRoot: Node?) -> SuiteSelection {
        var changed = Set<SpecLocation>()
        for location in changedFiles.map({ SpecLocation(file: $0) }) {
            guard location == rootLocation else {
                changed.insert(location)
                continue
            }

            guard let baseRoot else {
                continue
            }

            if Self.version(of: root) != Self.version(of: baseRoot) {
                return .all
            }

            changed.formUnion(inlineComponents.filter { location in
                guard let pointer = location.pointer else {
                    return false
                }

                return (try? Self.node(at: pointer, in: root)) != (try? Self.node(at: pointer, in: baseRoot))
            })
        }

        let suites = pathFiles
            .filter { !closure(of: $0).isDisjoint(with: changed) }
            .map { $0.file.deletingPathExtension().lastPathComponent }

        return .suites(suites.sorted())
    }

    // MARK: Private

    private let root: Node
    private let rootLocation: SpecLocation
    private let components: [String: SpecLocation]
    private let pathFiles: [SpecLocation]
    private let dependencies: [SpecLocation: Set<SpecLocation>]

    private var inlineComponents: Set<SpecLocation> {
        Set(components.values.filter { $0.pointer != nil })
    }

    private static func version(of root: Node) -> String? {
        root["info"]?["version"]?.string
    }

    private static func components(in root: Node, at rootLocation: SpecLocation) -> [String: SpecLocation] {
        var components = [String: SpecLocation]()
        for (kind, entries) in root["components"]?.mapping ?? [:] {
            guard let kind = kind.string else {
                continue
            }

            for (name, value) in entries.mapping ?? [:] {
                guard let name = name.string else {
                    continue
                }

                let pointer = "#/components/\(kind)/\(name)"
                if let ref = value["$ref"]?.string, !ref.hasPrefix("#") {
                    components[pointer] = location(of: ref, relativeTo: rootLocation)
                } else {
                    components[pointer] = SpecLocation(file: rootLocation.file, pointer: pointer)
                }
            }
        }

        return components
    }

    private static func pathFiles(in root: Node, at rootLocation: SpecLocation) -> [SpecLocation] {
        var pathFiles = [SpecLocation]()
        for (_, pathItem) in root["paths"]?.mapping ?? [:] {
            guard let ref = pathItem["$ref"]?.string, !ref.hasPrefix("#") else {
                continue
            }

            let location = location(of: ref, relativeTo: rootLocation)
            if !pathFiles.contains(location) {
                pathFiles.append(location)
            }
        }

        return pathFiles
    }

    private static func references(in node: Node) -> [String] {
        switch node {
        case .mapping(let mapping):
            mapping.flatMap { key, value in
                if key.string == "$ref", let ref = value.string {
                    return [ref]
                }

                return references(in: value)
            }

        case .sequence(let sequence):
            sequence.flatMap { references(in: $0) }

        case .scalar, .alias:
            []
        }
    }

    private static func target(
        of ref: String,
        from location: SpecLocation,
        components: [String: SpecLocation]
    ) -> SpecLocation? {
        guard !ref.hasPrefix("#") else {
            return components[ref]
        }

        return Self.location(of: ref, relativeTo: location)
    }

    private static func location(of ref: String, relativeTo location: SpecLocation) -> SpecLocation {
        let file = String(ref.prefix { $0 != "#" })

        return SpecLocation(file: URL(fileURLWithPath: file, relativeTo: location.file.deletingLastPathComponent()))
    }

    private static func node(at pointer: String, in root: Node) throws -> Node {
        var node = root
        for key in pointer.dropFirst(2).split(separator: "/") {
            guard let next = node[String(key)] else {
                throw SpecGraphError.missingPointer(pointer)
            }

            node = next
        }

        return node
    }

    private func closure(of location: SpecLocation) -> Set<SpecLocation> {
        var visited = Set<SpecLocation>()
        var pending = [location]
        while let next = pending.popLast() {
            guard visited.insert(next).inserted else {
                continue
            }

            pending.append(contentsOf: dependencies[next] ?? [])
        }

        return visited
    }

}

// MARK: - SpecGraphError

enum SpecGraphError: Error, CustomStringConvertible {
    case emptyDocument(String)
    case missingPointer(String)

    var description: String {
        switch self {
        case .emptyDocument(let path):
            "Empty YAML document: \(path)"
        case .missingPointer(let pointer):
            "No node at \(pointer)"
        }
    }
}
