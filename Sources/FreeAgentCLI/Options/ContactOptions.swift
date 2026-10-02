import ArgumentParser
import FreeAgentAPI

struct ContactOptions: ParsableArguments {
    @Option(name: .long, help: "Organisation name")
    var organisationName: String?

    @Option(name: .long, help: "First name")
    var firstName: String?

    @Option(name: .long, help: "Last name")
    var lastName: String?

    @Option(name: .long, help: "Email address, or several separated by commas")
    var email: String?

    @Option(name: .long, help: "Billing email address")
    var billingEmail: String?

    @Option(name: .long, help: "Phone number")
    var phoneNumber: String?

    @Option(name: .long, help: "Mobile number")
    var mobile: String?

    @Option(name: .long, help: "First line of the address")
    var address1: String?

    @Option(name: .long, help: "Second line of the address")
    var address2: String?

    @Option(name: .long, help: "Third line of the address")
    var address3: String?

    @Option(name: .long, help: "Town")
    var town: String?

    @Option(name: .long, help: "Region or state")
    var region: String?

    @Option(name: .long, help: "Postcode or ZIP code")
    var postcode: String?

    @Option(name: .long, help: "Country")
    var country: String?

    @Option(name: .long, help: "Default payment terms in days")
    var defaultPaymentTermsInDays: Int?

    @Option(name: .long, help: "Language of the contact's invoices and estimates")
    var locale: Components.Schemas.ContactLocale?

    @Option(name: .long, help: "Whether invoices to the contact charge sales tax")
    var chargeSalesTax: Components.Schemas.ContactChargeSalesTax?

    @Option(name: .long, help: "Sales tax registration number shown on invoices")
    var salesTaxRegistrationNumber: String?

    @Option(
        name: .customLong("contact-name-on-invoices"),
        help: "Show the contact's name on invoices as well as the organisation name"
    )
    var nameOnInvoices: Bool?

    @Option(name: .long, help: "Number the contact's invoices in their own sequence")
    var usesContactInvoiceSequence: Bool?

    @Option(name: .long, help: "Status - a hidden contact is left out of the default list")
    var status: Components.Schemas.ContactStatus?

    var createPayload: Components.Schemas.ContactCreatePayload {
        .init(
            organisationName: organisationName,
            firstName: firstName,
            lastName: lastName,
            email: email,
            billingEmail: billingEmail,
            phoneNumber: phoneNumber,
            mobile: mobile,
            address1: address1,
            address2: address2,
            address3: address3,
            town: town,
            region: region,
            postcode: postcode,
            country: country,
            contactNameOnInvoices: nameOnInvoices,
            defaultPaymentTermsInDays: defaultPaymentTermsInDays,
            locale: locale,
            chargeSalesTax: chargeSalesTax,
            salesTaxRegistrationNumber: salesTaxRegistrationNumber,
            usesContactInvoiceSequence: usesContactInvoiceSequence,
            status: status
        )
    }

    var updatePayload: Components.Schemas.ContactUpdatePayload {
        .init(
            organisationName: organisationName,
            firstName: firstName,
            lastName: lastName,
            email: email,
            billingEmail: billingEmail,
            phoneNumber: phoneNumber,
            mobile: mobile,
            address1: address1,
            address2: address2,
            address3: address3,
            town: town,
            region: region,
            postcode: postcode,
            country: country,
            contactNameOnInvoices: nameOnInvoices,
            defaultPaymentTermsInDays: defaultPaymentTermsInDays,
            locale: locale,
            chargeSalesTax: chargeSalesTax,
            salesTaxRegistrationNumber: salesTaxRegistrationNumber,
            usesContactInvoiceSequence: usesContactInvoiceSequence,
            status: status
        )
    }
}
