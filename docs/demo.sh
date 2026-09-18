#!/usr/bin/env bash

set -euo pipefail

readonly SANDBOX_HOST="api.sandbox.freeagent.com"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TAPE="$REPO_ROOT/docs/demo.tape"
readonly EXPLANATION_DESCRIPTION="Office supplies"
readonly TARGET_TRANSACTION="Staples"

INVOICE_ID=""
BANK_ACCOUNT=""

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m==>\033[0m %s\n' "$*" >&2; }
die() {
    printf '\033[31mError:\033[0m %s\n' "$*" >&2
    exit 1
}

if [[ -x "$REPO_ROOT/.build/debug/freeagent" ]]; then
    PATH="$REPO_ROOT/.build/debug:$PATH"
    export PATH
fi

delete_explanations_created_by_the_tape() {
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
}

delete_invoice_fixture() {
    freeagent invoice mark-draft "$INVOICE_ID" >/dev/null 2>&1 || true
    freeagent invoice delete "$INVOICE_ID" >/dev/null 2>&1 &&
        info "    invoice $INVOICE_ID" ||
        warn "    could not delete invoice $INVOICE_ID"
}

teardown() {
    local status=$?
    trap - EXIT INT TERM
    info "Removing fixtures"
    if [[ -n "$BANK_ACCOUNT" ]]; then
        delete_explanations_created_by_the_tape
    fi
    if [[ -n "$INVOICE_ID" ]]; then
        delete_invoice_fixture
    fi
    exit $status
}

require_tools() {
    local tool
    for tool in freeagent jq vhs; do
        command -v "$tool" >/dev/null || die "$tool is not installed"
    done
}

require_valid_tape() {
    vhs validate "$TAPE" || die "$TAPE is not a valid tape"
}

require_sandbox_account() {
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
}

require_target_transaction() {
    local matches
    matches="$(
        freeagent bank-transaction list --bank-account "$BANK_ACCOUNT" --view unexplained |
            jq -r --arg p "$TARGET_TRANSACTION" \
                '[.bank_transactions[]? | select(.description | test($p))] | length'
    )"
    [[ "${matches:-0}" -gt 0 ]] || die "no unexplained '$TARGET_TRANSACTION' transaction - the tape has nothing to explain"
}

create_overdue_invoice_fixture() {
    local contact dated_on invoice
    contact="$(freeagent contact list | jq -r '.contacts[0].url')"
    [[ -n "$contact" && "$contact" != "null" ]] || die "no contact found to invoice"
    dated_on="$(date -v-60d +%Y-%m-%d 2>/dev/null || date -d '60 days ago' +%Y-%m-%d)"

    invoice="$(freeagent invoice create --contact "$contact" --dated-on "$dated_on" --payment-terms-in-days 30)"
    INVOICE_ID="$(jq -r '.invoice.url | split("/") | last' <<<"$invoice")"
    [[ -n "$INVOICE_ID" && "$INVOICE_ID" != "null" ]] || die "could not create the invoice fixture"

    trap teardown EXIT INT TERM

    freeagent invoice create-item "$INVOICE_ID" \
        --description "Consulting - retainer" \
        --item-type Services \
        --quantity 5 \
        --price 450.0 >/dev/null
    freeagent invoice mark-sent "$INVOICE_ID" >/dev/null
    info "    invoice $INVOICE_ID, dated $dated_on"
}

main() {
    require_tools
    require_valid_tape
    require_sandbox_account

    BANK_ACCOUNT="$(freeagent bank-account list | jq -r '.bank_accounts[0].url')"
    [[ -n "$BANK_ACCOUNT" && "$BANK_ACCOUNT" != "null" ]] || die "no bank account found"
    require_target_transaction

    info "Creating fixtures"
    create_overdue_invoice_fixture

    info "Recording"
    (cd "$REPO_ROOT/docs" && vhs demo.tape)

    info "Wrote docs/demo.gif ($(du -h "$REPO_ROOT/docs/demo.gif" | cut -f1 | tr -d ' '))"
}

main "$@"
