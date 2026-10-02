import ArgumentParser
import FreeAgentAPI

extension ViewFilter: ExpressibleByArgument {
    public static var allValueStrings: [String] {
        Name.allCases.map(\.rawValue)
    }

    public static var defaultCompletionKind: CompletionKind {
        .list(allValueStrings)
    }
}
