# Reference: frontmatter, sostituzioni e visibilità delle skill

## Indice
- Vincoli di validazione dei campi standard
- Tabella completa dei campi di frontmatter (Claude Code)
- Da dove viene il nome del comando
- Sostituzioni di stringa disponibili
- Argomenti passati alla skill
- Iniezione di contesto dinamico
- Esecuzione in un subagent (`context: fork`)
- Pre-approvazione e restrizione dei tool
- Controllo dell'accesso del modello alle skill
- `skillOverrides`: visibilità dalle impostazioni
- Budget dell'elenco skill e troncamento delle description
- Troubleshooting

---

## Vincoli di validazione dei campi standard

Validi in tutto l'ecosistema Agent Skills (API, claude.ai, Claude Code).

`name`:
- massimo 64 caratteri
- solo minuscole, cifre e trattini
- nessun tag XML
- nessuna parola riservata: `anthropic`, `claude`

`description`:
- non vuota
- massimo 1.024 caratteri
- nessun tag XML
- deve dire cosa fa la skill **e** quando usarla

---

## Tabella completa dei campi di frontmatter (Claude Code)

Tutti i campi sono opzionali. Solo `description` è raccomandata, perché è ciò su cui il modello decide se attivare la skill.

I campi booleani accettano `true`/`false` e anche `yes`, `no`, `on`, `off`, `1`, `0` in qualunque combinazione di maiuscole.

| Campo | Descrizione |
|-------|-------------|
| `name` | Etichetta mostrata negli elenchi. Default: nome della directory. Nelle skill personali e di progetto **non** determina il comando; nelle skill di plugin sì (ultimo segmento). |
| `description` | Cosa fa la skill e quando usarla. Se omessa, viene usato il primo paragrafo del corpo. Il testo combinato con `when_to_use` è troncato a 1.536 caratteri nell'elenco: metti il caso principale per primo. |
| `when_to_use` | Contesto aggiuntivo sull'attivazione: frasi trigger, esempi di richieste. Accodato a `description` e conta nel cap dei 1.536 caratteri. |
| `argument-hint` | Suggerimento mostrato in autocomplete. Esempio: `[issue-number]` o `[filename] [format]`. |
| `arguments` | Argomenti posizionali con nome, per la sostituzione `$nome` nel corpo. Stringa separata da spazi o lista YAML; i nomi mappano le posizioni in ordine. |
| `disable-model-invocation` | `true` impedisce al modello di caricare la skill automaticamente: solo invocazione manuale con `/nome`. Impedisce anche il precaricamento nei subagent e l'esecuzione da scheduled task. Default `false`. |
| `user-invocable` | `false` nasconde la skill dal menu `/`. Per conoscenza di background non azionabile come comando. Default `true`. Controlla **solo** la visibilità nel menu, non l'accesso via Skill tool. |
| `allowed-tools` | Tool usabili senza chiedere permesso **durante il turno** che invoca la skill. Stringa separata da spazi o virgole, o lista YAML. Non restringe nulla: tutti gli altri tool restano invocabili secondo le normali permission. |
| `disallowed-tools` | Tool rimossi dal pool disponibile mentre la skill è attiva. Utile per skill autonome che non devono mai chiamare, per esempio, `AskUserQuestion`. La restrizione decade al messaggio successivo. |
| `model` | Modello da usare quando la skill è attiva. Vale per il resto del turno, non viene salvato nelle impostazioni. Accetta gli stessi valori di `/model`, oppure `inherit`. |
| `effort` | Livello di effort mentre la skill è attiva: `low`, `medium`, `high`, `xhigh`, `max` (dipende dal modello). Default: eredita dalla sessione. |
| `context` | `fork` esegue la skill in un contesto di subagent isolato. |
| `agent` | Quale tipo di subagent usare quando `context: fork` è impostato. Default `general-purpose`. |
| `background` | Solo con `context: fork`. `false` attende il risultato nel turno che ha invocato la skill invece di eseguire in background. Default `true`. |
| `hooks` | Hook con ambito limitato al ciclo di vita della skill. |
| `paths` | Glob che limitano l'attivazione automatica ai soli file corrispondenti. Stringa separata da virgole o lista YAML. |
| `shell` | Shell per `` !`comando` `` e blocchi ` ```! `: `bash` (default) o `powershell`. |

---

## Da dove viene il nome del comando

| Posizione della skill | Fonte del nome del comando | Esempio |
|-----------------------|----------------------------|---------|
| Directory sotto `~/.claude/skills/` o `.claude/skills/` | nome della directory | `.claude/skills/deploy-staging/SKILL.md` → `/deploy-staging` |
| `.claude/skills/` annidata, con nome in conflitto | path relativo + nome directory | `apps/web/.claude/skills/deploy/` → `/apps/web:deploy` |
| File sotto `.claude/commands/` | nome del file senza estensione | `.claude/commands/deploy.md` → `/deploy` |
| Sottodirectory `skills/` di un plugin | frontmatter `name` o nome directory, con namespace del plugin | `my-plugin/skills/review/` → `/my-plugin:review` |
| `SKILL.md` alla radice di un plugin | frontmatter `name`, fallback al nome della directory del plugin | `name: review` → `/my-plugin:review` |

Le skill si caricano anche dalle `.claude/skills/` annidate sotto la directory di lavoro, on demand quando il modello lavora su file di quella sottodirectory. In caso di nome duplicato **restano disponibili entrambe**: la annidata compare con nome qualificato per directory.

Le directory di skill possono essere **symlink**: Claude Code segue il link e legge `SKILL.md` dalla destinazione. Se lo stesso target è raggiungibile da più posizioni, la skill viene caricata una sola volta.

Claude Code osserva le directory delle skill: aggiungere, modificare o rimuovere una skill ha effetto **nella sessione corrente** senza riavvio. Creare una directory skills top-level che non esisteva all'avvio richiede invece il riavvio.

---

## Sostituzioni di stringa disponibili

| Variabile | Significato |
|-----------|-------------|
| `$ARGUMENTS` | Tutti gli argomenti passati. Se non presente nel corpo, gli argomenti vengono accodati come `ARGUMENTS: <valore>`. |
| `$ARGUMENTS[N]` | Argomento per indice 0-based. |
| `$N` | Forma breve di `$ARGUMENTS[N]`: `$0`, `$1`, … |
| `$nome` | Argomento con nome dichiarato in `arguments`. |
| `${CLAUDE_SESSION_ID}` | ID della sessione corrente. |
| `${CLAUDE_EFFORT}` | Livello di effort attivo. |
| `${CLAUDE_SKILL_DIR}` | Directory che contiene `SKILL.md`. **Usala sempre** per riferire script bundled, così la skill funziona a qualunque livello sia installata. |
| `${CLAUDE_PROJECT_DIR}` | Radice del progetto. |

`${CLAUDE_SKILL_DIR}` e `${CLAUDE_PROJECT_DIR}` vengono sostituite **sia** nel corpo markdown **sia** nelle regole Bash di `allowed-tools`. Sfruttalo per far girare uno script bundled senza prompt di permesso:

```yaml
---
name: render-chart
description: Render a chart from a CSV file
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh *)
---

Run `${CLAUDE_SKILL_DIR}/scripts/render.sh <csv-file>` to render the chart.
```

La regola in `allowed-tools` combacia esattamente col comando indicato nel corpo, quindi lo script parte senza chiedere.

Gli argomenti indicizzati usano il quoting di shell: i valori multi-parola vanno tra apici. Un placeholder indicizzato senza argomento corrispondente resta invariato nel testo; uno con nome senza argomento diventa stringa vuota. Per un `$` letterale davanti a una cifra o a `ARGUMENTS`, sfuggilo con backslash: `\$1.00`.

---

## Argomenti passati alla skill

Sia l'utente sia il modello possono passare argomenti. `/fix-issue 123` sostituisce `$ARGUMENTS` con `123`. Se la skill non contiene `$ARGUMENTS`, Claude Code accoda `ARGUMENTS: <input>` al contenuto.

È possibile **impilare** più skill all'inizio di un messaggio: `/write-tests /fix-issue 123` carica entrambe e passa `123` come argomento a ciascuna. Claude Code espande la prima skill più altre cinque; l'espansione si ferma al primo token che non sia una skill inline invocabile dall'utente — per esempio una skill che gira come subagent forkato — e quel token e tutto il resto diventano il testo degli argomenti.

---

## Iniezione di contesto dinamico

La sintassi `` !`<comando>` `` esegue il comando **prima** che il contenuto arrivi al modello, e ne sostituisce l'output al placeholder. È preprocessing, non qualcosa che il modello esegue.

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

Dettagli che contano:
- La sostituzione avviene **una sola volta** sul file originale: l'output non viene riscansionato, quindi un comando non può emettere un placeholder per un passaggio successivo.
- La forma inline è riconosciuta solo se `!` sta a inizio riga o subito dopo uno spazio. In `` KEY=!`cmd` `` il placeholder resta testo letterale.
- Per comandi multi-riga usa un blocco recintato aperto con ` ```! `.
- L'impostazione `disableSkillShellExecution: true` disattiva il comportamento per le skill di utente, progetto, plugin e directory aggiuntive; le skill bundled e managed non sono toccate.

---

## Esecuzione in un subagent (`context: fork`)

`context: fork` esegue la skill in isolamento: il contenuto della skill **diventa il prompt** del subagent, che non ha accesso alla cronologia della conversazione.

- Per default il fork gira in **background** e il risultato arriva quando finisce. `background: false` attende nel turno che ha invocato la skill.
- Claude Code attende comunque il risultato in modalità non interattiva (`-p`, Agent SDK), quando `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, quando la stessa skill forkata è già in esecuzione, e quando parte da uno scheduled task.
- Un fork in background gira con il **set di tool più ristretto** dei subagent in background: se i passi della skill dipendono da un tool fuori da quel set, serve `background: false`.
- Le modifiche di un fork in background stanno **fuori dai checkpoint** della sessione: `/rewind` non le annulla, serve git.
- `agent` sceglie il tipo di subagent. Gli agent `Explore` e `Plan` saltano CLAUDE.md e git status, quindi un fork con `agent: Explore` vede solo il contenuto della skill e il proprio system prompt.

⚠️ `context: fork` ha senso **solo** per skill con istruzioni azionabili. Una skill di sole linee guida («usa queste convenzioni API») forkata riceve le linee guida e nessun compito, e torna senza output utile.

### Due direzioni di composizione skill + subagent

| Approccio | System prompt | Compito | Carica anche |
|-----------|---------------|---------|--------------|
| Skill con `context: fork` | dal tipo di agent | contenuto di `SKILL.md` | CLAUDE.md, tranne con agent `Explore` o `Plan` |
| Subagent con campo `skills` | corpo markdown del subagent | messaggio di delega | skill precaricate + CLAUDE.md |

---

## Pre-approvazione e restrizione dei tool

`allowed-tools` concede il permesso per i tool elencati **solo durante il turno** che invoca la skill. La concessione decade al messaggio successivo, anche se il contenuto della skill resta in contesto; reinvocare la skill la riapplica. Non restringe nulla: gli altri tool restano invocabili secondo le permission normali. Per pre-approvare per tutta la sessione servono regole di allow nelle permission, non questo campo.

Per le skill in `.claude/skills/` di un progetto, `allowed-tools` diventa effettivo **dopo l'accettazione del trust dialog** del workspace. Una skill può concedersi accesso ampio ai tool: va letta prima di dare fiducia a un repository.

`disallowed-tools` rimuove tool dal pool mentre la skill è attiva; anche questa restrizione decade al messaggio successivo. Come le regole di deny, non può rimuovere `EndConversation` se restano altri tool.

---

## Controllo dell'accesso del modello alle skill

Tre leve:

**Disattivare tutte le skill** negando il tool `Skill` in `/permissions`:
```text
Skill
```

**Consentire o negare skill specifiche** con regole di permission:
```text
Skill(commit)
Skill(review-pr *)
```
Sintassi: `Skill(nome)` per match esatto, `Skill(nome *)` per prefisso con qualunque argomento.

**Nascondere una singola skill** con `disable-model-invocation: true` nel suo frontmatter: la rimuove interamente dal contesto del modello. `user-invocable: false` **non** basta: controlla solo la visibilità nel menu.

---

## `skillOverrides`: visibilità dalle impostazioni

Controlla la visibilità dalle impostazioni invece che dal frontmatter — utile per skill il cui `SKILL.md` non vuoi modificare, per esempio quelle committate in un repo condiviso. Il menu `/skills` lo scrive per te (`Space` per ciclare gli stati, `Enter` per salvare in `.claude/settings.local.json`).

| Valore | Elencata al modello | Nel menu `/` |
|--------|---------------------|--------------|
| `"on"` | nome e description | sì |
| `"name-only"` | solo nome | sì |
| `"user-invocable-only"` | nascosta | sì |
| `"off"` | nascosta | nascosta |

```json
{
  "skillOverrides": {
    "legacy-context": "name-only",
    "deploy": "off"
  }
}
```

Una skill assente da `skillOverrides` è trattata come `"on"`. Le skill di plugin non sono toccate: si gestiscono con `/plugin`.

---

## Budget dell'elenco skill e troncamento delle description

Claude Code carica in contesto un elenco di nomi e description. L'elenco contiene **sempre tutti i nomi**, ma con molte skill le description vengono accorciate per rientrare nel budget di caratteri, e questo può togliere proprio le parole chiave necessarie al match.

- Il budget scala all'**1% della finestra di contesto** del modello. Configurabile con `skillListingBudgetFraction` (es. `0.02` = 2%) o con la variabile d'ambiente `SLASH_COMMAND_TOOL_CHAR_BUDGET` come conteggio fisso.
- Quando l'elenco sfora, Claude Code **elimina le description partendo dalle skill invocate meno**: le più usate mantengono il testo completo.
- Ogni voce è comunque limitata a **1.536 caratteri** di `description` + `when_to_use`, indipendentemente dal budget. Configurabile con `skillListingMaxDescChars`.
- `/doctor` stima il costo in contesto dell'elenco e i maggiori contributori. La riga Skills di `/context` riporta la dimensione **dopo** l'applicazione del budget.
- Per liberare budget, porta le voci a bassa priorità su `"name-only"` in `skillOverrides`.

Conseguenza per l'authoring: **il caso d'uso principale va nella prima frase della description.** Ciò che sta in fondo è quello che sparisce.

---

## Troubleshooting

**La skill non si attiva**
1. La description contiene le parole che l'utente pronuncerebbe davvero?
2. La skill compare chiedendo «quali skill sono disponibili?»
3. Riformula la richiesta per avvicinarla alla description.
4. Invocala a mano con `/nome-skill` per isolare il problema: se funziona a mano, il problema è la description; se non funziona, è il corpo.

Se il YAML del frontmatter è malformato, Claude Code carica il corpo con metadata vuoti: `/nome-skill` funziona ancora ma il modello non ha nessuna description su cui fare match. `--debug` mostra l'errore di parsing.

**La skill si attiva troppo spesso**
1. Rendi la description più specifica e circoscritta.
2. Aggiungi `disable-model-invocation: true` se vuoi solo l'invocazione manuale.
3. Valuta `paths` per limitare l'attivazione ai file pertinenti.

**La skill sembra smettere di funzionare dopo la prima risposta**
Il contenuto è quasi sempre ancora presente: il modello sta scegliendo altri approcci. Rafforza description e istruzioni, o usa gli hook per imporre il comportamento in modo deterministico. Se la skill è grande o ne hai invocate molte dopo, reinvocala dopo la compattazione.

**Skill in sessioni Cowork e cloud**
Le sessioni Cowork e cloud **non leggono** `~/.claude/skills/` sulla macchina locale: caricano le skill abilitate per l'account claude.ai, e le sessioni cloud anche le skill di progetto committate nel repository clonato. Una skill che esiste solo in locale risulta «non trovata» quando una routine la invoca.
