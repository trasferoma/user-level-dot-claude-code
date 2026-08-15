---
name: git-branch-token
description: Determina il token identificativo che chiude ogni messaggio di commit nella forma «tkn: <token>». Usa prima di committare, per stabilire il token del branch corrente. Sui commit successivi al primo lo recupera dai commit già presenti sul branch con git log; al primo commit del branch propone da due a quattro candidati derivati dal nome del branch o dal diff e lo fa scegliere all'utente, senza inventarlo. Definisce il formato del token, il comando di ricerca nella storia e il blocco di escalation TOKEN_RICHIESTO per i subagent. Complementare a git-commit-messages, che definisce il resto del messaggio.
---

# Scopo
Stabilire il token del branch corrente, che chiude ogni messaggio di commit come ultima riga nella forma `tkn: <token>`.

# Quando usare questa skill
- stai per comporre un messaggio di commit e serve il token del branch

# Quando NON usare questa skill
- serve il formato del resto del messaggio (tipo, scope, corpo, moduli): usa `git-commit-messages`
- il task è un'operazione git senza commit: usa `git-inspection`
- il repository non adotta la convenzione del token e l'utente non l'ha richiesta

# Regole di precedenza
- Il token indicato dall'utente prevale su quello trovato nella storia; se contraddice la storia, applicalo e segnala la divergenza in una riga.
- Il token già presente nella storia del branch prevale sulle euristiche derivate dal nome del branch.
- In assenza di entrambi, non decidere: chiedi.

# Regole operative

## Formato
- Riga esatta `tkn: <token>`, un solo spazio dopo i due punti, niente altro sulla riga.
- **Ultima riga del messaggio**, preceduta da una riga vuota, presente una sola volta.
- Token in kebab-case, caratteri `[a-z0-9-]`, 3-40 caratteri, senza il prefisso di tipo del branch (`feature/`, `bugfix/`, `hotfix/`).
- Un branch ha un solo token, stabile per tutta la sua vita.

## Determinazione
1. **Token fornito dall'utente** (nel prompt o nella delega) → usalo e **fermati qui**. Non eseguire la ricerca nella storia, non generare candidati, non verificare la coerenza col branch: il passo 2 e la sezione «Ricerca nella storia» non si applicano. Normalizza il token (minuscolo, kebab-case, senza prefisso `feature/`) e passa alla composizione del messaggio.
2. **Token già presente sul branch** → usalo, senza chiedere nulla. Il comando restituisce quello del commit più recente: se la storia del branch fosse incoerente, quello è il token che vince.
3. **Nessun token sul branch** → primo commit: proponi i candidati e **fermati**. Non committare, non scegliere il candidato «ovvio» in autonomia.

In detached HEAD fermati: chiedi su quale branch va il commit. Se il branch cambia durante la sessione, ricomincia dal passo 2: non riusare per inerzia il token della sessione.

## Ricerca nella storia

**Precondizione**: questa sezione si esegue **solo** quando il token non è stato fornito dall'utente. Se l'hai già, saltala: cercarlo in storia è lavoro inutile che può far emergere una divergenza irrilevante.

Esegui con il tool **Bash** (Git Bash), non con PowerShell: `VAR=$(...)`, `grep` e `head` lì non funzionano allo stesso modo e la ricerca torna **vuota senza errore**, facendo concludere «nessun token» su un branch che ne ha già uno. Se il comando non trova nulla, verifica prima quale shell l'ha eseguito.

```bash
git rev-parse --abbrev-ref HEAD
EXCL=$(for REF in origin/main main origin/master master origin/develop develop; do git rev-parse -q --verify "$REF"; done)
git --no-pager log --pretty=%b HEAD --not $EXCL | grep -iE '^tkn:' | head -n 1
```

`--not $EXCL` esclude tutto ciò che è raggiungibile dai branch di integrazione, così restano **solo i commit propri del branch**: senza questa esclusione un branch appena staccato erediterebbe il token dell'ultima attività di `main` o `develop` invece di farlo chiedere. `$EXCL` va lasciato senza apici, contiene più sha. Conseguenze volute:

- stando **su** `main`, `master` o `develop` l'esclusione copre HEAD stesso e la ricerca non trova nulla: su quei branch il token va chiesto a ogni attività nuova;
- se `rev-parse --abbrev-ref HEAD` stampa `HEAD` sei in **detached HEAD**: fermati, la ricerca lì non significa nulla;
- in un repo senza `main`, `master` né `develop`, `$EXCL` è vuoto e la ricerca scorre tutta la storia: il risultato è indicativo, dichiaralo.

## Primo commit sul branch: proposte

Genera **da due a quattro** candidati, il primo è il raccomandato, ognuno con la sua provenienza. Euristiche in ordine di priorità:

1. **Nome del branch depurato** — `feature/iam-operatore` → `iam-operatore`; `bugfix/fix-cambio-referente-2` → `cambio-referente`. Candidato primario.
2. **Codice ticket nel nome** — `feature/BANDI-123-iam-operatore` produce anche `bandi-123`.
3. **Tema del diff** — quando il nome del branch è muto (`fix2`, un nome di persona, una data): deriva dai moduli toccati e **dichiara** che il nome non era utilizzabile.
4. **Token del branch padre** — se il branch deriva da un branch di feature che ha già un token.

Niente candidati sinonimi tra loro, niente token generici (`sviluppo`, `modifiche`, `fix`, `varie`).

## Escalation TOKEN_RICHIESTO

Se hai un canale interattivo (processo principale, `AskUserQuestion`) chiedi direttamente, con il raccomandato come prima opzione. Se non lo hai (subagent) fermati senza committare e restituisci al chiamante:

```text
TOKEN_RICHIESTO
motivo: nessun token nella storia del branch
branch: feature/iam-operatore
proposte:
  1. iam-operatore   — dal nome del branch (raccomandato)
  2. bandi-123       — codice ticket nel nome del branch
  3. ruolo-operatore — tema del diff (moduli iam-web, iam-service)
messaggio pronto (manca solo l'ultima riga):
<bozza completa del messaggio senza la riga tkn:>
```

Quando la risposta arriva, normalizza il token (minuscolo, kebab-case, senza prefissi) e procedi senza rifare la domanda.

## Casi limite
- **Branch rinominato**: resta il token già in storia; non riallinearlo al nuovo nome.
- **Cherry-pick**: sostituisci la riga con il token del branch di destinazione.
- **Squash o rebase di commit con token diversi**: il commit risultante porta il token del branch.
- **`fixup!` / `squash!` temporanei**: ammessi senza token, purché riassorbiti prima del push.

# Vincoli
- Non inventare un token e non dedurlo «per ovvietà» quando la storia non lo contiene: al primo commit si chiede sempre.
- Non cambiare il token di un branch che ne ha già uno.
- Non scrivere più di una riga `tkn:`, né metterla altrove che in ultima riga.
- Non riusare il token della sessione precedente dopo un cambio di branch senza riverificarlo.
- Non riscrivere commit per uniformare i token senza richiesta esplicita dell'utente.
