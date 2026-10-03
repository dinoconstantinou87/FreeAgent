import ArgumentParser
import FreeAgentAPI

extension PermissionLevel: ExpressibleByArgument {
    public var defaultValueDescription: String {
        description
    }
}
