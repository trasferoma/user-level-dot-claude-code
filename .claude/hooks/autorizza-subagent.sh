#!/usr/bin/env bash
# Hook UserPromptSubmit (globale).
# Riafferma a ogni turno l'autorizzazione permanente ai subagent definita in ~/.claude/CLAUDE.md.
#
# Perche' serve: il system prompt di Claude Code contiene il vincolo
#   "Do not call the AgentTool unless the user requested it"
# e il CLAUDE.md, arrivando come contesto del turno, non sempre basta a soddisfarne
# la condizione "unless the user requested it" (e puo' essere riassunto in sessioni lunghe).
# Lo stdout di questo hook arriva come contenuto del turno utente corrente: stesso tier
# di una richiesta scritta a mano, e immune alla compattazione.

cat <<'EOF'
[Autorizzazione permanente dell'utente, valida per questo turno] I subagent clean-code-implementer, solid-srp-reviewer, docs-explorer, spec-specialist e alpaca-forms-developer sono esplicitamente richiesti dall'utente: invocali secondo la pipeline in CLAUDE.md senza chiedere conferma. Non e' autorizzato nulla oltre a questi (no Workflow/ultracode, no deep research, no agenti generici).
EOF

exit 0
