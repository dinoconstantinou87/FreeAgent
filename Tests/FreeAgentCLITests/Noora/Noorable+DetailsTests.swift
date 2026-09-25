import Noora
import Testing

@testable import FreeAgentCLI

struct NoorableDetailsTests {

    // MARK: Internal

    @Test("aligns every value in one column and leaves out empty fields and sections")
    func rendersSections() {
        ui.details(
            of: Invoice(reference: "006", contact: "Alice Johnson", poReference: nil, paymentTerms: "30 days", items: []),
            title: "Invoice",
            sections: [
                FieldSection("Details") {
                    Field("Reference") { .text($0.reference) }
                    Field("PO Reference") { .text($0.poReference) }
                    Field("Payment Terms") { .text($0.paymentTerms) }
                },
                FieldSection("Project") {
                    Field("Project") { .text($0.poReference) }
                },
                FieldSection("IDs") {
                    Field("Contact") { .text($0.contact) }
                },
            ],
            tables: []
        )

        #expect(ui.description == """
            Invoice

            Details
              Reference:      006
              Payment Terms:  30 days

            IDs
              Contact:        Alice Johnson

            """)
    }

    @Test("lists a collection under its count with columns padded to the widest cell")
    func rendersTable() {
        ui.details(
            of: Invoice(
                reference: "006",
                contact: nil,
                poReference: nil,
                paymentTerms: nil,
                items: [
                    Item(description: "Engineering Services", quantity: "3.0"),
                    Item(description: "Travel", quantity: nil),
                ]
            ),
            title: "Invoice",
            sections: [
                FieldSection("Details") { Field("Reference") { .text($0.reference) } }
            ],
            tables: [
                FieldTable("Items", items: { $0.items }) {
                    Field("Description") { .text($0.description) }
                    Field("Quantity") { .text($0.quantity) }
                }
            ]
        )

        #expect(ui.description == """
            Invoice

            Details
              Reference:  006

            Items (2)
              Description           Quantity
              Engineering Services  3.0
              Travel                -

            """)
    }

    @Test("leaves out a collection with nothing in it")
    func skipsEmptyTable() {
        ui.details(
            of: Invoice(reference: "006", contact: nil, poReference: nil, paymentTerms: nil, items: []),
            title: "Invoice",
            sections: [
                FieldSection("Details") { Field("Reference") { .text($0.reference) } }
            ],
            tables: [
                FieldTable("Items", items: { $0.items }) { Field("Description") { .text($0.description) } }
            ]
        )

        #expect(!ui.description.contains("Items"))
    }

    // MARK: Private

    private struct Invoice {
        let reference: String?
        let contact: String?
        let poReference: String?
        let paymentTerms: String?
        let items: [Item]
    }

    private struct Item {
        let description: String
        let quantity: String?
    }

    private let ui = NooraMock(terminal: Terminal(isInteractive: false, isColored: false, signalBehavior: .none))

}
