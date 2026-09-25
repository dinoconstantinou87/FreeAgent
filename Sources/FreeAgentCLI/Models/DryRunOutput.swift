import FreeAgentAPI

struct DryRunOutput: Codable {
    enum CodingKeys: String, CodingKey {
        case dryRun = "dry_run"
    }

    let dryRun: DryRunRequest
}
