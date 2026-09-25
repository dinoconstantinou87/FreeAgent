import ArgumentParser

struct PaginationOptions: ParsableArguments {
    @Option(name: .long, help: "Page number to show")
    var page = 1

    @Option(name: .customLong("page-size"), help: "Number of records per page")
    var size = 10

    func validate() throws {
        guard page >= 1 else {
            throw ValidationError("--page must be at least 1")
        }

        guard (1 ... 100).contains(size) else {
            throw ValidationError("--page-size must be between 1 and 100")
        }
    }
}
