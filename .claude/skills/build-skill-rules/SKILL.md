---
name: build-skill-rules
description: Regole ufficiali Anthropic per CREARE, MODIFICARE e REVISIONARE le Agent Skills di Claude (le directory con SKILL.md in ~/.claude/skills/, .claude/skills/ o nei plugin). Usa questa skill quando devi scrivere una nuova skill, valutare o correggere una skill esistente, compattarla o deduplicarla senza perdere regole per strada, giudicare la qualità di name e description che governano la scoperta automatica, decidere cosa mettere in SKILL.md e cosa spostare in file di reference, applicare la progressive disclosure, definire workflow e feedback loop, gestire script eseguibili e campi di frontmatter come disable-model-invocation, allowed-tools o context. Copre schema di validazione, naming, concisione, gradi di libertà, anti-pattern, sicurezza, controllo di copertura sulle modifiche, checklist di creazione e di revisione, e sviluppo eval-first. NON usare per generare codice applicativo, né per creare subagent (per quelli usa build-agent-rules).
---

# Scopo
Fornire le regole operative — allineate alla documentazione ufficiale Anthropic — per **creare nuove skill** e **revisionare quelle esistenti** in `~/.claude/skills/` (personali), `.claude/skills/` (progetto) o dentro un plugin.

Una skill è una **directory** il cui entrypoint è `SKILL.md`: frontmatter YAML per la scoperta, corpo markdown per le istruzioni, file opzionali di supporto (reference, template, script). Questa skill governa tutti e tre i livelli.

Fonti ufficiali:
- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` — best practice di authoring
- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview` — architettura, progressive disclosure, sicurezza
- `https://code.claude.com/docs/en/skills` — comportamento e frontmatter specifici di Claude Code

# Quando usare questa skill
Usa questa skill se:
- devi **creare** una nuova skill
- devi **revisionare, correggere o valutare la qualità** di una skill esistente
- devi giudicare `name`, `description`, struttura del corpo, file di supporto o frontmatter di una skill
- una skill non si attiva quando dovrebbe, o si attiva quando non dovrebbe
- devi decidere se un contenuto va in CLAUDE.md, in una skill o in un subagent

# Quando NON usare questa skill
Non usare questa skill se:
- il task è generare o modificare codice applicativo (usa le skill di code generation)
- il task riguarda la creazione o revisione di **subagent** (usa `build-agent-rules`)
- serve solo una spiegazione teorica di cosa sia una skill, senza produrre o revisionare un file
- il task riguarda le skill pre-costruite Anthropic (pptx, xlsx, docx, pdf), che non si autorano

# Regole di precedenza
- Le istruzioni esplicite dell'utente prevalgono su questa skill
- Le regole di sicurezza e i vincoli globali prevalgono su questa skill
- In caso di conflitto con lo stile del parco skill già presente, prevale la coerenza con l'esistente, **salvo** che violi una regola dura qui sotto (validazione del frontmatter, description muta, riferimenti annidati, path Windows)
- Questa skill definisce lo standard di forma; non sostituisce il giudizio sul dominio della singola skill

# Regole operative

## 1. Anatomia di una skill

Una skill è una directory, non un file:

```text
my-skill/
├── SKILL.md          # entrypoint obbligatorio
├── reference.md      # dettagli caricati solo se serve
├── examples.md       # esempi di output
└── scripts/
    └── validate.py   # eseguito, non letto in contesto
```

### Regola
- `SKILL.md` è **l'unico file obbligatorio**. Ogni altro file esiste solo se guadagna il proprio posto.
- Ogni file di supporto va **referenziato da `SKILL.md`**, dicendo cosa contiene e quando leggerlo. Un file mai citato è un file mai letto.
- Nomi di file **descrittivi del contenuto**: `form_validation_rules.md`, non `doc2.md`.
- Path sempre con **slash in avanti**, anche su Windows: `reference/guide.md`, mai `reference\guide.md`.

### Dove vivono e chi vince

| Posizione | Path | Ambito |
|-----------|------|--------|
| Enterprise | managed settings | tutta l'organizzazione |
| Personale | `~/.claude/skills/<nome>/SKILL.md` | tutti i tuoi progetti |
| Progetto | `.claude/skills/<nome>/SKILL.md` | solo quel progetto |
| Plugin | `<plugin>/skills/<nome>/SKILL.md` | dove il plugin è attivo |

A parità di nome: **enterprise batte personale, personale batte progetto**, e qualunque livello batte una skill bundled omonima. Le skill di plugin usano il namespace `plugin:skill` e non collidono.

> ⚠️ Ordine **opposto** a quello dei subagent (dove il progetto batte l'utente). Una skill personale con lo stesso nome di una di progetto **maschera** quella del progetto: verificalo in revisione.

Il nome del comando (`/nome`) viene dalla **directory**, non dal campo `name` del frontmatter — tranne nelle skill di plugin, dove `name` fornisce l'ultimo segmento. Nelle skill personali e di progetto `name` è solo l'etichetta mostrata negli elenchi: tienilo comunque **identico al nome della directory** per non avere due identità.

## 2. Progressive disclosure: i tre livelli

| Livello | Quando entra in contesto | Costo | Contenuto |
|---------|--------------------------|-------|-----------|
| 1. Metadata | sempre, all'avvio | ~100 token per skill | `name` + `description` |
| 2. Istruzioni | quando la skill è invocata | sotto i 5k token | corpo di `SKILL.md` |
| 3. Risorse | solo se lette | zero fino all'accesso | file di reference, script, dataset |

### Regola
- Tratta `SKILL.md` come un **indice ragionato**, non come un manuale: dice cosa fare nei casi comuni e dove andare per i casi rari.
- **Corpo di `SKILL.md` sotto le 500 righe.** Se lo superi, non comprimere: sposta in file separati.
- Nessun limite pratico al contenuto **bundled**: documentazione completa, dataset ampi ed esempi estesi non costano nulla finché nessuno li apre. Il costo è tutto nel livello 2.
- Per file di reference **oltre 100 righe**, metti un indice dei contenuti in testa: se il modello ne fa un'anteprima parziale, vede comunque l'intera portata del file.

### Perché
Il livello 1 è pagato da ogni sessione, per ogni skill installata. Il livello 2 è pagato da ogni sessione che invoca la skill. Il livello 3 è pagato solo da chi ne ha bisogno. Confondere i tre livelli è il modo più comune di scrivere una skill costosa e poco usata.

## 3. Riferimenti a un solo livello di profondità

### Regola
Tutti i file di supporto devono essere linkati **direttamente da `SKILL.md`**.

### Perché
Quando incontra un riferimento annidato (file → file → file), il modello tende a fare anteprime parziali invece di leggere per intero, e ottiene informazioni incomplete.

### Esempio corretto
```markdown
**Uso base**: [istruzioni inline in SKILL.md]
**Feature avanzate**: vedi [advanced.md](advanced.md)
**Reference API**: vedi [reference.md](reference.md)
```

### Anti-esempio
```markdown
# SKILL.md → vedi advanced.md
# advanced.md → vedi details.md
# details.md → qui c'è l'informazione vera
```

## 4. Naming

### Regola
- Vincoli di validazione del campo `name`: **massimo 64 caratteri**, solo **minuscole, cifre e trattini**, nessun tag XML, **nessuna parola riservata** (`anthropic`, `claude`).
- Applica gli stessi vincoli al **nome della directory**: è quello che diventa il comando `/nome` ed è ciò che rende la skill portabile fuori da Claude Code.
- Forma preferita: **gerundio** (`processing-pdfs`, `analyzing-spreadsheets`, `writing-documentation`).
- Alternative accettabili: frase nominale (`pdf-processing`) o imperativa (`process-pdfs`).
- Vieta: nomi vaghi (`helper`, `utils`, `tools`), nomi troppo generici (`documents`, `data`, `files`), pattern incoerenti dentro la stessa collezione.

### Perché
Il nome è il primo segnale di scoperta e l'unico modo in cui l'utente invoca la skill a mano. Una collezione con naming coerente si naviga; una con `helper` e `utils` si dimentica.

## 5. La description decide se la skill esiste davvero

`description` è il campo su cui il modello decide **se attivare la skill**, scegliendo tra potenzialmente centinaia di alternative. È l'unica parte sempre in contesto.

### Regola
- Deve dire **cosa fa la skill E quando usarla**. Entrambe le cose, sempre.
- **Sempre in terza persona.** La description viene iniettata nel system prompt: la prima o la seconda persona creano incoerenza di punto di vista e degradano la scoperta.
- **Specifica e ricca di termini chiave**: nomina domini, formati, estensioni, framework, tool e frasi che l'utente pronuncerebbe davvero.
- **Il caso d'uso principale va per primo**: l'elenco delle skill viene troncato (in Claude Code il testo combinato `description` + `when_to_use` è tagliato a 1.536 caratteri, e il budget complessivo dell'elenco può accorciarlo ancora). Ciò che sta in fondo può non arrivare mai al modello.
- Limite duro del campo: **massimo 1.024 caratteri**, non vuoto, nessun tag XML.
- Se una skill **non si attiva**, il primo sospetto è sempre la description, non le istruzioni.

### Esempio corretto
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

### Anti-esempio
```yaml
description: Helps with documents
```
```yaml
description: I can help you process Excel files
```

## 6. Concisione: il contesto è un bene comune

### Regola
- **Assumi che il modello sia già molto intelligente.** Aggiungi solo il contesto che non ha già.
- Per ogni paragrafo chiediti: «serve davvero? posso assumerlo noto? questo testo giustifica il suo costo in token?».
- Scrivi **cosa fare**, non narrazioni sul come e sul perché.
- Il corpo di una skill, una volta invocata, **resta in contesto per tutta la sessione**: ogni riga è un costo ricorrente, non un costo una volta sola.

### Esempio corretto (~50 token)
````markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

### Anti-esempio (~150 token)
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available, but pdfplumber is
recommended because it's easy to use...
```

## 7. Gradi di libertà proporzionati alla fragilità

Calibra la specificità sulla fragilità e sulla variabilità del compito.

| Libertà | Quando | Forma |
|---------|--------|-------|
| **Alta** | più approcci validi, la decisione dipende dal contesto | istruzioni testuali, euristiche |
| **Media** | esiste un pattern preferito, qualche variazione è accettabile | pseudocodice o script parametrizzati |
| **Bassa** | operazioni fragili, consistenza critica, sequenza obbligata | script esatto, «esegui esattamente questo, non aggiungere flag» |

### Perché
Immagina il modello come un robot su un percorso. **Ponte stretto con precipizi ai lati**: una sola via sicura, servono guardrail e comandi esatti (migrazione di database). **Campo aperto senza ostacoli**: molte vie portano al risultato, dai la direzione e fidati (code review, dove il contesto decide l'approccio).

## 8. Workflow, checklist e feedback loop

### Regola
- Per compiti complessi, dai **passi sequenziali numerati**, non un paragrafo descrittivo.
- Per workflow multi-step, fornisci una **checklist copiabile** che il modello spunta man mano.
- Per compiti dove la qualità conta, chiudi il ciclo: **esegui → valida → correggi → ripeti**, con un «procedi solo quando la validazione passa».
- Il «validatore» non deve essere necessariamente uno script: può essere un file di reference contro cui confrontarsi (uno style guide, una checklist).
- Se un workflow diventa lungo o ramificato, **spostalo in un file dedicato** e di' al modello quale leggere in base al caso.

### Esempio corretto
````markdown
## Processo di revisione contenuti

Copia questa checklist e spunta man mano:

```
- [ ] 1. Bozza secondo STYLE_GUIDE.md
- [ ] 2. Verifica coerenza terminologica
- [ ] 3. Correggi i rilievi trovati
- [ ] 4. Ripeti il punto 2
- [ ] 5. Finalizza solo quando tutti i requisiti sono soddisfatti
```
````

### Perché
I passi espliciti impediscono di saltare la validazione critica, che è esattamente il passo che si salta quando le istruzioni sono vaghe.

## 9. Pattern comuni

- **Template**: fornisci il formato di output atteso. Distingui i casi rigidi («usa SEMPRE esattamente questa struttura») da quelli flessibili («questo è un default sensato, adatta al contesto»).
- **Esempi input/output**: quando la qualità dipende dal *vedere* lo stile (messaggi di commit, formati di risposta), dai 2-3 coppie concrete. Gli esempi comunicano stile e livello di dettaglio meglio di qualunque descrizione.
- **Workflow condizionale**: se il compito si dirama, esplicita il punto di decisione («Stai creando contenuto nuovo? → workflow A. Stai modificando esistente? → workflow B»).

## 10. Terminologia coerente e nessuna informazione a scadenza

### Regola
- **Un concetto, un termine**, usato identico in tutta la skill. Non alternare «campo», «box», «elemento», «controllo».
- **Niente informazioni datate.** Non «se stai lavorando prima di agosto 2025 usa la vecchia API».
- Se serve contesto storico, isolalo in una sezione «Pattern superati» in fondo, così non inquina il contenuto attivo.

## 11. Skill con script eseguibili

Applicabile solo se la skill include codice eseguibile.

### Regola
- **Risolvi, non delegare**: gli script gestiscono gli errori invece di fallire lasciando il problema al modello (file mancante → crealo con un default e dillo, non `open()` che esplode).
- **Nessuna costante voodoo**: ogni valore di configurazione va motivato in un commento. Se non sai perché il timeout è 47, come dovrebbe saperlo il modello?
- **Dichiara esplicitamente l'intento**: «esegui `analyze_form.py` per estrarre i campi» (eseguire) oppure «vedi `analyze_form.py` per l'algoritmo di estrazione» (leggere come reference). Per le utility, l'esecuzione è preferibile: è più affidabile e non consuma contesto.
- **Preferisci script a codice generato** per le operazioni deterministiche: più affidabili, più veloci, consistenti, e il loro codice non entra in contesto.
- **Dichiara le dipendenze**: non assumere che un pacchetto sia installato. Indica il comando di installazione.
- **Tool MCP sempre con nome completamente qualificato**: `BigQuery:bigquery_schema`, non `bigquery_schema`. Senza il prefisso del server il tool può non essere trovato.
- **Output intermedi verificabili** per operazioni batch o distruttive: pattern `analizza → genera un file di piano → valida il piano → esegui → verifica`. Gli errori si intercettano prima di applicare le modifiche.
- Messaggi di errore dei validatori **verbosi e specifici**: «Campo 'signature_date' non trovato. Campi disponibili: customer_name, order_total, signature_date_signed».

### Vincoli d'ambiente da conoscere
- **Claude Code**: accesso completo alla rete; sconsigliata l'installazione globale di pacchetti (installa in locale, non sporcare la macchina dell'utente).
- **Claude API**: nessun accesso alla rete, nessuna installazione di pacchetti a runtime, solo dipendenze pre-configurate.
- **claude.ai**: accesso alla rete variabile secondo le impostazioni utente/admin.

Una skill scritta per Claude Code che scarica dalla rete **non funziona** sull'API. Se la skill deve essere portabile, dichiaralo o evita la dipendenza.

## 12. Controllo dell'invocazione

Per impostazione predefinita sia l'utente sia il modello possono invocare una skill. Due campi cambiano questo (dettagli completi in [reference/frontmatter.md](reference/frontmatter.md)):

- **`disable-model-invocation: true`** — solo l'utente. Obbligatorio per workflow con effetti collaterali o timing critico: commit, deploy, invio messaggi. Rimuove anche la description dal contesto.
- **`user-invocable: false`** — solo il modello. Per conoscenza di background che non è un'azione sensata da digitare (`legacy-system-context`).
- **`context: fork`** — esegue la skill in un subagent isolato, senza la cronologia di conversazione. Ha senso **solo per skill con istruzioni azionabili**: una skill di sole convenzioni forkata riceve linee guida e nessun compito, e torna senza risultato utile.

### Regola in revisione
Una skill che deploya, committa o manda messaggi **senza** `disable-model-invocation: true` è un rilievo di gravità alta, non stilistico.

## 13. Ciclo di vita del contenuto (Claude Code)

Fatti che cambiano come si scrive il corpo:
- Il contenuto renderizzato entra in conversazione **una volta** e **ci resta** per il resto della sessione. Il file non viene riletto ai turni successivi.
- Quindi: scrivi le regole che devono valere per tutto il compito come **istruzioni permanenti**, non come passi una volta sola («quando modifichi un file di questo tipo, verifica sempre X» invece di «adesso verifica X»).
- L'auto-compattazione riattacca la **invocazione più recente di ogni skill**, tenendo i primi 5.000 token di ciascuna, con un budget complessivo di 25.000 token partendo dalle più recenti: le skill invocate molto tempo prima possono sparire. Se una skill lunga sembra «smettere di funzionare» dopo una compattazione, va reinvocata.
- Un `allowed-tools` vale **solo per il turno** che invoca la skill, non per la sessione.

## 14. Sicurezza

### Regola
- Usa e installa skill **solo da fonti fidate**: proprie o Anthropic. Una skill può indirizzare il modello a invocare tool ed eseguire codice in modi che non corrispondono al suo scopo dichiarato.
- In revisione di una skill non tua, **audita tutti i file** del bundle: SKILL.md, script, risorse. Cerca chiamate di rete inattese, accessi a file fuori scopo, operazioni che non c'entrano con la funzione dichiarata.
- Attenzione particolare alle skill che **recuperano dati da URL esterni**: il contenuto scaricato può contenere istruzioni malevole, e una dipendenza esterna oggi affidabile può cambiare domani.
- Una skill di progetto con `allowed-tools` può concedersi accesso ampio ai tool: va letta **prima** di accordare fiducia al repository.
- Trattala come l'installazione di un software, non come la lettura di un documento.

## 15. Modificare una skill esistente: prima la copertura, poi la forma

Creare e modificare non sono la stessa attività. Su una skill che esiste già — compattazione, deduplicazione, riorganizzazione — il rischio dominante non è la forma sbagliata, è la **regola persa senza accorgersene**. Tutti i controlli di forma passano comunque, la perdita non produce nessun sintomo, e si scopre solo al giro di revisione successivo.

### Regola
Prima di dichiarare finita una modifica, esegui **entrambi** i controlli, nello stesso passaggio:

1. **Copertura** — elenca le regole normative della versione **precedente**, una per una, e verifica che ognuna sia presente in quella nuova. Una regola può sparire solo se **dichiari** all'utente che l'hai rimossa e perché.
2. **Forma** — i controlli meccanici su frontmatter, description, link, path e righe: comandi pronti in [reference/controlli-di-forma.md](reference/controlli-di-forma.md).

Distingui **regola normativa** (fissa un limite, un divieto, un obbligo, un caso da trattare) da **prosa di supporto** (ripetizioni, esempi ridondanti, incoraggiamenti, spiegazioni dell'ovvio). Le prime si conservano o si dichiarano perse; le seconde si tagliano liberamente, e sono il vero margine di compattazione. Se la riduzione di righe viene solo dalle prime, non stai compattando: stai sottraendo.

### Deduplicare tra due skill: le regole di confine
Quando togli una regola da una skill perché «l'altra la copre già»:

- **leggi la skill di destinazione** e verifica che copra davvero *tutta* la voce, non una parte;
- se la voce sta a cavallo dei due ambiti (metà formato e metà valore, metà cosa e metà quando), **spezzala**: una metà resta, l'altra si delega. Non spostarla intera;
- dopo lo spostamento, togli dalla skill di partenza i rinvii che ora contraddicono la regola rimasta.

Una voce che nessuna delle due skill copre più è il difetto tipico della deduplicazione, e nessun controllo di forma lo trova.

### Perché
Compattare misura il volume, la copertura misura il contenuto. Chi guarda solo il volume conclude «finito» con tre regole in meno e ha bisogno di un secondo giro per accorgersene. I due controlli costano un passaggio; saltarli costa un ciclo intero di revisione.

# Workflow di creazione: prima le valutazioni

**Costruisci le valutazioni PRIMA di scrivere documentazione estesa.** Serve a risolvere problemi reali, non problemi immaginati.

1. **Identifica il gap** — fai svolgere il compito rappresentativo *senza* skill e annota i fallimenti concreti e il contesto che hai dovuto fornire a mano.
2. **Crea le valutazioni** — almeno **tre** scenari che coprono quei gap.
3. **Misura la baseline** — le prestazioni senza la skill.
4. **Scrivi il minimo indispensabile** — solo il contenuto che chiude i gap e passa le valutazioni.
5. **Itera** — riesegui, confronta con la baseline, raffina.

Dettaglio del formato delle valutazioni, del ciclo di iterazione e dei segnali da osservare: [reference/evaluation.md](reference/evaluation.md).

# Checklist di CREAZIONE di una nuova skill
- [ ] Esiste un **gap reale**, osservato: cosa fallisce oggi senza questa skill?
- [ ] Il contenuto merita di essere una skill, e non una riga di CLAUDE.md (fatto) o un subagent (contesto isolato)
- [ ] Nome directory in kebab-case, ≤64 caratteri, senza parole riservate, preferibilmente gerundio
- [ ] `name` del frontmatter coerente col nome della directory
- [ ] `description` in terza persona che dice **cosa fa E quando usarla**, con termini chiave e caso principale per primo
- [ ] Corpo **sotto le 500 righe**, conciso, senza spiegazioni che il modello già possiede
- [ ] Gradi di libertà calibrati sulla fragilità del compito
- [ ] Workflow complessi come passi numerati, con checklist e feedback loop dove serve
- [ ] File di supporto solo se guadagnati, tutti referenziati da `SKILL.md`, **un solo livello** di profondità
- [ ] Indice dei contenuti nei file di reference oltre 100 righe
- [ ] Terminologia coerente, zero informazioni a scadenza, path con slash in avanti
- [ ] `disable-model-invocation: true` se la skill ha effetti collaterali
- [ ] Se ha script: errori gestiti, costanti motivate, dipendenze dichiarate, intento eseguire/leggere esplicito
- [ ] Almeno tre valutazioni scritte, testate in una **sessione nuova** (non quella dove hai scritto la skill)
- [ ] Testata sui modelli che userai davvero: sufficiente per Haiku, non ridondante per Opus

# Checklist di REVISIONE di una skill esistente
Separa i rilievi per gravità. Se stai revisionando una **modifica che hai appena fatto tu**, passa prima il controllo di copertura della sezione 15: questa checklist giudica la skill per come è, non ciò che è andato perso per strada.

**Gravità alta — la skill non funziona o è rischiosa**
- [ ] `description` assente, vaga, in prima/seconda persona, o priva del «quando usarla»
- [ ] `name` fuori validazione (maiuscole, underscore, >64 caratteri, parole riservate) o divergente dalla directory
- [ ] Effetti collaterali (deploy, commit, invii) senza `disable-model-invocation: true`
- [ ] `allowed-tools` più ampio del necessario
- [ ] Riferimenti a file annidati oltre un livello, o file di supporto mai citati da `SKILL.md`
- [ ] Path in stile Windows, tool MCP senza prefisso del server, dipendenze assunte come installate
- [ ] Collisione di nome che maschera silenziosamente un'altra skill (ricorda: personale batte progetto)
- [ ] Contenuto o script che fanno cose fuori dallo scopo dichiarato

**Gravità media — costa più di quanto vale**
- [ ] Corpo oltre le 500 righe, o contenuto di reference che dovrebbe stare in un file separato
- [ ] Spiegazioni di cose che il modello già sa; testo che non giustifica il proprio costo in token
- [ ] Caso d'uso principale non in testa alla description (rischio troncamento)
- [ ] Gradi di libertà sbagliati: istruzioni vaghe su operazioni fragili, o script rigidi dove serve giudizio
- [ ] Workflow complesso senza passi numerati; operazione critica senza loop di validazione
- [ ] Terminologia incoerente; informazioni a scadenza fuori da una sezione «pattern superati»
- [ ] Istruzioni scritte come passi una volta sola, quando dovrebbero valere per tutta la sessione
- [ ] `context: fork` su una skill di sole linee guida, senza compito azionabile

**Gravità bassa — rifiniture**
- [ ] Naming fuori dal pattern della collezione (gerundio vs frase nominale mescolati)
- [ ] Esempi astratti dove servirebbero coppie input/output concrete
- [ ] File di reference oltre 100 righe senza indice
- [ ] Troppe alternative offerte senza un default

# Anti-pattern
- **Description muta**: «Helps with documents». La skill esiste sul disco e non nel mondo.
- **Prima persona**: «I can help you process Excel files». Rompe la coerenza del system prompt.
- **Manuale monolitico**: 900 righe in `SKILL.md` invece di un indice più tre file di reference.
- **Riferimenti a catena**: SKILL.md → advanced.md → details.md. Il modello legge a metà.
- **Path Windows**: `scripts\helper.py` rompe su sistemi Unix.
- **Troppe opzioni**: «puoi usare pypdf, o pdfplumber, o PyMuPDF, o pdf2image…». Dai un default e, se serve, una via d'uscita per il caso particolare.
- **Costanti voodoo**: `TIMEOUT = 47`. Perché 47?
- **Deferire al modello**: script che fallisce e lascia che «il modello si arrangi».
- **Skill onnicomprensiva**: se copre tre domini indipendenti, sono tre skill, o una skill con tre file di reference per dominio.
- **Testarla nella sessione in cui l'hai scritta**: il contesto residuo maschera esattamente i buchi che vuoi trovare.
- **Compattare a volume**: tagliare finché il file è corto, senza confrontare le regole prima e dopo. Il giro successivo le ritrova, e quel giro è tempo perso due volte.
- **Delega a scatola chiusa**: spostare una regola in un'altra skill dando per scontato che la copra, senza aprirla.
- **Dichiarare finito dopo i soli controlli di forma**: passano anche su una skill a cui hai tolto tre regole.

# Vincoli
- Non violare i vincoli di validazione di `name` e `description`.
- Non lasciare una skill senza description sperando che il modello capisca dal corpo.
- Non superare le 500 righe nel corpo di `SKILL.md`: spostare, non comprimere.
- Non annidare i riferimenti tra file oltre un livello da `SKILL.md`.
- Non usare path in stile Windows.
- Non inserire informazioni a scadenza fuori da una sezione dedicata ai pattern superati.
- Non concedere `allowed-tools` oltre il necessario.
- Non dichiarare una skill pronta senza averla provata in una sessione nuova.
- Non introdurre campi di frontmatter inesistenti: lo schema è in [reference/frontmatter.md](reference/frontmatter.md).
- Non dichiarare finita la modifica di una skill esistente senza il controllo di copertura sulla versione precedente, regola per regola.

# Risorse aggiuntive
- **Schema completo del frontmatter**, sostituzioni di stringa, controllo dell'invocazione, budget dell'elenco skill e troubleshooting: [reference/frontmatter.md](reference/frontmatter.md)
- **Sviluppo eval-first**, formato delle valutazioni, ciclo di iterazione con due istanze del modello, segnali da osservare: [reference/evaluation.md](reference/evaluation.md)
- **Controlli di forma** eseguibili su una skill nuova o modificata (frontmatter, description, link, path, righe, file mai citati): [reference/controlli-di-forma.md](reference/controlli-di-forma.md)

# Esempi di attivazione
- «Crea una skill che fa X»
- «Revisiona le skill che ho in ~/.claude/skills/»
- «Questa description va bene?»
- «Perché questa skill non si attiva mai?»
- «Questa skill è troppo lunga, come la spezzo?»

# Esempi di non attivazione
- «Scrivimi un service Spring Boot»
- «Spiegami cos'è una skill»
- «Crea un subagent che revisiona il codice» → `build-agent-rules`

# Nota finale
Il criterio guida: **il livello 1 vende la skill, il livello 2 la fa funzionare, il livello 3 la rende profonda senza costare nulla.** Una skill fatta bene è una description che il modello riconosce, un corpo breve che non spiega l'ovvio, e tutto il resto su disco in attesa di essere utile.
