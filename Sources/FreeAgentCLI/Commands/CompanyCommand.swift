import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIURLSession

struct CompanyCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "company",
        abstract: "Get company details"
    )

    static let title = "Company"

    static var sections: [FieldSection<Components.Schemas.Company>] {
        FieldSection("Details") {
            Field("Name") { .text($0.name) }
            Field("Subdomain") { .text($0.subdomain) }
            Field("Type") { .text($0._type) }
            Field("Currency") { .text($0.currency) }
            Field("Registration Number") { .text($0.companyRegistrationNumber) }
            Field("Mileage Units") { .text($0.mileageUnits) }
        }
        FieldSection("Dates") {
            Field("Company Start") { .date($0.companyStartDate) }
            Field("FreeAgent Start") { .date($0.freeagentStartDate) }
            Field("First Year End") { .date($0.firstAccountingYearEnd) }
        }
        FieldSection("Sales Tax") {
            Field("Status") { .status($0.salesTaxRegistrationStatus) }
            Field("Name") { .text($0.salesTaxName) }
            Field("Number") { .text($0.salesTaxRegistrationNumber) }
            Field("Effective Date") { .date($0.salesTaxEffectiveDate) }
            Field("Rates") { .text($0.salesTaxRates?.compactMap { FieldValue.percent($0).formatted() }.joined(separator: ", ")) }
            Field("Initial Basis") { .text($0.initialVatBasis) }
            Field("Flat Rate Type") { .text($0.vatFrsType) }
        }
        FieldSection("Address") {
            Field("Address") { .text([$0.address1, $0.address2].compactMap(\.self).joined(separator: ", ")) }
            Field("Town") { .text($0.town) }
            Field("Region") { .text($0.region) }
            Field("Postcode") { .text($0.postcode) }
            Field("Country") { .text($0.country) }
            Field("Email") { .text($0.contactEmail) }
            Field("Phone") { .text($0.contactPhone) }
            Field("Website") { .text($0.website) }
        }
    }

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.CompanyResponse {
        try await client.companyDetails().ok.body.json
    }

    func record(in response: Components.Schemas.CompanyResponse) -> Components.Schemas.Company {
        response.company
    }
}
