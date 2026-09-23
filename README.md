# FreeAgent CLI

[![CI](https://github.com/dinoconstantinou87/FreeAgent/actions/workflows/ci.yml/badge.svg)](https://github.com/dinoconstantinou87/FreeAgent/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/dinoconstantinou87/FreeAgent)](https://github.com/dinoconstantinou87/FreeAgent/releases/latest)

A command-line interface for the [FreeAgent](https://www.freeagent.com/) accounting API, built with Swift.

Manage your invoices, bills, expenses, bank accounts, contacts and more — directly from the terminal.

![freeagent in use](docs/demo.gif)

## Installation

### Homebrew

```bash
brew install dinoconstantinou87/tap/freeagent
```

## Getting Started

### 1. Create A FreeAgent OAuth App

Sign in at [dev.freeagent.com](https://dev.freeagent.com/), create a new app, and note your **OAuth app ID**, **secret**, and **redirect URI**.

### 2. Configure And Authenticate

```bash
$ freeagent setup
$ freeagent auth login
```

`setup` saves your OAuth credentials to `~/.freeagent/config.json`. `login` opens your browser for authorization — tokens are stored securely in the macOS Keychain.

The `FREEAGENT_AUTH_KEY`, `FREEAGENT_AUTH_SECRET`, `FREEAGENT_AUTH_CALLBACK_URL` and `FREEAGENT_AUTH_ENVIRONMENT` environment variables take precedence over the file, so CI can skip `setup`. `auth login --environment` takes precedence over both.

## Reference

Use `--help` on any command to explore its subcommands, flags and accepted values:

```bash
$ freeagent --help
$ freeagent invoice list --help
```

## Development

The API client is auto-generated from an OpenAPI specification using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator):

```bash
make generate    # bundle OpenAPI spec and regenerate Swift client
make build       # build the project
make help        # see all available targets
```

## License

[MIT](LICENSE)
