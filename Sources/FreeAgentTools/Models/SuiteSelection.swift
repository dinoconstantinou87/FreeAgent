enum SuiteSelection: Equatable, CustomStringConvertible {
    case all
    case suites([String])

    var description: String {
        switch self {
        case .all:
            "all"
        case .suites(let suites):
            suites.joined(separator: ",")
        }
    }
}
