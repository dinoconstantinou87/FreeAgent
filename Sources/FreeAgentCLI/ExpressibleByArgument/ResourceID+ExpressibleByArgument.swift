import ArgumentParser

extension ResourceID: ExpressibleByArgument {
    init?(argument: String) {
        guard !argument.isEmpty else {
            return nil
        }

        self.init(argument)
    }
}
