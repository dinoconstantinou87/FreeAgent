import Configuration
import Foundation
import Testing

@testable import FreeAgentAPI

struct AuthStorageTests {

    // MARK: Lifecycle

    init() {
        file = CredentialFile(
            directory: FileManager.default.temporaryDirectory
                .appendingPathComponent("AuthStorageTests")
                .appendingPathComponent(UUID().uuidString)
        )
    }

    // MARK: Internal

    @Test("get returns nil when no provider has a token")
    func getReturnsNilWhenEmpty() async throws {
        #expect(try await storage().get() == nil)
    }

    @Test("get reads the credential written to the file")
    func getReadsWrittenCredential() async throws {
        let expiresAt = Date(timeIntervalSince1970: 1_700_000_000)
        let storage = storage()

        try storage.set(
            AuthCredential(
                token: "stored-token",
                refreshToken: "stored-refresh",
                expiresAt: expiresAt,
                environment: .sandbox
            )
        )

        let result = try await storage.get()

        #expect(result?.token == "stored-token")
        #expect(result?.refreshToken == "stored-refresh")
        #expect(result?.expiresAt == expiresAt)
        #expect(result?.environment == .sandbox)
    }

    @Test("get returns nil when the credential file is corrupted")
    func getReturnsNilOnCorruptedFile() async throws {
        try file.write(Data("not json".utf8))

        #expect(try await storage().get() == nil)
    }

    @Test("get prefers FREEAGENT_TOKEN over the stored credential")
    func getPrefersConfiguredToken() async throws {
        let storage = storage(["FREEAGENT_TOKEN": "configured"])
        try storage.set(stored(environment: .sandbox))

        #expect(try await storage.get()?.token == "configured")
    }

    @Test("a configured token keeps the stored environment and refresh token")
    func configuredTokenKeepsStoredFields() async throws {
        let storage = storage(["FREEAGENT_TOKEN": "configured"])
        try storage.set(stored(environment: .sandbox))

        let result = try await storage.get()

        #expect(result?.token == "configured")
        #expect(result?.environment == .sandbox)
        #expect(result?.refreshToken == "stored-refresh")
    }

    @Test("a configured token defaults to production with nothing stored")
    func configuredTokenDefaultsToProduction() async throws {
        #expect(try await storage(["FREEAGENT_TOKEN": "configured"]).get()?.environment == .production)
    }

    @Test("FREEAGENT_ENVIRONMENT overrides the stored environment", arguments: Environment.allCases)
    func configuredEnvironmentWins(environment: Environment) async throws {
        let storage = storage([
            "FREEAGENT_TOKEN": "configured",
            "FREEAGENT_ENVIRONMENT": environment.rawValue,
        ])
        try storage.set(stored(environment: .sandbox))

        #expect(try await storage.get()?.environment == environment)
    }

    @Test("an unrecognised FREEAGENT_ENVIRONMENT falls back to production")
    func unknownConfiguredEnvironmentFallsBack() async throws {
        let storage = storage([
            "FREEAGENT_TOKEN": "configured",
            "FREEAGENT_ENVIRONMENT": "staging",
        ])

        #expect(try await storage.get()?.environment == .production)
    }

    @Test("an empty FREEAGENT_TOKEN masks the stored credential")
    func emptyConfiguredTokenMasksStore() async throws {
        let storage = storage(["FREEAGENT_TOKEN": ""])
        try storage.set(stored(environment: .sandbox))

        #expect(try await storage.get() == nil)
    }

    @Test("get reflects a credential written after an earlier read")
    func getReflectsLaterWrites() async throws {
        let storage = storage()

        #expect(try await storage.get() == nil)

        try storage.set(stored(environment: .sandbox))

        #expect(try await storage.get()?.token == "stored-token")
    }

    @Test("set writes the credential readable only by its owner")
    func setWritesOwnerOnlyPermissions() throws {
        try storage().set(stored(environment: .production))

        let attributes = try FileManager.default.attributesOfItem(atPath: file.url.path)

        #expect((attributes[.posixPermissions] as? NSNumber)?.int16Value == 0o600)
    }

    @Test("clear removes the stored credential")
    func clearRemovesCredential() async throws {
        let storage = storage()
        try storage.set(stored(environment: .sandbox))

        try storage.clear()

        #expect(try await storage.get() == nil)
        #expect(!FileManager.default.fileExists(atPath: file.url.path))
    }

    @Test("clear succeeds when nothing is stored")
    func clearToleratesMissingCredential() throws {
        try storage().clear()
    }

    // MARK: Private

    private let file: CredentialFile

    private func storage(_ variables: [String: String] = [:]) -> AuthStorage {
        AuthStorage(
            variables: EnvironmentVariablesProvider(environmentVariables: variables)
                .prefixKeys(with: "freeagent"),
            keychain: nil,
            file: file
        )
    }

    private func stored(environment: Environment) -> AuthCredential {
        AuthCredential(
            token: "stored-token",
            refreshToken: "stored-refresh",
            expiresAt: nil,
            environment: environment
        )
    }

}
