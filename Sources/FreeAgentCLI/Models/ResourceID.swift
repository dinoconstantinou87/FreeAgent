import Foundation

struct ResourceID: Hashable, Sendable, CustomStringConvertible {
    init(_ idOrURL: String) {
        value = URL(string: idOrURL)?.lastPathComponent ?? idOrURL
    }

    let value: String

    var description: String {
        value
    }
}
