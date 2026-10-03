# IMPLEMENTATION — <titolo della modifica>

**Specifica di riferimento:** `<percorso-della-specifica>`  — nel resto del documento: «la SPEC».
**Stato:** `NOT_STARTED`  <!-- NOT_STARTED | IN_PROGRESS | BLOCKED | COMPLETED -->

Documento di lavoro: la SPEC (il "cosa") resta stabile; qui vivono stato, piano, decisioni e problemi (il "come").

## Regole per l'agente
- Leggere `CLAUDE.md` (se presente) e la SPEC prima di toccare codice.
- All'apertura di ogni fase, annunciare la fase in una riga sola prima di qualunque altra cosa: `Fase <N> delegata: <obiettivo>` se la fase passa a un subagent, `Fase <N> in corso: <obiettivo>` altrimenti. L'obiettivo si copia dalla riga **Annuncio:** della fase. Mai `faccio partire la fase <N>` senza obiettivo.
- Alla ripresa del lavoro, leggere prima questo file e riprendere dallo stato corrente.
- Prima di modificare, elencare i file che verranno toccati. Nessun refactoring fuori scope.
- Non modificare i requisiti della SPEC senza decisione esplicita.
- Dopo ogni fase: eseguire i test pertinenti e aggiornare questo file. Spuntare una voce solo dopo verifica reale, mai a priori.
- Scelta che **non** cambia il comportamento osservabile → procedi e annotala in *Decisioni*.
- Scelta che **cambia** comportamento o criteri di accettazione, o ambiguità non risolvibile dalla SPEC → **fermati**, imposta lo stato a `BLOCKED` e registra in *Problemi aperti* / *Deviazioni*.

## Piano operativo

**Fase 1 — Analisi**
**Annuncio:** `Fase 1 in corso: <obiettivo dell'analisi nel linguaggio del dominio>`
- [ ] Individuare i punti del codice coinvolti e le convenzioni/pattern già presenti.
- [ ] Confermare le assunzioni della SPEC (ciò che dovrebbe già esistere esiste davvero).
- [ ] Rilevare lo stile dei test esistenti.
- [ ] Compilare "File coinvolti (effettivi)".

**Fase 2 — Implementazione**
**Annuncio:** `Fase 2 delegata: <cosa viene implementato, nel linguaggio del dominio>`
- [ ] Applicare la modifica seguendo i pattern esistenti e i vincoli della SPEC.
- [ ] Mantenere invariato il comportamento preesistente dove la SPEC lo richiede.
- [ ] Nessun refactoring fuori scope.

**Fase 3 — Test**
**Annuncio:** `Fase 3 delegata: <cosa viene messo sotto test, nel linguaggio del dominio>`
- [ ] Un test per ciascun criterio della *Definition of done* della SPEC.
- [ ] Eseguire la suite del modulo interessato.

**Fase 4 — Revisione**
**Annuncio:** `Fase 4 in corso: <cosa viene verificato, nel linguaggio del dominio>`
- [ ] Coerenza con la SPEC; nessuna modifica non richiesta.
- [ ] Quality gate del progetto superate (analisi statica, coverage), se configurate.
- [ ] Aggiornare *Decisioni/Deviazioni* e portare lo stato a `COMPLETED`.

## File coinvolti (effettivi)
Da compilare in Fase 1 — formato: `` `path/File.java` — motivo``.

## Registro
Voci datate (`YYYY-MM-DD`), append-only.

- **Decisioni tecniche** (non cambiano il comportamento) — `Decisione · Motivazione · Impatto`.
- **Deviazioni dalla SPEC** (da motivare) — `Descrizione · Motivazione · Impatto · Aggiorna la SPEC? sì/no`.
- **Problemi aperti** (bloccano l'avanzamento) — `Descrizione · Impatto · Opzioni · Decisione richiesta`.
- **Test eseguiti** — `data · fase · comando · esito`.

## Esito finale
Da compilare a fine lavoro: stato finale, modifiche effettuate, test eseguiti, note residue.

## Esempio (concreto: filtro `status` su ricerca utenti)
```java
// File coinvolti (effettivi) — esempio:
//   UserController          — nuovo query param opzionale "status"
//   UserSearchRequest       — campo UserStatus status
//   UserService/Repository  — filtro applicato solo se status != null
//   UserSearchTest          — casi della Definition of done

// Test: uno per criterio della DoD
@Test void senzaStatus_risultatiInvariati()      { /* stessa lista di prima */ }
@Test void statusActive_soloUtentiAttivi()        { /* solo ACTIVE */ }
@Test void statusDisabled_soloUtentiDisabilitati(){ /* solo DISABLED */ }
@Test void statusNonValido_erroreValidazione()    { /* attende errore, es. HTTP 400 */ }
@Test void statusCombinatoConAltroFiltro()        { /* status + filtro esistente */ }
```
