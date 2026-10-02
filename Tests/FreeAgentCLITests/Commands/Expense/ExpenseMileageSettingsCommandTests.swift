import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct ExpenseMileageSettingsCommandTests {

    // MARK: Internal

    @Test("lists each period's engine types in name order")
    func engines() {
        let rows = ExpenseMileageSettingsCommand.engines(in: settings)

        #expect(rows.map(\.engineType) == ["Diesel", "Electric (Home charger)", "Petrol"])
        #expect(rows.allSatisfy { $0.from == "2025-09-01" && $0.to == "2099-12-31" })
        #expect(rows.first?.engineSizes == ["Up to 1600cc", "1601-2000cc", "Over 2000cc"])
    }

    @Test("lists a row per vehicle for each period, carrying the period's basic rate limit")
    func rates() {
        let rows = ExpenseMileageSettingsCommand.rates(in: settings)

        #expect(rows.map(\.vehicle) == ["Car", "Motorcycle", "Bicycle"])
        #expect(rows.map(\.rate.basicRate) == ["0.55", "0.24", "0.2"])
        #expect(rows.allSatisfy { $0.from == "2026-04-06" && $0.basicRateLimit == 10000 })
    }

    // MARK: Private

    private let settings = Components.Schemas.MileageSettings(
        engineTypeAndSizeOptions: [
            .init(
                from: "2025-09-01",
                to: "2099-12-31",
                value: .init(additionalProperties: [
                    "Petrol": ["Up to 1400cc", "1401-2000cc", "Over 2000cc"],
                    "Diesel": ["Up to 1600cc", "1601-2000cc", "Over 2000cc"],
                    "Electric (Home charger)": ["All"],
                ])
            )
        ],
        mileageRates: [
            .init(
                from: "2026-04-06",
                to: "2099-12-31",
                value: .init(
                    car: .init(basicRate: "0.55", additionalRate: "0.25"),
                    motorcycle: .init(basicRate: "0.24", additionalRate: "0.24"),
                    bicycle: .init(basicRate: "0.2", additionalRate: "0.2"),
                    basicRateLimit: 10000
                )
            )
        ]
    )
}
