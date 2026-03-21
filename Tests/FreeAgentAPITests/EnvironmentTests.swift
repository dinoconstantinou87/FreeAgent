import Foundation
import Testing

@testable import FreeAgentAPI

@Suite("Environment")
struct EnvironmentTests {

    @Test("production baseURL points to api.freeagent.com", .tags(.production))
    func productionBaseURL() {
        let url = Environment.production.baseURL

        #expect(url.host() == "api.freeagent.com")
        #expect(url.scheme == "https")
    }

    @Test("sandbox baseURL points to api.sandbox.freeagent.com", .tags(.sandbox))
    func sandboxBaseURL() {
        let url = Environment.sandbox.baseURL

        #expect(url.host() == "api.sandbox.freeagent.com")
        #expect(url.scheme == "https")
    }

    @Test("url appends path to baseURL")
    func urlAppendsPath() {
        let url = Environment.sandbox.url("v2/token_endpoint")

        #expect(url.absoluteString.hasSuffix("/v2/token_endpoint"))
    }

    @Test("is encodable and decodable", arguments: [Environment.production, .sandbox])
    func codable(environment: Environment) throws {
        let data = try JSONEncoder().encode(environment)
        let decoded = try JSONDecoder().decode(Environment.self, from: data)

        #expect(decoded == environment)
    }
}

extension Tag {
    @Tag static var production: Self
    @Tag static var sandbox: Self
}
