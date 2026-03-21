import Foundation
import Noora

public struct URLValidationRule: ValidatableRule {
    public init(error: ValidatableError) {
        self.error = error
    }

    public let error: ValidatableError

    public func validate(input: String) -> Bool {
        URL(string: input) != nil
    }
}
