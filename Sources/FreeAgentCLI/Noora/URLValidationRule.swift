import Noora
import Foundation

public struct URLValidationRule: ValidatableRule {
    public let error: ValidatableError

    public init(error: ValidatableError) {
        self.error = error
    }

    public func validate(input: String) -> Bool {
        URL(string: input) != nil
    }
}
