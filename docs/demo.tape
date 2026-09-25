# Regenerate with:  mise run demo
#
# Records against a FreeAgent *sandbox* account. docs/demo.sh creates the
# fixtures this tape needs and removes them afterwards, including the bank
# transaction explanation created below if the recording stops before the
# tape deletes it.

Output demo.gif

Require freeagent
Require jq

Set Shell "bash"
Set Theme "Catppuccin Mocha"
Set FontSize 20
Set Width 1500
Set Height 400
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
Type "freeagent company" Enter
Sleep 2500ms

Hide
Type "clear" Enter
Show

Type "# What is still owed to me?" Enter
Sleep 300ms
Type "freeagent invoice list --view open_or_overdue --page-size 3" Enter
Sleep 3s
Type "q"
Sleep 500ms

Hide
Type "clear" Enter
Show

Type "# Which bank transactions still need explaining?" Enter
Sleep 300ms
Type "freeagent bank-transaction list --bank-account 39907 --view unexplained --page-size 3" Enter
Sleep 3s
Type "n"
Sleep 3s
Type "q"
Sleep 500ms

Hide
Type "clear" Enter
Show

Type "# Explain the Staples debit as an office cost" Enter
Sleep 300ms
Type "freeagent explanation create --bank-transaction 2581845 --bank-account 39907 --category 250 --dated-on 2025-08-21 --description 'Office supplies' --gross-value -45.99 | jq -c '.bank_transaction_explanation | {dated_on, gross_value, description}'" Enter
Sleep 3s

Hide
Type "id=$(freeagent explanation list --bank-account 39907 --json --page-size 100 | jq -r --arg d 'Office supplies' '.bank_transaction_explanations[] | select(.description == $d) | .url' | sed 's:.*/::' | head -1)" Enter
Type "clear" Enter
Show

Type "# Changed my mind - deleting asks first" Enter
Sleep 300ms
Type "freeagent explanation delete $id" Enter
Sleep 1500ms
Left
Sleep 600ms
Enter
Sleep 2500ms
