import ArgumentParser

struct ListLimit: ExpressibleByArgument, CustomStringConvertible, Sendable {
    init?(argument: String) {
        guard let value = Int(argument), value >= 1 else {
            return nil
        }

        self.value = value
    }

    private init(value: Int) {
        self.value = value
    }

    static let `default` = ListLimit(value: 30)

    let value: Int

    var description: String {
        String(value)
    }
}
