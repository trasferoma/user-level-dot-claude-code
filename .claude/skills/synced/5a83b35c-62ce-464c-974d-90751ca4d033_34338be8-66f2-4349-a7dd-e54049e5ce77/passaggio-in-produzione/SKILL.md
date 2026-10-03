---
name: passaggio-in-produzione
description: Genera un report semplice del passaggio in produzione confrontando due branch git. Per ogni attività elenca i moduli applicativi impattati (nome breve) e gli script SQL rilasciati. Skill SOLO a invocazione manuale (`/passaggio-in-produzione` o richiesta esplicita del documento/report di passaggio in produzione): non attivarla mai in autonomia, nemmeno per un semplice confronto/diff tra branch.
disable-model-invocation: true
---

# Scopo

Produrre un **report semplice di passaggio in produzione** a partire dal confronto tra due
branch di un repository git. Il report deve rendere chiari tre elementi, e solo quelli:

1. **l'attività** — cosa è stato fatto, raggruppato per tema funzionale (non un commit alla volta);
2. **i moduli impattati** — con il nome breve del modulo;
3. **gli script SQL creati** — solo il nome file delle migration rilasciate.

Tutto il resto (letture di merito dei singoli diff, spiegazioni) si fa solo se richiesto dopo.

# Attivazione (VINCOLO DURO)

- Skill **solo a invocazione manuale**. Non attivarla mai da sola, nemmeno se il task in corso
  somiglia allo scopo (confronto branch, release, elenco moduli, changelog, script DB).
- Eseguirla **solo** su richiesta esplicita: `/passaggio-in-produzione`, oppure "genera/aggiorna
  il report (o documento) di passaggio in produzione".
- In assenza di richiesta esplicita, ignorarla.

# Repository e branch di default

Se l'utente non indica altro, usare questi valori (repo oros, sola lettura via URL diretto):

- **URL:** `https://oros-git.regione.puglia.it/innovapuglia/rp2412-hubpa/hubpa-servizi-digitali/hubpa-egov-bandi-codice-sorgente/hubpa-servizi-digitali-liferay.git`
- **Branch base:** `main`
- **Branch target:** `ambiente-coll`
- **Filtro autore:** nessuno (tutti gli autori del range)
- **Output:** stampa la tabella direttamente in risposta (nessun file, salvo richiesta)

Questi sono default sovrascrivibili: se l'utente passa un altro repo, altri branch, un autore o
un percorso di output, usare i suoi valori.

## SHA di riferimento (opzionale, delta dall'ultimo confronto)

Gli SHA dei tip cambiano nel tempo: **non assumerli mai**, rileggerli sempre al volo dopo il fetch.
Se l'utente vuole solo le differenze rispetto all'ultimo confronto, fornisce lo SHA target
precedente: in quel caso confrontare `<SHA_target_precedente>..<SHA_target_nuovo>` invece del range
completo. Se chiede di ricordarlo, salvare in memoria lo SHA target di oggi come riferimento.

# Input richiesti

Prima di procedere, verificare di avere (altrimenti chiedere solo ciò che è ambiguo e decisivo):

1. **Repo e accesso** — default: repo oros sopra, in sola lettura.
2. **Branch base** e **branch target** — default: base `main`, target `ambiente-coll`.
3. **Filtro autore** (opzionale) — se il report deve includere solo alcune identità (nome/email).
   Chiederlo **solo** se nel range compaiono più autori e l'utente vuole restringere.
4. **Output** — inline (default) o percorso file. Se file, usare la cartella
   `passaggio_in_produzione/` **fuori** dal repo del progetto.

# Processo operativo

## 1. Recupero oggetti (sola lettura — vincoli tassativi)

Se il repo è remoto: NON aggiungere remote, NON creare branch locali, NON modificare
config/ref/working tree. Scaricare solo oggetti in `FETCH_HEAD`.

```
git fetch --no-tags <URL> <branch-base>      # poi leggere lo SHA base
git fetch --no-tags <URL> <branch-target>    # poi leggere lo SHA target
```

Salvare i due SHA leggendoli al volo (es. `git rev-parse FETCH_HEAD` dopo ciascun fetch).

## 2. Divergenza

```
git merge-base <SHA_BASE> <SHA_TARGET>
git rev-list --left-right --count <SHA_BASE>...<SHA_TARGET>   # (indietro  avanti)
git shortlog -sne --no-merges <SHA_BASE>..<SHA_TARGET>        # autori nel range
```

## 3. Commit e file

Per tutti gli autori (o solo quelli filtrati):

```
git log --no-merges [--author=<email>] --format="%h %ad %s" --date=short <SHA_BASE>..<SHA_TARGET>
git log --no-merges [--author=<email>] --name-only --format="" <SHA_BASE>..<SHA_TARGET> | sort -u
```

Per lo stato (Aggiunto/Modificato/Eliminato):
`git diff --name-status <SHA_BASE>..<SHA_TARGET> -- <path>`.

## 4. Raggruppamento in attività

Aggregare i commit in **poche righe di attività** a partire dai messaggi e dai file toccati.
Ogni riga è un tema funzionale, non un singolo commit.

- Descrizione sintetica e orientata al business (es. "Firma remota (FDR) e data di validità",
  "Gestione Audit", "Rifacimento della gestione dei codici ATECO").
- Un fix puntuale con un solo file è comunque una riga a sé.

# Regole di derivazione dei contenuti

## Moduli impattati

- Usare il **nome breve** del modulo, non il path completo: è il segmento di cartella
  immediatamente **precedente a `/src/`**.
  - `modules/gestione-bandi/gestione-bandi-frontend/src/...` → `gestione-bandi-frontend`
  - `modules/gestione-bandi/gestione-eventi/catalogo-eventi-frontend/src/...` → `catalogo-eventi-frontend`
  - `modules/servizi-digitali-common/servizi-digitali-fdr-integration/src/...` → `servizi-digitali-fdr-integration`
- Deduplicare i nomi, ordine leggibile.
- **Escludere** `servizi-digitali-database-version-control`: il suo contenuto va in "Script SQL".
- Gli asset frontend sotto `alpaca/` (fuori da `modules/`) **non** sono moduli: attribuirli
  all'attività pertinente senza elencarli come modulo.
- Se un'attività non ha moduli Java significativi (solo JS/JSON/asset), lasciare `—`.

## Script SQL

- Considerare **solo** i file sotto
  `modules/servizi-digitali-database-version-control/src/main/resources/db/migration/`.
- Riportare **solo il nome file**
  (es. `V2026.06.23.1__BANDI_insert_dato_bando_abilita_firma_data_istanza.sql`).
- Associare ogni script all'attività pertinente in base al tema (nome file + commit).
- Se l'attività non ha script, lasciare `—`.

# Formato di output

Puntare alla **massima semplicità**. Prima una breve intestazione (verifica di ripetibilità),
poi una tabella Markdown con le tre colonne essenziali.

```markdown
## Passaggio in produzione — <target> vs <base>

- Repo: <URL o "locale">
- SHA base (<base>): <sha>  ·  SHA target (<target>): <sha>  ·  merge-base: <sha>
- Divergenza: target +<avanti> / -<indietro> commit rispetto a base  ·  file differenti: <N>

| # | Attività | Moduli impattati | Script SQL |
|---|----------|------------------|------------|
| 1 | Firma remota (FDR) e data di validità | servizi-digitali-fdr-integration, gestione-bandi-common | V2026.06.23.1__BANDI_insert_dato_bando_abilita_firma_data_istanza.sql |
| 2 | Gestione Audit | — | V2026.07.01.1__AUDIT_configurazione_log_gestione_referente_istanze.sql |
```

Regole minime:

- Numerazione `#` progressiva da 1.
- Moduli separati da virgola (nome breve); `—` se nessun modulo.
- Script separati da `; ` (solo nome file); `—` se nessuno.
- Se l'utente non chiede un file, stampare la tabella direttamente in risposta.

# Vincoli

- **Sola lettura sul repo**: mai `remote add`, mai creare branch, mai toccare working tree/config.
  Solo `git fetch <URL> <branch>` con lettura da `FETCH_HEAD`.
- Non compilare né buildare il progetto, non lanciare Gradle.
- Se si salva un file, **non** metterlo dentro il repo del progetto: usare
  `passaggio_in_produzione/` (o il percorso indicato).
- Non inventare moduli o script: elencare solo ciò che risulta dal diff reale.
- Rispettare i nomi brevi dei moduli e i nomi file esatti degli script SQL.
- Non entrare nel merito dei singoli diff se non richiesto esplicitamente dopo.
- Non attivarsi mai in autonomia (vedi "Attivazione").

# Esempi di attivazione

- "/passaggio-in-produzione"
- "Genera il report di passaggio in produzione per ambiente-coll vs main"
- "Aggiorna la tabella di rilascio con le mie modifiche"

# Esempi di NON attivazione

- "Confronta i due branch e dimmi i moduli impattati" (nessuna richiesta del report formale)
- "Spiegami cosa ha fatto Tizio" (analisi, non report)
- Qualsiasi caso senza richiesta esplicita del report di passaggio in produzione.
