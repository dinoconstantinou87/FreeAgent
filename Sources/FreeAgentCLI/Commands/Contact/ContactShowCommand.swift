import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show contact details"
    )

    static let title = "Contact"

    static var sections: [FieldSection<Components.Schemas.Contact>] {
        FieldSection("Details") {
            Field("Organisation") { .text($0.organisationName) }
            Field("Name") { .text([$0.firstName, $0.lastName].compactMap(\.self).joined(separator: " ")) }
            Field("Status") { .status($0.status.rawValue) }
            Field("Email") { .text($0.email) }
            Field("Billing Email") { .text($0.billingEmail) }
            Field("Phone") { .text($0.phoneNumber) }
            Field("Mobile") { .text($0.mobile) }
        }
        FieldSection("Address") {
            Field("Address") { .text([$0.address1, $0.address2, $0.address3].compactMap(\.self).joined(separator: ", ")) }
            Field("Town") { .text($0.town) }
            Field("Region") { .text($0.region) }
            Field("Postcode") { .text($0.postcode) }
            Field("Country") { .text($0.country) }
        }
        FieldSection("Invoicing") {
            Field("Payment Terms In Days") { .number($0.defaultPaymentTermsInDays) }
            Field("Locale") { .text($0.locale) }
            Field("Charge Sales Tax") { .text($0.chargeSalesTax) }
            Field("Sales Tax Registration") { .text($0.salesTaxRegistrationNumber) }
            Field("Contact Name On Invoices") { .flag($0.contactNameOnInvoices) }
            Field("Own Invoice Sequence") { .flag($0.usesContactInvoiceSequence) }
            Field("Direct Debit") { .status($0.directDebitMandateState) }
        }
        FieldSection("CIS") {
            Field("Subcontractor") { .flag($0.isCisSubcontractor) }
            Field("Deduction Rate") { .text($0.cisDeductionRate) }
            Field("Unique Tax Reference") { .text($0.uniqueTaxReference) }
            Field("Verification Number") { .text($0.subcontractorVerificationNumber) }
        }
        FieldSection("Activity") {
            Field("Account Balance") { .currency($0.accountBalance, code: nil) }
            Field("Active Projects") { .number($0.activeProjectsCount) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Contact") { .id(url: $0.url) }
        }
    }

    @Argument(help: "Contact ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.ContactResponse {
        try await client.showContact(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.ContactResponse) -> Components.Schemas.Contact {
        response.contact
    }
}
