# FreeAgent CLI

A command-line interface for the [FreeAgent](https://www.freeagent.com/) accounting API, built with Swift.

Manage your invoices, bills, expenses, bank accounts, contacts and more — directly from the terminal.

<p align="center">
  <img src="docs/demo.gif" alt="freeagent in use" width="80%" />
</p>

## Chase What You're Owed

See everything outstanding, then email an invoice to its contact:

```bash
freeagent invoice list --view open_or_overdue
freeagent invoice send-email 12345 --subject "Invoice 12345 from Acme Ltd"
```

Mark it sent once it has gone out, or save the PDF to disk:

```bash
freeagent invoice mark-sent 12345
freeagent invoice pdf 12345 | jq -r '.pdf.content' | base64 --decode > invoice-12345.pdf
```

## Explain Bank Transactions

Bank transactions are scoped to an account, so look up its URL first, then find
everything FreeAgent has not matched yet:

```bash
freeagent bank-account list
freeagent bank-transaction list \
  --bank-account https://api.freeagent.com/v2/bank_accounts/123 \
  --view unexplained
```

Explain one as payment of a bill, which marks that bill paid:

```bash
freeagent explanation create \
  --bank-transaction https://api.freeagent.com/v2/bank_transactions/456 \
  --bank-account https://api.freeagent.com/v2/bank_accounts/123 \
  --paid-bill https://api.freeagent.com/v2/bills/789 \
  --dated-on 2026-09-18 \
  --description "Office rent" \
  --gross-value -730.0
```

## Script It

Every command prints JSON, so your accounts compose with the rest of your toolchain:

```bash
freeagent invoice list --view overdue | jq '.invoices[] | {reference, contact_name, due_value}'
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
