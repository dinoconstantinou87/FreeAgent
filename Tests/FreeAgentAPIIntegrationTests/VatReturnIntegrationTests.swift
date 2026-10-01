import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("vat_returns")))
struct VatReturnIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/vat_returns returns a typed list, including payments with nothing due")
    func listVatReturns() async throws {
        let returns = try await client.listVatReturns(.init()).ok.body.json.vatReturns

        #expect(!returns.isEmpty)

        let vatReturn = try #require(returns.first)
        #expect(vatReturn.url.contains("/v2/vat_returns/"))
        #expect(vatReturn.periodEndsOn != nil)
        #expect(vatReturn.periodStartsOn != nil)
        #expect(vatReturn.filingDueOn != nil)
        #expect(vatReturn.filingStatus != nil)

        let payment = try #require(vatReturn.payments?.first)
        #expect(payment.label != nil)
        #expect(payment.dueOn != nil)
        #expect(payment.amountDue != nil)
    }

    @Test("GET /v2/vat_returns/:period_ends_on returns a typed return")
    func showVatReturn() async throws {
        let listed = try #require(
            try await client.listVatReturns(.init()).ok.body.json.vatReturns.first
        )
        let periodEndsOn = try #require(listed.periodEndsOn)

        let vatReturn = try await client.showVatReturn(.init(path: .init(periodEndsOn: periodEndsOn)))
            .ok.body.json.vatReturn

        #expect(vatReturn.url == listed.url)
        #expect(vatReturn.filingStatus == listed.filingStatus)
        #expect(vatReturn.periodStartsOn == listed.periodStartsOn)
        #expect(vatReturn.filingDueOn == listed.filingDueOn)
    }

    @Test("A VAT return payment can be marked as paid and back to unpaid")
    func markPaymentAsPaidAndUnpaid() async throws {
        let vatReturn = try #require(
            try await client.listVatReturns(.init()).ok.body.json.vatReturns.first { vatReturn in
                vatReturn.payments?.contains { $0.status == "unpaid" } == true
            }
        )
        let periodEndsOn = try #require(vatReturn.periodEndsOn)
        let paymentDate = try #require(vatReturn.payments?.first { $0.status == "unpaid" }?.dueOn)

        let paid = try await client.markVatReturnPaymentAsPaid(
            .init(path: .init(periodEndsOn: periodEndsOn, paymentDate: paymentDate))
        ).ok.body.json.vatReturn
        #expect(paid.payments?.first { $0.dueOn == paymentDate }?.status == "marked_as_paid")

        let unpaid = try await client.markVatReturnPaymentAsUnpaid(
            .init(path: .init(periodEndsOn: periodEndsOn, paymentDate: paymentDate))
        ).ok.body.json.vatReturn
        #expect(unpaid.payments?.first { $0.dueOn == paymentDate }?.status == "unpaid")
    }

    // MARK: Private

    private let client: Client

}
