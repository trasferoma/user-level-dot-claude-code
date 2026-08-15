---
name: build-agent-rules
description: Regole ufficiali Anthropic per CREARE e REVISIONARE subagent di Claude Code (i file markdown in .claude/agents/ o ~/.claude/agents/ con frontmatter YAML). Usa questa skill quando devi scrivere un nuovo agente, revisionare o correggere un agente esistente, valutarne il frontmatter (name, description, tools, model, ecc.), la qualità della description che guida la delega automatica, il system prompt nel corpo, le restrizioni sui tool e la scelta del modello. Copre schema completo dei campi, priorità di scope, best practice di description action-oriented, principi di scrittura del system prompt, single-responsibility e minimizzazione dei tool. NON usare per generare codice applicativo, né per gli agent SDK/API (questa skill riguarda i subagent di Claude Code).
---

# Scopo
Fornire le regole operative — allineate alla documentazione ufficiale Anthropic — per **creare nuovi subagent** di Claude Code e **revisionare quelli esistenti** in `.claude/agents/` (progetto) o `~/.claude/agents/` (utente).

Un subagent è un file markdown con frontmatter YAML: il frontmatter ne definisce identità, delega, tool e modello; il corpo ne è il system prompt. Questa skill governa entrambi.

Fonti ufficiali:
- `https://code.claude.com/docs/en/sub-agents.md` — riferimento completo subagent
- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md` — best practice di scrittura dei prompt

# Quando usare questa skill
Usa questa skill se:
- devi **creare** un nuovo subagent
- devi **revisionare, correggere o migliorare** un subagent esistente
- devi valutare frontmatter, description, system prompt, tool o modello di un agente
- vuoi verificare che un agente rispetti single-responsibility, delega efficace e minimizzazione dei tool

# Quando NON usare questa skill
Non usare questa skill se:
- il task è generare o modificare codice applicativo (usa le skill di code generation)
- il task riguarda gli agent costruiti con Agent SDK o Messages API (contesto diverso dai subagent di Claude Code)
- serve solo una spiegazione teorica senza produrre o revisionare un file agente

# Regole di precedenza
- Le istruzioni esplicite dell'utente prevalgono su questa skill
- Le regole di sicurezza e i vincoli globali prevalgono su questa skill
- In caso di conflitto con lo stile di un agente già presente nel repository, prevale la coerenza col parco agenti esistente, salvo che violi una regola dura qui sotto
- Questa skill definisce lo standard; non sostituisce il giudizio sul dominio specifico dell'agente

# Regole operative

## 1. Schema del frontmatter YAML

### Campi obbligatori
- `name` — identificatore univoco. **Solo lettere minuscole e trattini.** Diventa l'`agent_type` usato nella delega e negli hook. Deve essere unico nel proprio scope.
- `description` — dice a Claude **quando** delegare a questo agente. È il meccanismo primario di selezione automatica, non un testo di aiuto. Vedi regola 3.

### Campi opzionali principali
- `tools` — allowlist di tool, come stringa separata da virgole o lista. **Se omesso, l'agente eredita tutti i tool disponibili.** Preferire sempre una allowlist esplicita (regola 4). Supporta pattern MCP (`mcp__<server>`, `mcp__<server>__*`, `mcp__*`) e `Agent(tipo1, tipo2)` per limitare quali subagent può generare.
- `disallowedTools` — denylist. Applicata prima di `tools`: un tool presente in entrambi viene rimosso.
- `model` — `sonnet`, `opus`, `haiku`, `fable`, un ID completo (es. `claude-opus-4-8`), oppure `inherit`. **Default: `inherit`** (stesso modello della sessione padre).
- `permissionMode` — `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`, `manual`. Ignorato per subagent da plugin. Usare `bypassPermissions` solo con motivazione esplicita.
- `maxTurns` — intero, limite massimo di turni.
- `skills` — lista di skill precaricate: il loro **contenuto completo** viene iniettato all'avvio.
- `mcpServers` — server MCP per l'agente (riferimenti a server già configurati o definizioni inline).
- `hooks` — hook di ciclo di vita, ambito solo-agente (`PreToolUse`, `PostToolUse`, `Stop`→`SubagentStop`).
- `memory` — `user`, `project` o `local`: memoria persistente tra conversazioni.
- `background` — booleano; forza l'esecuzione in background.
- `effort` — `low`, `medium`, `high`, `xhigh`, `max` (dipende dal modello).
- `isolation` — `worktree` per eseguire in un git worktree isolato.
- `color` — `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`.
- `initialPrompt` — primo turno auto-inviato (solo quando l'agente gira come sessione principale via `--agent`).

### Regola
- Dichiarare **sempre e solo** `name` e `description` come minimo; aggiungere gli altri campi solo se portano valore reale.
- Non inventare campi non presenti in questo schema.
- `name` in kebab-case minuscolo, coerente col nome del file.

## 2. Posizione dei file e scope

| Posizione | Scope | Priorità |
|-----------|-------|----------|
| Managed settings | Organizzazione | 1 (massima) |
| `--agents` (CLI) | Sessione corrente | 2 |
| `.claude/agents/` | Progetto | 3 |
| `~/.claude/agents/` | Utente (tutti i progetti) | 4 |
| `agents/` di un plugin | Dove il plugin è attivo | 5 (minima) |

### Regola
- Gli agent di progetto (`.claude/agents/`) vanno versionati per condivisione col team.
- L'identità dell'agente deriva **solo** dal campo `name`, non dal path: le sottocartelle sono ammesse ma non cambiano l'identità.
- Mantenere i `name` unici dentro ogni scope per evitare conflitti silenziosi di caricamento.

## 3. La description guida la delega automatica

La `description` è il modo con cui Claude decide **quando** invocare l'agente. Va scritta con questo scopo.

### Regola
- Includere **sia cosa fa l'agente sia quando usarlo.**
- Usare linguaggio **specifico e orientato all'azione**, con frasi trigger: «Usa quando…», «Usa proattivamente…», «Usa per…», «Usa se…».
- Nominare domini, tool, framework o condizioni concrete che attivano l'agente.
- Scrivere in **terza persona** (descrivendo l'agente), non in prima o seconda persona.

### Perché
Una description vaga rende l'agente invisibile alla delega automatica o lo fa invocare a sproposito. Il modello sceglie l'agente leggendo questa stringa: se non dice quando usarlo, non verrà usato bene.

### Esempio corretto
```yaml
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
```

### Anti-esempio
```yaml
description: Code reviewer
```

## 4. Restrizione dei tool

### Regola
- Concedere **solo i tool necessari** al compito (principio del minimo privilegio): riduce superficie d'attacco e mantiene l'agente focalizzato.
- Agenti di sola lettura/analisi: `Read`, `Grep`, `Glob` (ed eventualmente `Bash`); **omettere `Write`, `Edit`, `MultiEdit`**.
- Agenti che modificano codice: aggiungere `Edit`/`Write` solo se davvero scrivono.
- Preferire l'allowlist (`tools`) alla denylist, salvo casi in cui la denylist è più chiara.
- Non lasciare `tools` omesso «per comodità»: l'ereditarietà totale è un rischio, non una scelta di default accettabile per un agente specializzato.

### Note sulle restrizioni automatiche (da conoscere in revisione)
- Alcuni tool sono **sempre rimossi** dai subagent a prescindere da `tools` (es. `Agent`, `AskUserQuestion`, `ExitPlanMode` salvo `permissionMode: plan`, `Workflow`, `ScheduleWakeup`). Non elencarli sperando di riabilitarli.
- I subagent in background mantengono solo un sottoinsieme di tool salvo elencarli esplicitamente. Se un agente in background deve usare un tool fuori dal set base, va dichiarato in `tools`.
- Se **nessun** tool in `tools` risolve a un tool reale (es. tutti scritti male), l'agente **non parte**. Verificare la scrittura esatta dei nomi.

## 5. Selezione del modello

### Regola
- Default `inherit`: adeguato per la maggior parte degli agenti.
- Fissare `model` esplicito solo quando il compito lo giustifica: modelli più leggeri (`haiku`) per compiti meccanici/ripetitivi, più potenti per ragionamento complesso o review critica.
- Ricordare l'ordine di risoluzione: env `CLAUDE_CODE_SUBAGENT_MODEL` → parametro per-invocazione → campo `model` → modello della sessione padre.

## 6. Scrittura del system prompt (corpo markdown)

Il corpo dopo il secondo `---` è il system prompt dell'agente. Riceve solo questo prompt più dettagli minimi d'ambiente, **non** il system prompt completo di Claude Code.

### Regola
- **Conciso.** Non ripetere ciò che il modello già sa. Per ogni frase chiedersi: «serve davvero?».
- **Responsabilità singola.** L'agente deve eccellere in un compito preciso, non essere un tuttofare.
- **Gradi di libertà proporzionati:** istruzioni testuali quando più approcci sono validi; passi/script precisi per operazioni fragili che richiedono una sequenza rigida.
- **Workflow e checklist:** per compiti complessi, dare passi sequenziali chiari («Quando invocato: 1… 2… 3…») e checklist che l'agente può spuntare.
- **Loop di validazione** per operazioni critiche: esegui → valida → correggi → ripeti.
- **Esempi concreti** input/output quando la qualità dipende dal vederli, invece di sole descrizioni astratte.
- **Terminologia coerente:** un solo termine per un concetto, usato ovunque.
- **Niente informazioni a scadenza** (date che invecchiano).
- **Definire il formato dell'output atteso** dall'agente (cosa restituisce e come), dato che il suo output finale è un dato per il processo chiamante, non un messaggio all'utente.

### Struttura consigliata del corpo
1. Una frase che definisce ruolo e specializzazione.
2. «Quando invocato:» — passi iniziali concreti.
3. Checklist o criteri di qualità del compito.
4. Formato dell'output / priorità delle risposte.
5. Vincoli e cosa NON fare.

# Checklist di CREAZIONE di un nuovo agente
Prima di considerare pronto un nuovo agente, verifica:
- [ ] `name` in kebab-case minuscolo, univoco, coerente col file
- [ ] Responsabilità **singola e chiara**: cosa fa in modo unico questo agente?
- [ ] `description` che dice **cosa fa E quando usarlo**, in terza persona, action-oriented
- [ ] `tools` esplicito e **minimo** per il compito
- [ ] `model` adeguato (default `inherit` salvo motivo)
- [ ] System prompt conciso, con passi/checklist e formato di output definito
- [ ] Nessun campo frontmatter inventato o fuori schema
- [ ] Se di progetto: pronto per il versionamento

# Checklist di REVISIONE di un agente esistente
Per ogni agente da revisionare, controlla e segnala:
- [ ] `name` valido (solo minuscole e trattini) e univoco nello scope
- [ ] `description` sufficiente a guidare la delega: contiene i trigger «quando usarlo»? È in terza persona? Non è vaga?
- [ ] `tools`: è presente? È minimo? Contiene tool inutili (es. `Write`/`Edit` in un agente di sola analisi) o tool che verrebbero comunque rimossi?
- [ ] `model`: la scelta è giustificata o `inherit` sarebbe più appropriato?
- [ ] System prompt: è focalizzato su una responsabilità? È conciso? Definisce il formato di output? Ha passi/checklist dove servono?
- [ ] Coerenza con gli altri agenti del repository (naming, struttura, tono)
- [ ] Assenza di informazioni a scadenza e di terminologia incoerente

Quando revisioni, **separa** i rilievi per gravità: problemi che rompono la delega o la sicurezza (tool eccessivi, description muta), problemi di qualità (system prompt verboso, output non definito), suggerimenti minori.

# Esempio di frontmatter minimo corretto
```yaml
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- No exposed secrets or API keys
- Proper error handling
- Good test coverage

Provide feedback organized by priority (critical / warning / suggestion),
with specific examples of how to fix each issue.
```

# Vincoli
- Non introdurre campi frontmatter non previsti dallo schema ufficiale.
- Non lasciare `tools` implicito in un agente specializzato senza motivo esplicito.
- Non scrivere description vaghe o in prima/seconda persona.
- Non gonfiare il system prompt con nozioni che il modello già possiede.
- Non assegnare a un agente più di una responsabilità principale.
- Non usare `permissionMode: bypassPermissions` senza giustificazione esplicita.

# Esempi di attivazione
- «Crea un agente che fa X»
- «Revisiona questo agente in .claude/agents/»
- «La description di questo agente va bene?»
- «Perché Claude non delega mai a questo subagent?»
- «Sistema il frontmatter di questo agente»

# Esempi di non attivazione
- «Scrivimi un service Spring Boot»
- «Spiegami cos'è un agente»
- «Costruisci un agente con l'Agent SDK in Python»

# Nota finale
Questa skill è lo standard di riferimento per creare e revisionare i subagent di Claude Code del progetto e dell'utente. Il criterio guida resta: responsabilità singola, description che guida la delega, tool minimi, system prompt conciso e con output definito.
