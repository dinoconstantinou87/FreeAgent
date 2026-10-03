import Foundation
import Testing

@testable import FreeAgentAPI

struct PermissionLevelTests {

    @Test("decodes every documented level", arguments: PermissionLevel.allCases)
    func decodesDocumentedLevels(level: PermissionLevel) throws {
        #expect(try JSONDecoder().decode(PermissionLevel.self, from: Data("\(level.rawValue)".utf8)) == level)
    }

    @Test("encodes as FreeAgent's integer")
    func encodesInteger() throws {
        #expect(try String(decoding: JSONEncoder().encode(PermissionLevel.full), as: UTF8.self) == "8")
    }

    @Test("refuses a level FreeAgent does not document")
    func refusesUnknownLevel() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(PermissionLevel.self, from: Data("9".utf8))
        }
    }

}
