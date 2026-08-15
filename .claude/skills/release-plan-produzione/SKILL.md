---
name: release-plan-produzione
description: Genera un report semplice del passaggio in produzione confrontando due branch git. Per ogni attività elenca i moduli applicativi impattati (nome breve) e gli script SQL rilasciati. Skill a sola invocazione manuale con `/release-plan-produzione` o su richiesta esplicita del documento di passaggio in produzione.
disable-model-invocation: true
---

# Scopo

Produrre un **report semplice di passaggio in produzione** a partire dal confronto tra due
branch di un repository git. Il report deve rendere chiari tre elementi, e solo quelli:

1. **l'attività** — cosa è stato fatto, raggruppato per tema funzionale (non un commit alla volta);
2. **i moduli impattati** — con il nome breve del modulo;
3. **gli script SQL creati** — solo il nome file delle migration rilasciate.

Tutto il resto (letture di merito dei singoli diff, spiegazioni) si fa solo se richiesto dopo.

# Quando usare questa skill

Usa questa skill **solo** se:
- l'utente digita `/release-plan-produzione`
- l'utente chiede esplicitamente di generare o aggiornare il report (o documento) di passaggio
  in produzione

# Quando NON usare questa skill

Non usare questa skill se:
- il task somiglia allo scopo ma la richiesta non è esplicita: confronto tra branch, release,
  elenco moduli, changelog, elenco script DB
- serve solo un diff o una lettura di merito dei commit
- manca una richiesta esplicita del documento di passaggio in produzione

L'attivazione automatica è disabilitata dal frontmatter (`disable-model-invocation: true`),
quindi la skill si carica solo su richiesta.

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
git diff --name-status <SHA_BASE>..<SHA_TARGET>              # elenco completo file + stato
```

**Non** usare `git log --name-only ... | sort -u`: quel comando stacca i file dai commit e
fa perdere il legame file→tema, che è la causa più frequente di attribuzioni sbagliate.
Mantenere invece il legame file↔commit con:

```
git log --no-merges --name-only --format="=== %h %s" <SHA_BASE>..<SHA_TARGET>   # file raggruppati per commit
```

## 3-bis. Verifica del contenuto reale (attribuzione basata sul diff, non sulle euristiche)

Il messaggio di commit e il nome del modulo sono **indizi**, non prove. Prima di attribuire un
file a un'attività, in questi casi **ispezionare il diff reale del file** (`git diff <SHA_BASE>..<SHA_TARGET> -- <path>`,
oppure `git log -p ... -- <path>`, eventualmente filtrando con un pattern del tema):

- il file appartiene a un **modulo condiviso** toccato da più temi (es. un `*-common` o un
  `*-frontend` usato da più feature);
- lo stesso file compare in **commit di temi diversi**, o in un commit dal messaggio generico
  (`feat modifiche custom`, `fix vari`);
- un modulo sembra appartenere a un'attività "per intuizione", ma nessun commit lo dice
  esplicitamente.

Esempio del tipo di errore da evitare: la modifica firma FDR (`setVerificaFirmaSuDataFineValidita`,
`getVerificaFirmaSoloDataOggiByBandoId`) tocca anche `presentatore-forms-bandi-common`,
`presentatore-forms-bandi-frontend` e `gestione-referente-istanze-common`; questi moduli erano
già toccati da altri temi (cambio referente, compilazione domanda) e vanno comunque attribuiti
**anche** all'attività "Firma remota", non solo all'altra.

## 4. Raggruppamento in attività

Aggregare i commit in **poche righe di attività** a partire dai messaggi e, per l'attribuzione
dei moduli, dal **contenuto reale** dei file toccati (vedi 3-bis).
Ogni riga è un tema funzionale, non un singolo commit.

- Descrizione sintetica e orientata al business (es. "Firma remota (FDR) e data di validità",
  "Gestione Audit", "Rifacimento della gestione dei codici ATECO").
- Un fix puntuale con un solo file è comunque una riga a sé.
- **Un file può contribuire a più attività** se il suo diff contiene modifiche di temi diversi:
  in tal caso il suo modulo va elencato in **ognuna** di quelle attività.

## Controllo di copertura (obbligatorio prima di produrre la tabella)

Ogni file del `git diff --name-status` deve essere **coperto da almeno un'attività**. Prima di
scrivere la tabella:

1. scorrere l'elenco completo dei file modificati;
2. verificare che ogni file risulti attribuito ad almeno una riga;
3. per ogni modulo, controllare in **quante** attività i suoi file ricadono e assicurarsi che
   compaia in tutte (non solo nella prima trovata).

Se un file non trova collocazione, non scartarlo: creare una riga "Fix vari" o chiedere. Non è
ammesso omettere silenziosamente un modulo impattato.

# Regole di derivazione dei contenuti

## Moduli impattati

- Usare il **nome breve** del modulo, non il path completo: è il segmento di cartella
  immediatamente **precedente a `/src/`**.
  - `modules/gestione-bandi/gestione-bandi-frontend/src/...` → `gestione-bandi-frontend`
  - `modules/gestione-bandi/gestione-eventi/catalogo-eventi-frontend/src/...` → `catalogo-eventi-frontend`
  - `modules/servizi-digitali-common/servizi-digitali-fdr-integration/src/...` → `servizi-digitali-fdr-integration`
- Deduplicare i nomi **all'interno della stessa attività**, ordine leggibile. Lo **stesso modulo
  può e deve comparire in più attività** se i suoi file cambiano per temi diversi: non è una
  duplicazione da eliminare.
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

- non caricare nient'altr, niente claude.md o altri tipi di file
- **Sola lettura sul repo**: mai `remote add`, mai creare branch, mai toccare working tree/config.
  Solo `git fetch <URL> <branch>` con lettura da `FETCH_HEAD`.
- Non compilare né buildare il progetto, non lanciare Gradle.
- Se si salva un file, **non** metterlo dentro il repo del progetto: usare
  `<cartella temporanea>/passaggio_in_produzione/` (o il percorso indicato).
- Non inventare moduli o script: elencare solo ciò che risulta dal diff reale.
- Rispettare i nomi brevi dei moduli e i nomi file esatti degli script SQL.
- **Non omettere mai un modulo impattato**: ogni file del diff deve ricadere in almeno
  un'attività (vedi "Controllo di copertura").
- Ispezionare i diff **è consentito e dovuto** quando serve ad attribuire correttamente i moduli
  (vedi 3-bis): non è "entrare nel merito". Il divieto di "entrare nel merito" riguarda solo la
  **spiegazione** dei diff all'utente nel report, non la verifica interna necessaria a costruirlo.
- Non attivarsi mai in autonomia (vedi "Attivazione").

# Esempi di attivazione

- "/release-plan-produzione"
- "Genera il report di passaggio in produzione per ambiente-coll vs main"
- "Aggiorna la tabella di rilascio con le mie modifiche"

# Esempi di NON attivazione

- "Confronta i due branch e dimmi i moduli impattati" (nessuna richiesta del report formale)
- "Spiegami cosa ha fatto Tizio" (analisi, non report)
- Qualsiasi caso senza richiesta esplicita del report di passaggio in produzione.
