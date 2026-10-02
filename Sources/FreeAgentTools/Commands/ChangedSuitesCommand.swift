import ArgumentParser
import Foundation

struct ChangedSuitesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "changed-suites",
        abstract: "Write the integration test suites affected by changed OpenAPI files",
        discussion: """
            Writes all when the API version changed, nothing when no suite is affected, and otherwise \
            the suites separated by commas. Each suite is named after its path file.
            """
    )

    @Option(name: .long, help: "Path to the root OpenAPI YAML file")
    var root = "openapi/openapi.yaml"

    @Option(name: .long, help: "Path to the root OpenAPI YAML file on the base branch")
    var base: String?

    @Option(name: .long, help: "Path to write the selected suites to")
    var output: String

    @Argument(help: "Changed OpenAPI files")
    var changedFiles = [String]()

    func run() throws {
        let graph = try SpecGraph(rootURL: URL(fileURLWithPath: root))
        let baseRoot = try base.map { try SpecGraph.load(URL(fileURLWithPath: $0)) }
        let selection = graph.selection(changedFiles: changedFiles.map { URL(fileURLWithPath: $0) }, baseRoot: baseRoot)

        try selection.description.write(toFile: output, atomically: true, encoding: .utf8)
    }
}
