import Foundation
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct AmountDuePayloadCustomStringConvertibleTests {

    // MARK: Internal

    @Test("keeps a string amount as FreeAgent sends it")
    func describesStringAmount() throws {
        #expect(try amountDue(#""413.06""#).description == "413.06")
    }

    @Test("describes the number 0 that VAT returns send when nothing is due")
    func describesNumericAmount() throws {
        #expect(try amountDue("0").description == "0.0")
    }

    // MARK: Private

    private func amountDue(_ json: String) throws -> Components.Schemas.TaxReturnPayment.AmountDuePayload {
        let payment = try JSONDecoder().decode(
            Components.Schemas.TaxReturnPayment.self,
            from: Data(#"{"amount_due": \#(json)}"#.utf8)
        )

        return try #require(payment.amountDue)
    }

}
