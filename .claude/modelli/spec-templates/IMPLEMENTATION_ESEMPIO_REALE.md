# IMPLEMENTATION — Collisione tra Mario e i nemici

**Specifica di riferimento:** `SPEC_ESEMPIO_REALE.md`  — nel resto del documento: «la SPEC».
**Stato:** `COMPLETED`  <!-- NOT_STARTED | IN_PROGRESS | BLOCKED | COMPLETED -->

Documento di lavoro: la SPEC (il "cosa") resta stabile; qui vivono stato, piano, decisioni e problemi (il "come").

## Regole per l'agente
- Leggere `CLAUDE.md` (se presente) e la SPEC prima di toccare codice.
- Alla ripresa del lavoro, leggere prima questo file e riprendere dallo stato corrente.
- Prima di modificare, elencare i file che verranno toccati. Nessun refactoring fuori scope.
- Non modificare i requisiti della SPEC senza decisione esplicita.
- Dopo ogni fase: eseguire i test pertinenti e aggiornare questo file. Spuntare una voce solo dopo verifica reale, mai a priori.
- Scelta che **non** cambia il comportamento osservabile → procedi e annotala in *Decisioni*.
- Scelta che **cambia** comportamento o criteri di accettazione, o ambiguità non risolvibile dalla SPEC → **fermati**, imposta lo stato a `BLOCKED` e registra in *Problemi aperti* / *Deviazioni*.

## Piano operativo

**Fase 1 — Analisi**
- [x] Individuati i punti del codice: `CollisionSystem`, `Player`, `Enemy`.
- [x] Confermato che il rilevamento collisioni AABB per le piattaforme esiste già ed è riusabile.
- [x] Rilevato lo stile dei test esistenti (JUnit, un test per comportamento).
- [x] Compilata "File coinvolti (effettivi)".

**Fase 2 — Implementazione**
- [x] Aggiunto il dispatch della collisione Mario–nemico nel `CollisionSystem` esistente.
- [x] Collisioni con piattaforme/oggetti invariate.
- [x] Nessun refactoring fuori scope.

**Fase 3 — Test**
- [x] Un test per ciascun criterio della *Definition of done* della SPEC.
- [x] Eseguita la suite del modulo collisioni.

**Fase 4 — Revisione**
- [x] Coerenza con la SPEC; nessuna modifica non richiesta.
- [x] Quality gate superate (analisi statica, coverage).
- [x] Aggiornati *Decisioni* ed *Esito finale*; stato portato a `COMPLETED`.

## File coinvolti (effettivi)
- `CollisionSystem.java` — dispatch della collisione Mario–nemico
- `Player.java` — stato di invincibilità, rimbalzo, danno
- `Enemy.java` — metodo `defeat()`
- `CollisionMarioEnemyTest.java` — casi della Definition of done

## Registro
Voci datate (`YYYY-MM-DD`), append-only.

- **Decisioni tecniche** — `2026-07-03` · introdotto `STOMP_MARGIN` per il rilevamento "dall'alto" · tollera l'imprecisione tra frame · nessun impatto sulle collisioni con le piattaforme.
- **Deviazioni dalla SPEC** — nessuna.
- **Problemi aperti** — nessuno.
- **Test eseguiti** — `2026-07-03` · Fase 3 · `./gradlew test` · verde (4/4).

## Esito finale
- **Stato:** `COMPLETED`
- **Modifiche:** dispatch collisione Mario–nemico nel `CollisionSystem`; sconfitta con rimbalzo dall'alto, danno sugli altri lati, sconfitta senza danno con stella.
- **Test:** 4 test (uno per criterio verificabile della DoD), tutti verdi; il criterio "nessuna modifica non richiesta" verificato in revisione.
- **Note residue:** nessuna.

## Esempio
```java
// File coinvolti (effettivi):
//   CollisionSystem          — dispatch collisione Mario–nemico
//   Player                   — invincibilità, rimbalzo (bounce), danno
//   Enemy                    — defeat()
//   CollisionMarioEnemyTest  — casi della DoD

// Test: uno per criterio della DoD (il criterio "nessuna modifica non richiesta"
// è verificato in revisione, non con un test unitario)
@Test void stompDallAlto_nemicoSconfitto_marioRimbalza() { /* Mario in caduta sopra il nemico */ }
@Test void collisioneLaterale_marioSubisceDanno()        { /* contatto di lato */ }
@Test void conStella_nemicoSconfitto_nessunDanno()       { /* invincibilità attiva */ }
@Test void collisioniPiattaforme_invariate()             { /* test di regressione */ }
```
