# FreeAgent CLI

A macOS CLI tool for interacting with the FreeAgent API, built with Swift 6.1.

## Commands

- `make generate` — Bundle OpenAPI spec and generate Swift client code
- `make build` or `swift build` — Build the project
- `swift test` — Run unit tests
- `make format` — Run SwiftFormat
- `make lint` — Run SwiftLint

## Before Committing

Always run `make format` and `make lint` before committing and pushing.

## Project Structure

- `Sources/FreeAgentAPI/` — API library (auth, generated client, type overrides)
- `Sources/FreeAgentCLI/` — CLI executable (commands, config, OAuth flow)
- `Sources/OpenAPIBundler/` — Tool to bundle split OpenAPI YAML files
- `Tests/FreeAgentAPITests/` — Unit tests (mirrors source directory structure)
- `openapi/` — Split OpenAPI spec files

## Testing

- Use **Swift Testing** (`import Testing`, `@Test`, `#expect`)
- Use **Mockable** (`@Mockable` on protocols) for generating mocks
- Test directory structure should mirror `Sources/FreeAgentAPI/`
- Protocols suffixed with `Interface` (e.g. `AuthStorageInterface`) for mockability
