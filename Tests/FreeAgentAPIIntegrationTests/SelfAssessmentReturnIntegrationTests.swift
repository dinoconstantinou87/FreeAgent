import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("self_assessment_returns")))
struct SelfAssessmentReturnIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/users/:user_id/self_assessment_returns returns a typed list")
    func listSelfAssessmentReturns() async throws {
        let returns = try await client.listSelfAssessmentReturns(.init(path: .init(userId: userId()))).ok.body.json
            .selfAssessmentReturns

        #expect(!returns.isEmpty)

        let selfAssessmentReturn = try #require(returns.first)
        #expect(selfAssessmentReturn.url.contains("/self_assessment_returns/"))
        #expect(selfAssessmentReturn.periodEndsOn != nil)
        #expect(selfAssessmentReturn.periodStartsOn != nil)
        #expect(selfAssessmentReturn.filingDueOn != nil)
        #expect(selfAssessmentReturn.filingStatus != nil)

        let payment = try #require(selfAssessmentReturn.payments?.first)
        #expect(payment.label != nil)
        #expect(payment.dueOn != nil)
        #expect(payment.amountDue != nil)
    }

    @Test("GET /v2/users/:user_id/self_assessment_returns/:period_ends_on returns a typed return")
    func showSelfAssessmentReturn() async throws {
        let userId = try await userId()
        let listed = try #require(
            try await client.listSelfAssessmentReturns(.init(path: .init(userId: userId))).ok.body.json
                .selfAssessmentReturns.first
        )
        let periodEndsOn = try #require(listed.periodEndsOn)

        let selfAssessmentReturn = try await client.showSelfAssessmentReturn(
            .init(path: .init(userId: userId, periodEndsOn: periodEndsOn))
        ).ok.body.json.selfAssessmentReturn

        #expect(selfAssessmentReturn.url == listed.url)
        #expect(selfAssessmentReturn.filingStatus == listed.filingStatus)
        #expect(selfAssessmentReturn.periodStartsOn == listed.periodStartsOn)
        #expect(selfAssessmentReturn.filingDueOn == listed.filingDueOn)
        #expect(selfAssessmentReturn.payments?.map(\.dueOn) == listed.payments?.map(\.dueOn))
    }

    @Test("A self assessment return can be marked as filed and back to unfiled")
    func markAsFiledAndUnfiled() async throws {
        let userId = try await userId()
        let selfAssessmentReturn = try #require(
            try await client.listSelfAssessmentReturns(.init(path: .init(userId: userId))).ok.body.json
                .selfAssessmentReturns.first { $0.filingStatus == "unfiled" }
        )
        let periodEndsOn = try #require(selfAssessmentReturn.periodEndsOn)

        let filed = try await client.markSelfAssessmentReturnAsFiled(
            .init(path: .init(userId: userId, periodEndsOn: periodEndsOn))
        ).ok.body.json.selfAssessmentReturn
        #expect(filed.filingStatus == "marked_as_filed")

        let unfiled = try await client.markSelfAssessmentReturnAsUnfiled(
            .init(path: .init(userId: userId, periodEndsOn: periodEndsOn))
        ).ok.body.json.selfAssessmentReturn
        #expect(unfiled.filingStatus == "unfiled")
    }

    // MARK: Private

    private let client: Client

    private func userId() async throws -> String {
        let url = try await client.showCurrentUser(.init()).ok.body.json.user.url
        return try #require(URL(string: url)?.lastPathComponent)
    }

}
