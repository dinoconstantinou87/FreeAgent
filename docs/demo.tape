# Regenerate with:  cd docs && vhs demo.tape
#
# Records against a FreeAgent *sandbox* account. Log in first with
# `freeagent auth login --environment sandbox` - never record production data.
#
# NOTE: this tape WRITES to the account - it creates a bank transaction
# explanation. Re-running it creates another one. Clean up with
# `freeagent explanation delete <id>`.

Output demo.gif

Require freeagent
Require jq

Set Shell "bash"
Set Theme "Catppuccin Mocha"
Set FontSize 16
Set Width 1300
Set Height 700
Set Padding 24
Set BorderRadius 10
Set WindowBar Colorful
Set TypingSpeed 12ms
Set Framerate 20

Hide
Type "set +m" Enter
Type "export PS1='❯ '" Enter
Type "cd $(mktemp -d)" Enter
Type "clear" Enter
Show

Sleep 750ms

Type "# Who am I connected to?" Enter
Sleep 300ms
Type "freeagent company | jq '.company | {name, type, currency, sales_tax_registration_status}'" Enter
Sleep 1800ms

Type "# What is still owed to me?" Enter
Sleep 300ms
Type "freeagent invoice list --view open_or_overdue | jq -r '.invoices[] | [.reference, .contact_name, .due_on, .due_value] | @tsv'" Enter
Sleep 1800ms

Type "# Which bank transactions still need explaining?" Enter
Sleep 300ms
Type "ACC=$(freeagent bank-account list | jq -r '.bank_accounts[0].url')" Enter
Sleep 1500ms
Type "freeagent bank-transaction list --bank-account $ACC --view unexplained | jq -r '.bank_transactions[] | [.dated_on, .amount, .description] | @tsv'" Enter
Sleep 1800ms

Type "# Explain the Staples debit as an office cost" Enter
Sleep 300ms
Type "TX=$(freeagent bank-transaction list --bank-account $ACC --view unexplained | jq -r --arg p Staples '.bank_transactions[] | select(.description | test($p)) | .url')" Enter
Sleep 1500ms
Type "freeagent explanation create --bank-transaction $TX --bank-account $ACC --category https://api.sandbox.freeagent.com/v2/categories/250 --dated-on 2025-08-21 --description 'Office supplies' --gross-value -45.99 | jq -r '.bank_transaction_explanation | [.dated_on, .gross_value, .description] | @tsv'" Enter
Sleep 1500ms

Type "# It drops off the unexplained list" Enter
Sleep 300ms
Type "freeagent bank-transaction list --bank-account $ACC --view unexplained | jq '.bank_transactions | length'" Enter
Sleep 3s
