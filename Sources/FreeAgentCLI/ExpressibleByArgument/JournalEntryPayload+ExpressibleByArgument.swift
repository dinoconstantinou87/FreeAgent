import ArgumentParser
import Foundation
import FreeAgentAPI

extension Components.Schemas.JournalEntryPayload: ExpressibleByArgument {
    public init?(argument: String) {
        guard let entry = try? JSONDecoder().decode(Self.self, from: Data(argument.utf8)) else {
            return nil
        }

        self = entry
    }
}
