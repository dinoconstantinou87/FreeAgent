import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("company")))
struct CompanyIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/company returns company details")
    func companyDetails() async throws {
        let response = try await client.companyDetails()
        let company = try response.ok.body.json.company

        // Required fields
        #expect(company.url == "https://api.sandbox.freeagent.com/v2/company")
        #expect(company.name == "Acme Technologies Ltd")
        #expect(company.subdomain == "acmetechnologiesltd")
        #expect(company._type == "UkLimitedCompany")
        #expect(company.currency == "GBP")
        #expect(company.mileageUnits == "miles")
        #expect(company.companyStartDate == "2025-01-01")
        #expect(company.freeagentStartDate == "2025-01-01")
        #expect(company.firstAccountingYearEnd == "2026-01-31")

        // Optional fields
        #expect(company.companyRegistrationNumber == "12345678")
        #expect(company.salesTaxRegistrationStatus == "Registered")
        #expect(company.salesTaxName == "VAT")
        #expect(company.salesTaxIsValueAdded == true)
        #expect(company.salesTaxRegistrationNumber == "999888777")
        #expect(company.salesTaxEffectiveDate == "2025-01-01")
        #expect(company.initialVatBasis == "Invoice")
        #expect(company.country == "United Kingdom")
        #expect(company.address1 == "42 Innovation Street")
        #expect(company.town == "Manchester")
        #expect(company.postcode == "M1 4BT")
    }

    // MARK: Private

    private let client: Client

}
