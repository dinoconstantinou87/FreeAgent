import ArgumentParser
import FreeAgentAPI

struct TaskOptions: ParsableArguments {
    @Option(name: .long, help: "Whether the task is billed to the client")
    var isBillable: Bool?

    @Option(name: .long, help: "Billing rate per billing period, e.g. 95")
    var billingRate: Double?

    @Option(name: .long, help: "Unit of the billing rate")
    var billingPeriod: Components.Schemas.BillingPeriod?

    @Option(name: .long, help: "Status")
    var status: Components.Schemas.TaskStatus?

    func createPayload(name: String) -> Components.Schemas.TaskCreatePayload {
        .init(
            name: name,
            isBillable: isBillable,
            billingRate: billingRate,
            billingPeriod: billingPeriod,
            status: status
        )
    }

    func updatePayload(name: String?) -> Components.Schemas.TaskUpdatePayload {
        .init(
            name: name,
            isBillable: isBillable,
            billingRate: billingRate,
            billingPeriod: billingPeriod,
            status: status
        )
    }
}
