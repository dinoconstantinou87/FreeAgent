# FreeAgent CLI

A command-line interface for the [FreeAgent](https://www.freeagent.com/) accounting API, built with Swift.

Manage your invoices, bills, expenses, bank accounts, contacts and more — directly from the terminal.

## Installation

### Homebrew

```bash
brew install freeagent
```

### Build from source

```bash
git clone https://github.com/dinoconstantinou87/FreeAgent.git
cd FreeAgent
swift build -c release
```

Requires macOS 15+ and Swift 6.1+.

## Getting Started

### 1. Create a FreeAgent OAuth App

Sign in at [dev.freeagent.com](https://dev.freeagent.com/), create a new app, and note your **OAuth app ID**, **secret**, and **redirect URI**.

### 2. Configure and authenticate

```bash
$ freeagent setup
$ freeagent auth login
```

`setup` saves your OAuth credentials to `~/.freeagent/config.json`. `login` opens your browser for authorization — tokens are stored securely in the macOS Keychain.

### 3. You're ready

```bash
$ freeagent --help
```

Run `freeagent <command> --help` for detailed usage of any command.

## Development

The API client is auto-generated from an OpenAPI specification using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator):

```bash
make generate    # bundle OpenAPI spec and regenerate Swift client
make build       # build the project
make help        # see all available targets
```

## License

[MIT](LICENSE)
