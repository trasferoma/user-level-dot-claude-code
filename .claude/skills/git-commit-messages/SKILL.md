---
name: git-commit-messages
description: Compone il messaggio di un commit git secondo le convenzioni di questo utente. Usa quando devi scrivere, correggere o revisionare un messaggio di commit, o verificare che i commit di un branch siano conformi. Impone un sommario in italiano alla terza persona SENZA prefisso di tipo e senza scope (niente Conventional Commits, niente «feat:», «fix:», «chore:»), corpo che spiega il perché solo sui commit non auto-evidenti, sezione «Moduli impattati» sui soli progetti Liferay/OSGi e riga finale «tkn: <token>». Copre sommario, corpo, trailer, merge, revert, checklist di validazione ed esempi. Il token si determina con la skill git-branch-token. NON copre l'esecuzione di commit, push o altre operazioni git.
allowoed-tools: Bash(git status:*), Bash(git diff --staged)
model: Haiku
effort: medium
---

# Scopo
Comporre il testo di un messaggio di commit: sommario in italiano senza prefisso di tipo, corpo che spiega il perché quando serve, moduli impattati sui progetti Liferay/OSGi, riga del token in chiusura.

# Quando usare questa skill
- scrivere, correggere o revisionare il messaggio di un commit (anche in `--amend` o durante un reword)
- verificare che i commit di un branch siano conformi
- decidere se un insieme di modifiche sta in un solo commit

# Quando NON usare questa skill
- **esecuzione** di operazioni git (staging, push, rebase, verifiche) → agente `git-specialist`, skill `git-inspection`
- solo il token del branch e non il messaggio → `git-branch-token`
- generare o modificare codice applicativo

# Regole di precedenza
- Le istruzioni dell'utente per il singolo commit prevalgono su questa skill.
- Se la storia del branch usa già un'altra convenzione coerente, segnalalo prima di divergere: per i commit nuovi vale comunque il formato definito qui.
- La riga `tkn:` è un vincolo duro: nessuna esigenza di stile la sposta dall'ultima riga.

# Regole operative

## Struttura

```text
<descrizione sintetica in italiano>

<corpo: perché e conseguenze, righe ≤ 72 caratteri>

Moduli impattati:
- <nome-breve-modulo>

tkn: <token>
```

Obbligatori: sommario, riga vuota dopo il sommario, `tkn:` come ultima riga.
Condizionali: corpo (se il commit non è auto-evidente), «Moduli impattati» (solo Liferay/OSGi), trailer (solo se pertinenti).

## Sommario
- **Nessun prefisso di tipo e nessuno scope**: il sommario è la sola descrizione. Non usare Conventional Commits né alcuna sua variante: `feat:`, `fix(gestione-bandi):`, `chore(i18n):`, `refactor!:` sono tutti errori, anche quando il tipo sembra ovvio.
- Non sostituire il prefisso vietato con equivalenti travestiti: niente `[fix]`, `FIX -`, `bugfix:`, né il nome del modulo o dell'area come prefisso (`gestione-enti: ...`).
- `descrizione` in italiano, terza persona presente («aggiunge», «corregge», «consente»), iniziale minuscola, senza punto finale, riga ≤ 72 caratteri e idealmente ≤ 60.
- Descrivi l'**effetto funzionale**, non i file toccati: quelli li mostra il diff.
- Breaking change: nessun `!` nel sommario (non c'è prefisso a cui attaccarlo); dillo nella descrizione e aggiungi il trailer `BREAKING CHANGE: <conseguenza>`.
- Vietati: `fix vari`, `modifiche custom`, `aggiornamenti`, `wip`, un nome di file, un numero di ticket da solo.

## Corpo
- **Obbligatorio** se il commit cambia comportamento, tocca più di due o tre file, o la ragione non si deduce dal sommario. **Omesso** sui commit auto-evidenti: allineamento di versione, refuso o riformulazione di una label o di un tooltip i18n, rimozione di commenti, rinomina locale. In questi casi il messaggio è solo sommario, «Moduli impattati» e token.
- Se stai scrivendo un corpo per dire «cambia solo il testo della label, nessun impatto funzionale», il corpo non serve: cancellalo.
- Spiega **perché** e con quali conseguenze; su un difetto, di' la causa reale e non il sintomo.
- Righe ≤ 72 caratteri, elenchi puntati ammessi per cambiamenti indipendenti dello stesso tema.
- Nessun percorso di file, nome di branch, stack trace o diff. Nessuna promessa di follow-up («poi sistemeremo»).

## Moduli impattati (solo Liferay/OSGi)
- Presente **solo** su workspace Liferay/OSGi; altrove omessa del tutto, senza scrivere «nessuno».
- Nome **breve** del modulo: segmento di cartella immediatamente precedente a `/src/`, non il path. Stessa convenzione del report di passaggio in produzione. Elenco deduplicato, in ordine alfabetico.
- Ogni modulo toccato dal diff va elencato: **nessuna omissione silenziosa**. I file che non appartengono a un modulo (script SQL, asset fuori da `modules/`, configurazione di root) non compaiono.
- Oltre otto moduli: il commit sta probabilmente mescolando temi. Segnalalo e proponi di spezzarlo.

Riconoscimento del progetto, derivazione dei nomi dal diff, file fuori da `/src/`, esclusioni e controllo di copertura: [reference/moduli-osgi-liferay.md](reference/moduli-osgi-liferay.md).



## Casi particolari
- **Merge**: conserva il sommario generato da git (`Merge branch '...'`); aggiungi corpo e token solo se il merge ha richiesto scelte non ovvie (conflitti risolti a favore di un lato, comportamento cambiato).
- **Revert**: sommario `annulla <sommario del commit ripristinato>`, corpo con il motivo del ripristino, trailer `Reverts: <sha>`, poi il token del branch corrente. Non usare il prefisso `revert:` generato da git: riscrivi il sommario.
- **Commit che mescola temi**: non scrivere un sommario generico per tenerli insieme; proponi commit separati, uno per tema.
- **Cherry-pick**: mantieni il messaggio originale e sostituisci la sola riga del token con quello del branch di destinazione.
- **`fixup!` / `squash!`**: ammessi senza token purché riassorbiti prima del push; il commit definitivo deve essere conforme.

## Checklist prima di consegnare il messaggio

```text
- [ ] sommario senza prefisso di tipo e senza scope: inizia con il verbo, non con «feat», «fix», «chore» o un nome di modulo
- [ ] sommario italiano, terza persona, iniziale minuscola, senza punto, ≤ 72 caratteri
- [ ] riga vuota dopo il sommario
- [ ] corpo presente solo se il commit non è auto-evidente, e spiega il perché
- [ ] nessun percorso di file o nome di branch nel testo
- [ ] «Moduli impattati» presente su Liferay e assente altrove, completo, alfabetico
- [ ] ultima riga «tkn: <token>», verificato sul branch
```

Voce aperta → correggi il messaggio e ripeti la checklist. Non consegnare un messaggio con voci aperte.

## Context

Current git status: !`git status`
Current git diff: !`git diff --staged`

# Esempi

Correzione su progetto Liferay, con moduli:

```text
consente il cambio referente su istanza chiusa

Il cambio referente era rifiutato dopo la chiusura dell'istanza perché
la validazione guardava lo stato invece dei permessi dell'operatore.
Lo stato non è più discriminante: il controllo passa dal ruolo attivo.

Moduli impattati:
- gestione-referente-istanze-common
- gestione-referente-istanze-web

tkn: cambio-referente
```

Commit auto-evidente su progetto Liferay: nessun corpo, solo sommario, moduli e token.

```text
accorcia il tooltip del flag di protocollazione degli allegati aggiuntivi

Moduli impattati:
- gestione-enti-frontend

tkn: protocolla-allegati
```

Rifattorizzazione su progetto non Liferay, con trailer e senza «Moduli impattati»:

```text
estrae il rollback della protocollazione in un servizio dedicato

Il rollback della protocollazione era duplicato nei tre rami di chiusura
domanda, con messaggi di errore divergenti. La logica passa in un
servizio unico che riceve il contesto di rollback già costruito.

tkn: rollback-protocollazione
```

Anti-esempi:

- prefisso di tipo: `chore(i18n): accorcia il tooltip del flag` → il sommario corretto è `accorcia il tooltip del flag`
- corpo inutile su un cambio di label, che si limita a riformulare il sommario e a dichiarare «nessun impatto funzionale»
- sommario `fix vari`, corpo che elenca i file toccati (`sistemato PortletUtil.java`, `aggiornati alcuni jsp`), nessun token

# Vincoli
- Non omettere la riga `tkn:` né spostarla dall'ultima posizione; non inventare il token.
- Non premettere al sommario un tipo, uno scope, un tag fra parentesi quadre o il nome di un modulo: il sommario comincia dal verbo.
- Non scrivere il messaggio in inglese, salvo richiesta esplicita.
- Non inserire «Moduli impattati» fuori dai progetti Liferay/OSGi, né omettere moduli realmente toccati per tenere corto il messaggio.
- Non usare questa skill per giustificare un commit che mescola temi: prima proponi di spezzarlo.
- Non fare mai commit in autonomia, chiedi sempre 
