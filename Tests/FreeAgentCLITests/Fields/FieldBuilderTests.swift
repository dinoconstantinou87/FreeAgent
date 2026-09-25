import Testing

@testable import FreeAgentCLI

struct FieldBuilderTests {

    // MARK: Internal

    @Test("keeps fields in the order they are written, splicing in reused lists")
    func buildsFieldsInOrder() {
        #expect(fields.map(\.label) == ["ID", "Reference", "Contact", "Total"])
    }

    // MARK: Private

    private struct Invoice {
        let reference: String?
    }

    @FieldBuilder<Invoice>
    private var reused: [Field<Invoice>] {
        Field("Reference") { .text($0.reference) }
        Field("Contact") { .text($0.reference) }
    }

    @FieldBuilder<Invoice>
    private var fields: [Field<Invoice>] {
        Field("ID") { .text($0.reference) }
        reused
        Field("Total") { .text($0.reference) }
    }

}
