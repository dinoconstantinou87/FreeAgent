import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("corporation_tax_returns")))
struct CorporationTaxReturnIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/corporation_tax_returns returns a typed list")
    func listCorporationTaxReturns() async throws {
        let returns = try await client.listCorporationTaxReturns(.init()).ok.body.json.corporationTaxReturns

        #expect(!returns.isEmpty)

        let corporationTaxReturn = try #require(returns.first)
        #expect(corporationTaxReturn.url.contains("/v2/corporation_tax_returns/"))
        #expect(corporationTaxReturn.periodEndsOn != nil)
        #expect(corporationTaxReturn.periodStartsOn != nil)
        #expect(corporationTaxReturn.amountDue != nil)
        #expect(corporationTaxReturn.paymentDueOn != nil)
        #expect(corporationTaxReturn.filingDueOn != nil)
        #expect(corporationTaxReturn.filingStatus != nil)
    }

    @Test("GET /v2/corporation_tax_returns/:period_ends_on returns a typed return")
    func showCorporationTaxReturn() async throws {
        let listed = try #require(
            try await client.listCorporationTaxReturns(.init()).ok.body.json.corporationTaxReturns.first
        )
        let periodEndsOn = try #require(listed.periodEndsOn)

        let corporationTaxReturn = try await client.showCorporationTaxReturn(
            .init(path: .init(periodEndsOn: periodEndsOn))
        ).ok.body.json.corporationTaxReturn

        #expect(corporationTaxReturn.url == listed.url)
        #expect(corporationTaxReturn.filingStatus == listed.filingStatus)
        #expect(corporationTaxReturn.periodStartsOn == listed.periodStartsOn)
        #expect(corporationTaxReturn.amountDue == listed.amountDue)
    }

    @Test("A corporation tax return can be marked as paid and back to unpaid")
    func markAsPaidAndUnpaid() async throws {
        let corporationTaxReturn = try #require(
            try await client.listCorporationTaxReturns(.init()).ok.body.json.corporationTaxReturns.first {
                $0.paymentStatus == "unpaid"
            }
        )
        let periodEndsOn = try #require(corporationTaxReturn.periodEndsOn)

        let paid = try await client.markCorporationTaxReturnAsPaid(
            .init(path: .init(periodEndsOn: periodEndsOn))
        ).ok.body.json.corporationTaxReturn
        #expect(paid.paymentStatus == "marked_as_paid")

        let unpaid = try await client.markCorporationTaxReturnAsUnpaid(
            .init(path: .init(periodEndsOn: periodEndsOn))
        ).ok.body.json.corporationTaxReturn
        #expect(unpaid.paymentStatus == "unpaid")
    }

    // MARK: Private

    private let client: Client

}
