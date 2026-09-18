#!/usr/bin/env bash
#
# Records the README demo GIF.
#
#   mise run demo
#
# Creates the fixtures the tape needs, records it, then removes them again -
# including the bank transaction explanation the tape itself creates. Teardown
# runs even if recording fails, so a botched run does not leave litter behind.
#
# Refuses to run against anything but a sandbox account. Log in first with:
#
#   freeagent auth login --environment sandbox

set -euo pipefail

readonly SANDBOX_HOST="api.sandbox.freeagent.com"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The tape creates its explanation with this description; teardown finds it
# again by matching on it. Keep the two in step.
readonly EXPLANATION_DESCRIPTION="Office supplies"

# Substring identifying the transaction the tape explains.
readonly TARGET_TRANSACTION="Staples"

INVOICE_ID=""
BANK_ACCOUNT=""

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m==>\033[0m %s\n' "$*" >&2; }
die() {
    printf '\033[31mError:\033[0m %s\n' "$*" >&2
    exit 1
}

# Prefer the working tree's build, and put it on PATH rather than calling it by
# path: the commands VHS types run in its own shell, so they resolve `freeagent`
# themselves and must find the same binary this script checked.
if [[ -x "$REPO_ROOT/.build/debug/freeagent" ]]; then
    PATH="$REPO_ROOT/.build/debug:$PATH"
    export PATH
fi

teardown() {
    local status=$?
    info "Removing fixtures"

    if [[ -n "$BANK_ACCOUNT" ]]; then
        local explanations id
        explanations="$(
            freeagent explanation list --bank-account "$BANK_ACCOUNT" 2>/dev/null |
                jq -r --arg d "$EXPLANATION_DESCRIPTION" \
                    '.bank_transaction_explanations[]? | select(.description == $d) | .url | split("/") | last'
        )" || explanations=""

        for id in $explanations; do
            freeagent explanation delete "$id" >/dev/null 2>&1 &&
                info "    explanation $id" ||
                warn "    could not delete explanation $id"
        done
    fi

    if [[ -n "$INVOICE_ID" ]]; then
        # An invoice has to be back in draft before it can be deleted.
        freeagent invoice mark-draft "$INVOICE_ID" >/dev/null 2>&1 || true
        freeagent invoice delete "$INVOICE_ID" >/dev/null 2>&1 &&
            info "    invoice $INVOICE_ID" ||
            warn "    could not delete invoice $INVOICE_ID"
    fi

    exit $status
}

main() {
    local tool
    for tool in freeagent jq vhs; do
        command -v "$tool" >/dev/null || die "$tool is not installed"
    done

    # Guard first: everything below this point writes to the account.
    local company company_url company_name
    company="$(freeagent company)" || die "could not reach the API - are you logged in?"
    company_url="$(jq -r '.company.url' <<<"$company")"
    company_name="$(jq -r '.company.name' <<<"$company")"

    if [[ "$company_url" != "https://$SANDBOX_HOST/"* ]]; then
        die "refusing to run against ${company_url#https://}
       This script writes to the account, so it only runs against $SANDBOX_HOST.
       Switch with: freeagent auth login --environment sandbox"
    fi
    info "Sandbox account: $company_name"

    BANK_ACCOUNT="$(freeagent bank-account list | jq -r '.bank_accounts[0].url')"
    [[ -n "$BANK_ACCOUNT" && "$BANK_ACCOUNT" != "null" ]] || die "no bank account found"

    # The tape explains a specific transaction, so fail early and clearly rather
    # than recording a GIF of an error.
    local target
    target="$(
        freeagent bank-transaction list --bank-account "$BANK_ACCOUNT" --view unexplained |
            jq -r --arg p "$TARGET_TRANSACTION" \
                '[.bank_transactions[]? | select(.description | test($p))] | length'
    )"
    [[ "$target" -gt 0 ]] || die "no unexplained '$TARGET_TRANSACTION' transaction - the tape has nothing to explain"

    # Fixtures. Dated far enough back that 30 day terms have already lapsed, so
    # it lands in the open_or_overdue view the tape queries.
    info "Creating fixtures"
    local contact dated_on invoice
    contact="$(freeagent contact list | jq -r '.contacts[0].url')"
    [[ -n "$contact" && "$contact" != "null" ]] || die "no contact found to invoice"
    dated_on="$(date -v-60d +%Y-%m-%d 2>/dev/null || date -d '60 days ago' +%Y-%m-%d)"

    invoice="$(freeagent invoice create --contact "$contact" --dated-on "$dated_on" --payment-terms-in-days 30)"
    INVOICE_ID="$(jq -r '.invoice.url | split("/") | last' <<<"$invoice")"
    [[ -n "$INVOICE_ID" && "$INVOICE_ID" != "null" ]] || die "could not create the invoice fixture"

    # Register teardown only once there is something to tear down.
    trap teardown EXIT

    freeagent invoice create-item "$INVOICE_ID" \
        --description "Consulting - retainer" \
        --item-type Services \
        --quantity 5 \
        --price 450.0 >/dev/null
    freeagent invoice mark-sent "$INVOICE_ID" >/dev/null
    info "    invoice $INVOICE_ID, dated $dated_on"

    info "Recording"
    (cd "$REPO_ROOT/docs" && vhs demo.tape)

    info "Wrote docs/demo.gif ($(du -h "$REPO_ROOT/docs/demo.gif" | cut -f1 | tr -d ' '))"
}

main "$@"
