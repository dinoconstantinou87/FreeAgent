import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct BillCreateItemCommandTests {

    // MARK: Internal

    @Test("names the new item by the last item FreeAgent returns")
    func namesLastItem() throws {
        let command = try BillCreateItemCommand.parse(arguments)

        let message = command.success(for: .init(bill: .init(
            url: "https://api.freeagent.com/v2/bills/348104",
            billItems: [
                .init(url: "https://api.freeagent.com/v2/bill_items/1"),
                .init(url: "https://api.freeagent.com/v2/bill_items/2"),
            ]
        )))

        #expect(message == "Created item https://api.freeagent.com/v2/bill_items/2 on bill 348104")
    }

    @Test("names only the bill when FreeAgent returns no items")
    func namesBillWithoutItems() throws {
        let command = try BillCreateItemCommand.parse(arguments)

        let message = command.success(for: .init(bill: .init(url: "https://api.freeagent.com/v2/bills/348104")))

        #expect(message == "Created item on bill 348104")
    }

    // MARK: Private

    private let arguments = ["348104", "--category", "285", "--description", "Hosting", "--total-value", "120.0"]
}
