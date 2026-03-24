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

        var expected = Components.Schemas.Company(
            url: "https://api.sandbox.freeagent.com/v2/company",
            name: "Acme Technologies Ltd",
            subdomain: "acmetechnologiesltd",
            _type: "UkLimitedCompany",
            currency: "GBP",
            mileageUnits: "miles",
            companyStartDate: "2025-01-01",
            freeagentStartDate: "2025-01-01",
            firstAccountingYearEnd: "2026-01-31",
            companyRegistrationNumber: "12345678",
            salesTaxRegistrationStatus: "Registered",
            salesTaxName: "VAT",
            salesTaxRegistrationNumber: "999888777",
            salesTaxEffectiveDate: "2025-01-01",
            salesTaxIsValueAdded: true,
            salesTaxRates: ["20.0", "5.0", "0.0"],
            ecVatReportingEnabled: false,
            initialVatBasis: "Invoice",
            cisEnabled: false,
            cisSubcontractor: false,
            cisContractor: false,
            address1: "42 Innovation Street",
            town: "Manchester",
            postcode: "M1 4BT",
            country: "United Kingdom"
        )

        expected.createdAt = company.createdAt
        expected.updatedAt = company.updatedAt

        #expect(company == expected)
    }

    // MARK: Private

    private let client: Client

}
