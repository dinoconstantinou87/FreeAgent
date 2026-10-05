import Testing

@testable import FreeAgentTools

struct EndpointTests {
    @Test(
        "matches a documented placeholder or example ID with a spec placeholder",
        arguments: ["/v2/tasks/:id", "/v2/tasks/{id}", "/v2/tasks/1"]
    )
    func placeholder(path: String) {
        #expect(Endpoint(method: "GET", path: path).key == "GET /v2/tasks/{}")
    }

    @Test("keeps literal segments and the method apart")
    func literals() {
        let timeline = Endpoint(method: "GET", path: "/v2/invoices/timeline")

        #expect(timeline.key == "GET /v2/invoices/timeline")
        #expect(timeline.key != Endpoint(method: "PUT", path: "/v2/invoices/timeline").key)
    }

    @Test("names placeholders in every position")
    func nestedPlaceholders() {
        let endpoint = Endpoint(method: "PUT", path: "/v2/users/:user_id/self_assessment_returns/{period_ends_on}/mark_as_filed")

        #expect(endpoint.key == "PUT /v2/users/{}/self_assessment_returns/{}/mark_as_filed")
    }
}
