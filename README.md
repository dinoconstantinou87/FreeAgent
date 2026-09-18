# FreeAgent CLI

[![CI](https://github.com/dinoconstantinou87/FreeAgent/actions/workflows/ci.yml/badge.svg)](https://github.com/dinoconstantinou87/FreeAgent/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/dinoconstantinou87/FreeAgent)](https://github.com/dinoconstantinou87/FreeAgent/releases/latest)

An unofficial command-line interface for the [FreeAgent](https://www.freeagent.com/) accounting API, built with Swift - for UK contractors and small businesses running their books through FreeAgent.

Manage your invoices, bills, expenses, bank accounts, contacts and more - directly from the terminal.

> This project is not affiliated with, endorsed by, or supported by FreeAgent Central Limited. "FreeAgent" is their trademark.

![freeagent in use](docs/demo.gif)

## Features

- **Invoices end to end** - create one, add line items, mark it sent, email it to the contact, download the PDF, read its timeline, and inspect recurring invoices.
- **Bank reconciliation** - list the transactions FreeAgent has not matched yet and explain them against a category, or against a bill, invoice or salary payment to mark it paid.
- **Expenses, bills and contacts** - record expenses and bills as they come in, and create the contacts they belong to.
- **JSON on stdout** - every command emits JSON, so results pipe straight into `jq` and compose with the rest of your toolchain.
- **Sandbox and production** - choose the environment at login; OAuth tokens are held in the macOS Keychain rather than a dotfile.
- **Generated from an OpenAPI spec** - the API client is produced by [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) from a spec kept in this repo, so the CLI tracks the API rather than drifting from it.

## Examples

```bash
# What is still owed to you
freeagent invoice list --view open_or_overdue

# Which bank transactions still need explaining
freeagent bank-transaction list --bank-account 123 --view unexplained

# Explain one as payment of a bill, which marks that bill paid
freeagent explanation create --bank-transaction 456 --bank-account 123 \
  --paid-bill 789 --dated-on 2026-09-18 \
  --description "Office rent" --gross-value -730.0

# Save an invoice as a PDF
freeagent invoice pdf 12345 | jq -r '.pdf.content' | base64 --decode > invoice-12345.pdf

# Compose with anything that reads JSON
freeagent invoice list --view overdue | jq -c '.invoices[] | {reference, contact_name, due_value}'
```

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
