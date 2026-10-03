import ArgumentParser

extension PermissionLevel: ExpressibleByArgument {
    var defaultValueDescription: String {
        name
    }
}
