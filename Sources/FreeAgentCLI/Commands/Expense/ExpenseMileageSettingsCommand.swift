import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseMileageSettingsCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "mileage-settings",
        abstract: "Show the engine types, engine sizes and mileage rates for mileage claims"
    )

    static let title = "Mileage Settings"

    static let sections = [FieldSection<Components.Schemas.MileageSettings>]()

    static let tables = [
        FieldTable<Components.Schemas.MileageSettings>("Engines", items: engines) {
            Field("From") { .date($0.from) }
            Field("To") { .date($0.to) }
            Field("Engine Type") { .text($0.engineType) }
            Field("Engine Sizes") { .text($0.engineSizes.joined(separator: ", ")) }
        },
        FieldTable("Rates", items: rates) {
            Field("From") { .date($0.from) }
            Field("To") { .date($0.to) }
            Field("Vehicle") { .text($0.vehicle) }
            Field("Basic Rate") { .currency($0.rate.basicRate, code: "GBP") }
            Field("Additional Rate") { .currency($0.rate.additionalRate, code: "GBP") }
            Field("Basic Rate Miles") { .number($0.basicRateLimit) }
        },
    ]

    @Flag(name: .long, help: "Output JSON")
    var json = false

    @Sendable
    static func engines(
        in settings: Components.Schemas.MileageSettings
    ) -> [(from: String, to: String, engineType: String, engineSizes: [String])] {
        settings.engineTypeAndSizeOptions.flatMap { period in
            period.value.additionalProperties
                .sorted { $0.key < $1.key }
                .map { (from: period.from, to: period.to, engineType: $0.key, engineSizes: $0.value) }
        }
    }

    @Sendable
    static func rates(
        in settings: Components.Schemas.MileageSettings
    ) -> [(from: String, to: String, vehicle: String, rate: Components.Schemas.MileageRate, basicRateLimit: Int?)] {
        settings.mileageRates.flatMap { period in
            [
                (vehicle: "Car", rate: period.value.car),
                (vehicle: "Motorcycle", rate: period.value.motorcycle),
                (vehicle: "Bicycle", rate: period.value.bicycle),
            ].map {
                (
                    from: period.from,
                    to: period.to,
                    vehicle: $0.vehicle,
                    rate: $0.rate,
                    basicRateLimit: period.value.basicRateLimit
                )
            }
        }
    }

    func fetch(client: Client) async throws -> Components.Schemas.MileageSettingsResponse {
        try await client.showMileageSettings(.init()).ok.body.json
    }

    func record(in response: Components.Schemas.MileageSettingsResponse) -> Components.Schemas.MileageSettings {
        response.mileageSettings
    }
}
