#!/usr/bin/env bash

set -euo pipefail

readonly SANDBOX_HOST="api.sandbox.freeagent.com"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TAPE="$REPO_ROOT/docs/demo.tape"
readonly EXPLANATION_DESCRIPTION="Office supplies"
readonly TAPE_BANK_ACCOUNT_ID="39907"
readonly TAPE_TRANSACTION_ID="2581845"
readonly TAPE_CATEGORY_ID="250"

INVOICE_ID=""

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
        freeagent explanation list --bank-account "$TAPE_BANK_ACCOUNT_ID" --json --page-size 100 2>/dev/null |
            jq -r --arg d "$EXPLANATION_DESCRIPTION" \
                '.bank_transaction_explanations[]? | select(.description == $d) | .url | split("/") | last'
    )" || explanations=""

    for id in $explanations; do
        freeagent explanation delete "$id" --yes >/dev/null 2>&1 &&
            info "    explanation $id" ||
            warn "    could not delete explanation $id"
    done
}

delete_invoice_fixture() {
    freeagent invoice mark-draft "$INVOICE_ID" >/dev/null 2>&1 || true
    freeagent invoice delete "$INVOICE_ID" --yes >/dev/null 2>&1 &&
        info "    invoice $INVOICE_ID" ||
        warn "    could not delete invoice $INVOICE_ID"
}

teardown() {
    local status=$?
    trap - EXIT INT TERM
    info "Removing fixtures"
    delete_explanations_created_by_the_tape
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
    company="$(freeagent company --json)" || die "could not reach the API - are you logged in?"
    company_url="$(jq -r '.company.url' <<<"$company")"
    company_name="$(jq -r '.company.name' <<<"$company")"

    if [[ "$company_url" != "https://$SANDBOX_HOST/"* ]]; then
        die "refusing to run against ${company_url#https://}
       This script writes to the account, so it only runs against $SANDBOX_HOST.
       Switch with: freeagent auth login --environment sandbox"
    fi
    info "Sandbox account: $company_name"
}

require_tape_references() {
    local unexplained matches
    unexplained="$(freeagent bank-transaction list --bank-account "$TAPE_BANK_ACCOUNT_ID" --view unexplained --json --page-size 100)" ||
        die "bank account $TAPE_BANK_ACCOUNT_ID does not resolve - the tape references it by ID"

    matches="$(
        jq -r --arg id "$TAPE_TRANSACTION_ID" \
            '[.bank_transactions[]? | select(.url | endswith("/" + $id))] | length' <<<"$unexplained"
    )"
    [[ "${matches:-0}" -gt 0 ]] ||
        die "bank transaction $TAPE_TRANSACTION_ID is not unexplained on account $TAPE_BANK_ACCOUNT_ID - the tape references it by ID"

    freeagent category list |
        jq -e --arg id "$TAPE_CATEGORY_ID" \
            'any(..; objects | select(.url? // "" | endswith("/" + $id)))' >/dev/null ||
        die "category $TAPE_CATEGORY_ID does not resolve - the tape references it by ID"
}

create_overdue_invoice_fixture() {
    local contact dated_on invoice
    contact="$(freeagent contact list --json | jq -r '.contacts[0].url')"
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

    require_tape_references

    info "Creating fixtures"
    create_overdue_invoice_fixture

    info "Recording"
    (cd "$REPO_ROOT/docs" && vhs demo.tape)

    info "Wrote docs/demo.gif ($(du -h "$REPO_ROOT/docs/demo.gif" | cut -f1 | tr -d ' '))"
}

main "$@"
