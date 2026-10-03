import ArgumentParser
import FreeAgentAPI

struct UserProfileOptions: ParsableArguments {
    @Option(name: .long, help: "What the user can see and do in FreeAgent")
    var permissionLevel: PermissionLevel?

    @Option(name: .long, help: "UK National Insurance number, e.g. AB123456C")
    var niNumber: String?

    @Option(name: .long, help: "10-digit UK Unique Taxpayer Reference")
    var uniqueTaxReference: String?

    @Option(name: .long, help: "Opening mileage as of the company start date")
    var openingMileage: Double?

    @Option(name: .long, help: "Whether the user is hidden")
    var hidden: Bool?

    func createPayload(
        email: String,
        firstName: String,
        lastName: String,
        role: Components.Schemas.UserRole,
        sendInvitation: Bool
    ) -> Components.Schemas.UserCreatePayload {
        .init(
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            permissionLevel: permissionLevel,
            niNumber: niNumber,
            uniqueTaxReference: uniqueTaxReference,
            openingMileage: openingMileage,
            hidden: hidden,
            sendInvitation: sendInvitation
        )
    }

    func updatePayload(
        email: String?,
        firstName: String?,
        lastName: String?,
        role: Components.Schemas.UserRole?
    ) -> Components.Schemas.UserUpdatePayload {
        .init(
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            permissionLevel: permissionLevel,
            niNumber: niNumber,
            uniqueTaxReference: uniqueTaxReference,
            openingMileage: openingMileage,
            hidden: hidden
        )
    }
}
