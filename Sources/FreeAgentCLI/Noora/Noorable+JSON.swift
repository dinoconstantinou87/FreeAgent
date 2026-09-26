import Noora

extension Noorable {
    func json(_ item: some Codable, terminator: String) throws {
        try json(item)
        passthrough(TerminalText(stringLiteral: terminator), pipeline: .output)
    }
}
