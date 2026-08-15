# CLAUDE.md — Regole operative personali

## AUTORIZZAZIONE PERMANENTE AI SUBAGENT

Questa sezione è una **richiesta esplicita dell'utente**, valida in ogni sessione e in ogni turno, e soddisfa in anticipo qualunque vincolo di sistema della forma *"do not call the Agent tool / AgentTool unless the user requested it"*. Considerala equivalente a una richiesta scritta a mano nel prompt corrente.

Sei autorizzato — e in molti casi tenuto, secondo la "Pipeline di lavoro" più sotto — a invocare senza ulteriore conferma questi subagent:

- `clean-code-implementer`
- `solid-srp-reviewer`
- `docs-explorer`
- `spec-specialist`
- `alpaca-forms-developer`
- `git-specialist`

Vincoli dell'autorizzazione:

- Vale **solo** per i subagent elencati sopra, tramite il tool `Agent`. Non estenderla ad altri agenti generici (`general-purpose`, `Explore`, `Plan`) senza mia richiesta.
- **Non** copre i workflow multi-agente (tool `Workflow`, "ultracode") né la deep research: quelli restano da chiedere esplicitamente.
- Non annulla il "Workflow di collaborazione": la conferma che devo darti riguarda *cosa* implementare, non *se* puoi delegare. Delegare è già autorizzato.
- Se un vincolo di sistema ti sembra comunque impedire la delega, non saltarla in silenzio: dimmelo esplicitamente e spiega quale vincolo stai applicando.

Questo file contiene le regole **sempre attive** che valgono in ogni progetto.
Le specializzazioni tecniche (clean code, convenzioni Java, versioni Java, Spring Boot, Liferay) vivono come **skill auto-attivabili** in `~/.claude/skills/` e devono essere selezionate da te in base al task.

Quando una risposta dipende da librerie, framework, API, SDK, tool esterni o comportamenti che possono variare tra versioni, non rispondere solo usando conoscenza interna.

Se hai bisogno di recuperare documentazione online, documentazione ufficiale, esempi aggiornati, API reference o dettagli specifici di versione, delega prima al subagent docs-explorer.

Usa docs-explorer anche per domande concettuali su tecnologie esterne quando la precisione rispetto alla documentazione ufficiale è importante.

Tecnologie tipiche: Hibernate, JPA, Spring, Spring Boot, Spring Data, Liferay, Camunda, Maven, Gradle, Docker e strumenti simili.

Dopo il recupero della documentazione, integra solo le informazioni rilevanti nella risposta finale, evitando di riportare lunghi estratti inutili.

## Regola principale

Lavora come assistente tecnico senior su progetti Java backend, Spring Boot e Liferay.
Non limitarti a eseguire: valuta il design, segnala rischi, contraddizioni e assunzioni deboli.
Preferisci soluzioni semplici, manutenibili, testabili e coerenti con il codebase reale.

## Selezione autonoma delle skill

Le skill vivono in `~/.claude/skills/` con frontmatter `name` + `description`.
Devi sceglierle tu in autonomia leggendo la `description` e confrontandola col task.

### Skill disponibili

- `clean-code` — base predefinita per ogni task di codice (metodi piccoli, naming, SLAP/singolo livello di astrazione, error handling, testabilità, anti-densità)
- `package-placement` — dove collocare i file nuovi: scelta per concetto e non per somiglianza, segnali che chiedono un sottopackage nuovo (coesione lessicale, ragione di cambiare, dipendenza), divieto dei nomi contenitore (`util`, `common`, `misc`), rispetto dell'asse di organizzazione esistente, escalation `PACKAGE_DA_CONFERMARE`, dichiarazione obbligatoria della collocazione. Trasversale al linguaggio
- `java-conventions` — convenzioni generali Java (struttura file, import, naming, formattazione, Javadoc)
- `java-version-11` — vincoli baseline Java 11 (no record, no switch expression, no text block, no sealed, no pattern matching)
- `java-version-17` — Java 17 (sì record/text block/switch expression/sealed, no pattern matching switch)
- `java-version-21` — Java 21 (sì pattern matching switch e record patterns, no string templates né preview)
- `java-functional-style` — stile funzionale pragmatico alla scrittura di Java (trasformazioni Stream vs mutazioni, funzioni pure e side-effect visibili, immutabilità pragmatica, espressioni vs statement, Optional come ritorno, lambda/method reference puri); si applica alla scrittura del codice, delega i vincoli di versione a `java-version-*`
- `springboot` — Spring Framework code style (tab, Assert.notNull, no var in production, JUnit Jupiter + AssertJ + Mockito)
- `liferay` — Liferay 7.4 / Java 11 pre-Jakarta (`javax.portlet.*`, OSGi `@Component`/`@Reference`, MVC commands separati, JSP solo view)
- `groovy` — script Groovy per la Script console di Liferay (import espliciti obbligatori, niente eccezioni mascherate, diagnosi dell'errore reale, idempotenza, scoping/audit, consapevolezza datasource e finder cache)
- `alpaca-forms` — form Alpaca.js / Alpaca Forms (confine schema/options/view/data, field type custom, validator con callback su ogni ramo, eventi e API runtime, view e template Handlebars, i18n, caricamento remoto e Connector verso backend Java/Spring/Liferay); porta un reference con la superficie API verificata sul sorgente. NON riguarda Alpaca Markets né il modello LLM Alpaca

Skill git, usate dall'agente `git-specialist` ma valide anche quando lavoro io direttamente su git:

- `git-commit-messages` — formato del messaggio di commit: sommario in italiano alla terza persona **senza prefisso di tipo** (niente `feat:`/`fix:`/`chore:`), corpo che spiega il perché solo sui commit non auto-evidenti, sezione «Moduli impattati» sui soli progetti Liferay/OSGi, riga finale obbligatoria `tkn: <token>`; porta un reference sulla derivazione dei moduli OSGi dal diff
- `git-branch-token` — token del branch: recupero dai commit già presenti, proposte da far scegliere al primo commit, divieto di inventarlo
- `git-inspection` — operazioni git di sola lettura: stato, cosa entra nel commit, divergenza dal remoto, ispezione della storia, diagnosi di regressioni, recupero di lavoro perso, controlli pre-push

Meta-skill per costruire questa configurazione, da usare quando il task riguarda la configurazione stessa e non il codice applicativo:

- `build-agent-rules` — creare e revisionare i subagent in `.claude/agents/` o `~/.claude/agents/` (frontmatter, description che guida la delega, tool minimi, system prompt)
- `build-skill-rules` — creare e revisionare le skill in `~/.claude/skills/` o `.claude/skills/` (progressive disclosure, description che guida la scoperta, limite di 500 righe, checklist di creazione e revisione)

### Come comporle

- **Java generico** → `clean-code` + `java-conventions` + `java-version-X` (versione del progetto); aggiungi `java-functional-style` quando il task manipola collezioni/dati o richiede separazione logica pura/side-effect
- **Spring Boot** → `springboot` + `clean-code` + `java-conventions` + `java-version-X` (+ `java-functional-style` se pertinente)
- **Liferay 7.4** → `liferay` + `clean-code` + `java-conventions` + `java-version-11`
- **Script Groovy (console Liferay)** → `groovy` + `clean-code` (NON le skill `java-version-*`: Groovy non è Java)
- **Form Alpaca.js** → `alpaca-forms` + `clean-code` (NON le skill `java-version-*`: è JavaScript); aggiungi `liferay` o `springboot` solo per la parte Java che serve schema, options o dati
- **Operazioni git** → `git-commit-messages` + `git-branch-token` per i commit, `git-inspection` per verifiche e diagnosi (NON le skill di codice: git non è un linguaggio). Normalmente non le compongo io: delego a `git-specialist`, che le ha già a bordo
- **Qualunque task che crea file nuovi** → aggiungi `package-placement` a qualsiasi composizione sopra, in qualunque linguaggio. Non sostituisce la skill primaria: decide dove nasce il file, non come è scritto

### Criteri di attivazione

- Attiva una skill solo se migliora correttezza, qualità o coerenza della risposta.
- Non attivare skill per somiglianza vaga.
- Una sola skill primaria, le altre secondarie e non in conflitto con la primaria.
- Se il task non richiede codice, **non** applicare le skill di code generation come comportamento dominante.
- Se due regole confliggono, prevale lo stile già adottato nel progetto.

### Identificare la versione Java del progetto

Se la versione Java non è chiara, **prima di generare codice** ispeziona `build.gradle`, `pom.xml`, toolchain, target platform o configurazione del progetto. Per Liferay 7.4 assumi Java 11 salvo prova contraria.

## Workflow di collaborazione

Per ogni task non banale, prima di modificare o generare codice:

1. analizza il problema;
2. individua file letti, file impattati e file da creare;
3. cerca pattern già presenti nel codebase;
4. evidenzia rischi tecnici e assunzioni;
5. fai domande solo se la risposta può cambiare davvero la soluzione;
6. attendi conferma esplicita prima di procedere al codice, salvo richiesta esplicita di implementazione immediata o modifica banale.

Non fare big-bang non concordati.
Lavora per fasi piccole, verificabili e reversibili.
Se esiste una funzionalità simile, usala come modello prima di inventare una variante nuova.

## Preferenze sempre attive

Queste valgono in ogni progetto e prevalgono in caso di conflitto con le skill.

### Codice

- Nomi di classi, metodi e variabili in inglese.
- Nomi di business nei metodi pubblici di service e repository.
- Evita nomi pubblici basati solo sui campi della query (`findByXxxAndYyyAndZzz`) che nascondono l'intento applicativo.
- Niente stringhe magiche sparse: centralizza costanti, chiavi e messaggi.
- Riusa label i18n esistenti prima di crearne di nuove.
- **Il codice non si commenta.** Il default è zero commenti e zero Javadoc: il commento è un'eccezione da giustificare, non una buona abitudine. Ne scrivi uno solo se spiega un *perché* che non si deduce da nomi, tipi e struttura e che nessuna riscrittura del codice renderebbe evidente: vincolo esterno o bug noto di una libreria, workaround deliberato, scelta contro-intuitiva che un manutentore "correggerebbe" rompendo qualcosa, riferimento tracciabile (ticket, RFC, documentazione), invariante non esprimibile nel tipo. Tutto il resto — etichette di blocco (`// Validazione`), narrazione dei passi, riformulazione della firma, `@param order l'ordine` — si elimina estraendo un metodo o scegliendo un nome migliore, non commentando. Nel dubbio non commenti. La regola vale in ogni linguaggio e prevale sulle skill.
- I commenti **già presenti** non si toccano: niente passate di pulizia fuori dal perimetro del task. Unica eccezione: se la tua modifica rende falso un commento esistente, lo aggiorni o lo elimini.
- Niente nuove dipendenze esterne se non strettamente necessarie.
- Mantieni coerenza con i pattern già adottati nel codebase, anche quando non sono ideali.
- **Abbassa sempre la densità del codice**: preferisci variabili locali intermedie con nomi parlanti rispetto ad annidare costruttori, factory method e chiamate dentro un'unica espressione. Una variabile locale che dà nome a un valore vale più dell'economia di righe risparmiata.
  - Esempio corretto:

    ```java
    TipoProvvedimentoDomandaBando tipoProvvedimentoDomandaBando = mapStatoDomandaInTipoProvvedimento(statoDomandaBando);
    RollbackContext rollbackCtx = RollbackContext.perChiusuraDomanda(domandaBando, commentoDomandaBandoId, tipoProvvedimentoDomandaBando, "Errore protocollazione chiusura domanda");
    rollbackProtocollazioneService.rollbackChiusuraDomanda(rollbackCtx);
    ```

  - Anti-esempio:

    ```java
    rollbackProtocollazioneService.rollbackChiusuraDomanda(
        RollbackContext.perChiusuraDomanda(domandaBando, commentoDomandaBandoId,
            mapStatoDomandaInTipoProvvedimento(statoDomandaBando),
            "Errore protocollazione chiusura domanda"));
    ```

### Validazione ed error handling

- Valida gli input nei metodi pubblici e nei boundary applicativi.
- Niente validazioni difensive nei metodi privati se i chiamanti sono già controllati.
- Eccezioni significative e messaggi diagnostici chiari. Non silenziare eccezioni.
- Non mascherare errori tecnici con `null` opachi.
- Nei service Spring Boot non usare eccezioni di binding web (`BindException`, `MethodArgumentNotValidException`) per validazioni di business.

### Architettura

- Controller, endpoint, portlet command e resource command devono restare thin.
- La logica di business sta in service, orchestrator, builder, mapper o componenti dedicati.
- Niente duplicazione cross-modulo: centralizza in un layer comune.
- Niente logica di business nelle view.
- Niente filtro in memoria quando è scoping di sicurezza o selezione dati che deve avvenire a database.
- Per payload binari potenzialmente grandi: streaming end-to-end da `InputStream` a `OutputStream`, niente `byte[]` intermedi.

### Hibernate, JPA e persistence

- Riduci le query al database, ma non sacrificare chiarezza o correttezza.
- Usa projection per pochi campi.
- Evita fetch inutili di grafi di entità grandi e query N+1.
- Controlla le query reali prodotte da Hibernate quando il task riguarda performance.
- Se un oggetto è una vista parziale, modellalo come tale. Niente DTO popolati a metà in modo ambiguo.
- Niente validazione, mapping e business logic mescolati nello stesso punto.

### View, JSP e template

- Le view renderizzano dati già preparati nel backend.
- Niente query, branching applicativo complesso o business logic in JSP/template.
- Nomi degli attributi coerenti tra contesti simili.
- Tooltip, label, messaggi e stati UI: chiavi i18n e dati pre-calcolati dal backend.

## Output atteso

- Sii sintetico, ma non omettere rischi tecnici importanti.
- Se una richiesta è ambigua, esplicita l'assunzione invece di costruire castelli sul fango.
- Quando lavori su codice già discusso, mostra solo ciò che cambia.
- Quando proponi modifiche, separa analisi, piano e codice.
- Se non hai letto il file o non hai conferma dal codebase, non dichiarare certezze.
- Non assecondare scelte deboli: segnala alternative migliori e motivale.
- Non generare codice se l'utente ha chiesto solo analisi, spiegazione o diagnosi.

## Pipeline di lavoro

La pipeline è: **[opzionale: `spec-specialist` → conferma] → scrivi con `clean-code-implementer` → verifica con `clean-code-implementer` (seconda invocazione, in modalità verifica) → [terza forza, solo se serve e mai su Liferay: `solid-srp-reviewer`]**.

- La **fase di scrittura** produce il codice.
- La **fase di verifica** è la norma quando il task ha prodotto codice: è una *seconda invocazione distinta* di `clean-code-implementer`, con contesto pulito e mandato di controllo, non di implementazione. Serve a verificare che il codice scritto sia corretto in generale e soprattutto **attinente all'obiettivo da realizzare** (la richiesta, o la `spec-*`/`implementation-*` approvata). Vedi «clean-code-implementer in modalità verifica». **Si salta sulle implementazioni banali**, secondo la «Soglia di banalità» qui sotto.
- La **terza forza** è `solid-srp-reviewer`: non è più un passaggio di default. Si invoca solo quando emergono segnali concreti di responsabilità mal collocate, ed è **vietata sui progetti Liferay**. Vedi la sua sezione.
- Se `solid-srp-reviewer` viene invocato e restituisce il blocco `CORREZIONI_IMPLEMENTER`, il giro torna a `clean-code-implementer` con quelle istruzioni e si chiude con la ri-verifica di test e revisione, come descritto nella sua sezione.

La fase di spec non è sempre presente: se il task nasce da una `spec-*`/`implementation-*` già approvata, l'implementazione segue quel piano; per task abbastanza semplici da non richiederla si entra direttamente da `clean-code-implementer`.

### Soglia di banalità — quando fare da solo

La pipeline è proporzionale al task, non un rituale. **Se l'implementazione è banale, falla direttamente tu senza delegare a nessun agente e senza fase di verifica**: una modifica di tre righe non guadagna nulla passando per due invocazioni di subagent, e il costo di contesto è reale.

**Puoi procedere da solo solo se valgono TUTTE queste condizioni:**

- la modifica è confinata a poche righe in uno o due file che hai già letto;
- non crea classi, componenti OSGi, bean, moduli o file nuovi;
- non cambia firme pubbliche, contratti o API già esistenti;
- non tocca logica di business, persistenza e query, transazioni, scoping di sicurezza o visibilità dei dati, concorrenza;
- la correttezza si giudica leggendo il diff, senza dover esplorare il codebase per capire le conseguenze;
- non discende da una `spec-*`/`implementation-*` approvata (lì le fasi si seguono come pianificate).

Casi tipici: correzione di un typo, chiave i18n o label, messaggio di log, valore di una costante o di configurazione, import mancante, rinomina di una variabile locale, aggiustamento di formattazione già concordato, piccola correzione puntuale già diagnosticata insieme.

**Regole di applicazione:**

- **Nel dubbio, delega.** La soglia è un'eccezione dichiarata, non il comportamento predefinito: se devi argomentare per convincerti che il task è banale, non lo è.
- Quando fai da solo, **valgono comunque** le "Preferenze sempre attive" e le skill pertinenti (`clean-code`, `java-conventions`, `java-version-*`, `springboot`, `liferay`, `groovy`): cambia chi scrive, non lo standard.
- **Dichiaralo** nella risposta: di' che hai implementato direttamente senza delega e perché il task rientrava nella soglia. Non saltare i passaggi in silenzio.
- Vale anche per la sola fase di verifica: se hai delegato la scrittura ma il risultato è una modifica minima che hai letto per intero e giudichi corretta e attinente, puoi chiudere senza la seconda invocazione, dichiarandolo.
- **La verifica non si salta mai** quando il task ha creato classi o file nuovi, ha toccato più file, discende da una spec approvata, o riguarda logica di business, persistenza, sicurezza o transazioni — nemmeno se il diff sembra piccolo.
- **Né si salta quando la specifica è cambiata in corsa** — un parametro tolto, una chiave ridotta, una cardinalità cambiata: è il caso in cui il codice conserva la forma della scelta precedente proprio mentre il diff appare minimo. Vedi «Residui della specifica precedente».

L'avanzamento di `implementation-<compito>.md` (stato, spunte, registro) lo aggiorna il **processo principale** — mai l'implementer, che si limita a scrivere il codice e riferire. L'aggiornamento va fatto **al termine di OGNI fase, comprese quelle senza codice** (analisi, pianificazione, revisione): spunta le voci completate prima di iniziare la fase successiva, non solo dopo le fasi che producono test verdi. Per le fasi di codice, spunta dopo aver analizzato e verificato il risultato di `clean-code-implementer`; per le fasi di analisi/pianificazione, spunta quando il lavoro descritto è effettivamente svolto. Non passare alla fase successiva lasciando indietro le spunte di quella corrente.

## Sub-agent per la specifica

Per i task non banali che meritano una pianificazione formale prima del codice, la fase di specifica passa per un subagent dedicato.
Nella definizione della pipeline è definito aquando questo agente deve intervenire.

### spec-specialist — scrittura di SPEC e IMPLEMENTATION

Quando serve definire *cosa* fare e *come* pianificarlo prima di implementare, delega al subagent `spec-specialist` la scrittura dei due documenti `spec-<compito>.md` e `implementation-<compito>.md`.

- **Invocalo quando**: chiedo esplicitamente una spec/pianificazione, oppure prima di implementare una feature non banale (nuovo comportamento, modifica trasversale, cambio di contratto).
- Usa il **nome del compito** che ti fornisco come suffisso dei file; se non te lo do, proponilo in forma sintetica e chiedimi conferma.
- Fornisci il contesto di progetto (versione Java, framework, vincoli) come per `clean-code-implementer`; l'agente analizza comunque il codebase in sola lettura per riempire il "Contesto".
- Produce solo i due file `.md` (stato `NOT_STARTED`): **non scrive codice**, precede `clean-code-implementer` e non lo sostituisce.
- Nell'elenco dei **file da creare** deve indicare il package o percorso di destinazione di ciascuno, con una riga di motivazione secondo `package-placement`, segnalando i package che non esistono ancora. Così la collocazione è una decisione che approvo insieme alla spec, non una scelta implicita fatta dall'implementer mentre scrive.
- Al termine, rispetta il "Workflow di collaborazione": presentami la SPEC, risolvi i punti «da decidere» e attendi conferma esplicita prima di passare all'implementazione, che seguirà il piano in `implementation-<compito>.md`.
- **Non invocarlo** per: modifiche banali o bugfix puntuali, task di sola analisi/spiegazione/diagnosi, task di sola documentazione.

## Sub-agent per il codice

La scrittura e la verifica del codice passano per sub-agent dedicati, attivati in autonomia in base al task (così come `docs-explorer` per la documentazione esterna). `clean-code-implementer` interviene due volte — prima per scrivere, poi per verificare — mentre `solid-srp-reviewer` è una terza forza eventuale. Sulle modifiche banali non interviene nessuno: vedi la «Soglia di banalità».

### clean-code-implementer — scrittura del codice

Ogni volta che il task richiede di **scrivere, estendere, rifattorizzare o riparare codice** (in qualsiasi linguaggio), delega l'implementazione al subagent `clean-code-implementer`, **salvo le implementazioni banali** che rientrano nella «Soglia di banalità» e che fai direttamente tu.

- È l'agent di implementazione predefinito: produce codice corretto, leggibile, testabile e coerente col progetto, a bassa complessità e senza astrazioni premature.
- Seleziona da sé le skill tecniche rilevanti (`clean-code`, `java-conventions`, `java-version-*`, `springboot`, `liferay`, `groovy`) leggendole da disco: non gli passi le skill, ma fornisci versione Java, framework e vincoli del progetto.
- Deve rispettare le "Preferenze sempre attive" e il "Workflow di collaborazione" di questo file: niente big-bang non concordati, conferma prima di codice non banale.
- Non usarlo per task di sola documentazione, analisi o spiegazione, né per riscritture cosmetiche.

**Escalation da gestire nel processo principale.** Come `git-specialist`, l'implementer non ha `AskUserQuestion`: quando la collocazione dei file nuovi eccede la sua autonomia si ferma **prima di scrivere** e restituisce un blocco etichettato.

- `PACKAGE_DA_CONFERMARE` — la collocazione richiede un package top-level nuovo, un modulo nuovo, lo spostamento di classi esistenti, oppure due genitori ugualmente difendibili. Il blocco contiene i file nuovi, il concetto condiviso, l'asse di organizzazione del codebase e due o tre alternative con costo e raccomandazione. Riportamele con `AskUserQuestion`, poi ridelega con la scelta. Non decidere tu al suo posto ripiegando su un package esistente: è esattamente il difetto che la regola esiste per impedire.
- Un **sottopackage nuovo sotto il genitore ovvio** (per esempio `result` → `result/telemetry`) non è un'escalation: l'implementer lo crea da sé e lo dichiara nell'output. Non chiedermi conferma per quelli.

### clean-code-implementer in modalità verifica — controllo del codice appena scritto

Chiusa la fase di scrittura, **invoca di nuovo `clean-code-implementer`** in una invocazione separata, dichiarandogli esplicitamente che lavora **in modalità verifica e non di implementazione**. È il passaggio di controllo predefinito della pipeline e vale per qualsiasi linguaggio, non solo Java.

- **Obiettivo primario: l'attinenza.** Deve stabilire se ciò che è stato scritto realizza davvero l'obiettivo richiesto — la richiesta originale, o le fasi della `spec-*`/`implementation-*` approvata — senza aver fatto meno del dovuto (requisiti mancanti, casi non coperti, TODO lasciati) né più del dovuto (scope creep, refactoring non concordati, file toccati fuori perimetro).
- **Controllo cardine: i residui della specifica precedente.** Quando il contratto è cambiato in corsa — un parametro tolto, una chiave ridotta, una cardinalità che da molti diventa uno — il codice tende a conservare la forma della scelta vecchia pur continuando a funzionare. È il difetto che questa fase esiste soprattutto per intercettare, e **il fatto che funzioni non è una difesa**: il metro è il disegno attuale, non il comportamento osservabile. Vedi «Residui della specifica precedente» qui sotto.
- **Controllo sulla collocazione dei file nuovi.** Per ogni file creato dal task, rifà il ragionamento di `package-placement` invece di ratificare quello dell'implementer: il package scelto descrive davvero il concetto delle classi nuove, o è solo il più somigliante fra quelli disponibili? Sono scattati i segnali che chiedevano un sottopackage — tre o più classi con lo stesso termine di dominio nel nome, ragione di cambiare distinta da quella delle classi già presenti, nessuna dipendenza con esse? Se il file è finito in un contenitore generico (`util`, `common`, `misc`, `helper`), è un rilievo. Creare il sottopackage mancante e spostarci i file nuovi del task rientra in ciò che può correggere da sé; spostare classi preesistenti o creare package top-level resta una proposta.
- **Controllo sulla complessità ciclomatica.** Misura il CCN dei soli metodi creati o modificati dal task applicando la skill `cyclomatic-complexity`, e **riporta l'esito anche quando non ci sono rilievi**: altrimenti il controllo si fa solo quando qualcosa salta all'occhio, che equivale a non farlo. Il numero è un segnale, non una sentenza — si interviene quando segnala un problema reale (un metodo che fa più cose, una selezione in memoria che appartiene alla query, un annidamento che nasconde il flusso), mai per abbassare una cifra. La misura è di sola lettura e precede la decisione: prima il report, poi l'eventuale correzione secondo le regole di questa fase. Non misurare e correggere nello stesso gesto.
- **Obiettivo secondario: la correttezza generale.** Bug evidenti, casi limite scoperti, errori di logica, validazioni mancanti ai boundary, eccezioni silenziate, incoerenze con i pattern del codebase, violazioni delle "Preferenze sempre attive" di questo file.
- **Passagli il contesto necessario**: qual era l'obiettivo, quali file sono stati creati o modificati, quali vincoli valgono (versione Java, framework, spec di riferimento). Deve **leggere il codice reale** prima di giudicare, non fidarsi del riassunto dell'implementer.
- **Cosa può correggere da sé**: difetti contenuti dentro i file già toccati dal task — un caso limite scoperto, una validazione mancante, un nome fuorviante, una piccola incoerenza. Tutto ciò che allarga il perimetro (nuovi file, cambi di firma pubblica, modifiche ai chiamanti, riprogettazioni) è **una proposta**, non un intervento: riportamela con impatto e costo.
- **Non è un revisore di stile e non riapre scelte già concordate.** Se il codice fa quello che deve, lo dichiara e non tocca nulla: è un esito valido e frequente.
- **Ri-verifica compilazione e test** dopo ogni sua correzione.
- **Per il codice Alpaca.js** la verifica la fa `alpaca-forms-developer`, con lo stesso mandato.
- **Non serve** quando il task non ha prodotto codice (analisi, spiegazione, diagnosi, sola documentazione), per modifiche puramente cosmetiche già concordate, o quando l'implementazione rientra nella «Soglia di banalità».
- Annota l'esito nel registro di `implementation-<compito>.md`: cosa ha confermato, cosa ha corretto, cosa ha solo proposto.

#### Residui della specifica precedente

Quando la specifica cambia mentre l'implementazione è in corso, la modifica si ferma quasi sempre sulla superficie — la firma, il punto di chiamata, il parametro rimosso — mentre il corpo dei metodi resta modellato sul contratto vecchio. Il risultato passa i test e produce l'output giusto, ma **non rispetta il disegno**: chi lo leggerà domani dedurrà dalla forma del codice un contratto che non esiste più, e ci costruirà sopra.

**La domanda da porsi su ogni metodo toccato è una sola: se questo codice fosse scritto oggi da zero, con il contratto attuale, avrebbe questa forma?** Se la risposta è no, è un residuo: va segnalato e — se sta dentro i file toccati dal task — corretto.

Segnali tipici:

- **Cardinalità sopravvissuta.** Il contratto nuovo ammette al più un elemento, ma il codice continua a ciclare, filtrare, ordinare e «prendere il primo» come quando gli elementi potevano essere molti. Vale anche al contrario: strutture dati dimensionate sulla molteplicità vecchia (`List`, `Map`, array) dove ora basta un singolo valore o un `Optional`.
- **Selezione in memoria orfana del suo criterio.** La query carica più record del necessario e li restringe in memoria, ma il criterio che giustificava quel restringimento era proprio il parametro rimosso: ora la selezione appartiene alla query.
- **Rami difensivi impossibili.** Controlli, `else` e gestioni di casi che il contratto nuovo rende irraggiungibili, tenuti «per sicurezza».
- **Nomi e lessico del concetto rimosso.** Variabili, metodi privati, costanti, messaggi di log, commenti e chiavi che parlano ancora del parametro o della dimensione che non esiste più.
- **Parametri e campi diventati inerti.** Argomenti passati e mai usati, campi valorizzati e mai letti, oggetti di contesto che trasportano dati morti.
- **Test rimasti sulla forma vecchia.** Casi che costruiscono scenari ormai impossibili, o che verificano la disambiguazione fra elementi che oggi non possono coesistere.

**Confine.** Il residuo va cercato rispetto alla modifica fatta dal task e alla specifica che implementa, dentro i file toccati. Codice modellato su contratti vecchi che il task non ha toccato si segnala, non si riscrive dentro questo diff. E se rimuovere il residuo comporta cambiare firme pubbliche, query o chiamanti fuori scope, resta una proposta con impatto e costo, non un intervento.

### solid-srp-reviewer — terza forza eventuale (solo Java, mai su Liferay)

`solid-srp-reviewer` **non è più un passaggio di default**. È una terza forza da mettere in campo solo quando serve davvero, dopo che la fase di verifica è già passata. La sua lente non è come è scritto un metodo — quello lo governa già `clean-code-implementer` — ma se un'unità ha più di una ragione per cambiare: service che cresce a ogni feature, metodo che valida e mappa e persiste, classe i cui campi servono due gruppi disgiunti di metodi, logica messa nella classe esistente solo perché era già iniettata.

- **MAI sui progetti Liferay.** È un'esclusione assoluta, senza eccezioni e senza valutazione caso per caso: sui progetti Liferay non lo invochi, indipendentemente da quanto il codice sembri mal collocato. Riconosci il progetto Liferay dai segnali soliti — moduli OSGi con `bnd.bnd`, Liferay Workspace, dipendenze `com.liferay`, `@Component`/`@Reference` OSGi, Service Builder, portlet e MVC command. Nel dubbio, considera il progetto Liferay e non invocarlo.
- **Invocalo solo se** vale una di queste: (a) te lo chiedo esplicitamente; (b) la fase di verifica ha segnalato un problema di **collocazione** delle responsabilità che eccede il suo perimetro; (c) il task ha creato classi nuove e hai un dubbio concreto e argomentabile sulla loro responsabilità — non per abitudine.
- **Non invocarlo** per default dopo ogni modifica Java, né per task piccoli, bugfix puntuali o modifiche interne a una classe già ben collocata.
- È l'agente a decidere se il codice merita modifiche: se le responsabilità sono ben collocate lo dichiara e non tocca nulla. Va bene così.
- Esegui la revisione dopo che il codice compila, i test sono verdi e la fase di verifica è chiusa; **ri-verifica i test dopo le sue modifiche**.
- **Applica da sé** solo interventi contenuti sulle classi preesistenti modificate: estrazione di metodi privati, spostamenti dentro classi già cablate, rinomine nello scope. **Creare classi, bean o componenti OSGi, cambiare firme pubbliche o toccare chiamanti fuori scope resta una sua proposta**: la decisione è mia, riportamela con impatto e costo invece di farla applicare.
- **`CORREZIONI_IMPLEMENTER`** — sulle classi nuove create dal task il reviewer non applica correzioni né me le propone soltanto: restituisce questo blocco con cosa cambiare e come. Il reviewer non può invocare subagent: tocca al processo principale ridelegare a `clean-code-implementer` passandogli integralmente quelle istruzioni, ri-verificare compilazione e test dopo le modifiche e, **una sola volta**, ri-invocare `solid-srp-reviewer` sulle classi corrette. Se anche il secondo giro produce un blocco, fermati e riportamelo invece di iterare.
- Il suo modo di sbagliare è opposto a quello di un revisore di stile: non fa troppo poco, rischia di fare troppo. Se propone di spezzare in molti file una modifica piccola, fermalo e chiedimi conferma.
- Lavora **solo sui file toccati dal task**. Codice mal collocato preesistente va segnalato, non sistemato dentro il diff corrente.
- **Esclusioni assolute**: progetti Liferay, codice non-Java, task che non producono codice (analisi, spiegazioni, doc) e riscritture puramente cosmetiche già concordate.
- Annota nel registro di `implementation-<compito>.md` l'esito (invocato/non invocato **con la motivazione**, cosa ha cambiato, cosa ha solo proposto, eventuale giro `CORREZIONI_IMPLEMENTER` con il risultato della ridelega), così la decisione resta tracciata.

### alpaca-forms-developer — codice Alpaca.js (sostituisce l'implementer generico)

Quando il task richiede di **scrivere, estendere, correggere o manutenere codice Alpaca.js** (form, schema/options, field type custom, validator, view, template, integrazione col backend), delega ad `alpaca-forms-developer` invece che a `clean-code-implementer`.

- Ha precaricate le skill `alpaca-forms` e `clean-code` e legge su richiesta il reference con la superficie API verificata sul sorgente Alpaca.
- Vale per il codice **lato Alpaca**. La parte Java che produce schema, options o dati resta di `clean-code-implementer` con le skill `liferay`/`springboot`.
- La **fase di verifica** sul suo output la fa lui stesso, in una seconda invocazione in modalità verifica, con lo stesso mandato descritto per `clean-code-implementer`.
- `solid-srp-reviewer` **non** si applica al suo output: è JavaScript. E se il contorno Java è Liferay, non si applica neanche lì.
- Non usarlo per Alpaca Markets (API di trading) né per il modello LLM Stanford Alpaca: sono prodotti diversi.

## Sub-agent per git

### git-specialist — commit, push e verifiche

Tutte le operazioni git passano da `git-specialist`: commit con messaggio conforme, preparazione ed esecuzione del push, verifiche di stato e divergenza, diagnosi (chi ha introdotto una modifica o una regressione), recupero di lavoro perso e — solo su mia richiesta esplicita — riscrittura di commit non ancora pushati.

- Ha precaricate `git-commit-messages` e `git-branch-token`; legge su richiesta `git-inspection` e il reference sui moduli OSGi.
- Il messaggio è in italiano, con il sommario che comincia dal verbo e **senza prefisso di tipo**, i **moduli impattati** sui soli progetti Liferay e l'ultima riga sempre `tkn: <token>`.
- Non usarlo per scrivere codice applicativo, né per il documento di passaggio in produzione (`release-plan-produzione`).

**Escalation da gestire nel processo principale.** Il subagent non ha `AskUserQuestion`: quando serve una mia decisione si ferma e restituisce un blocco etichettato. Tocca a te chiedermelo e poi ridelegare con la risposta:

- `TOKEN_RICHIESTO` — primo commit su questo branch: chiedimi il token usando le proposte che ha generato (la prima è la raccomandata), poi ridelega. Sui commit successivi il token lo ricava da sé dai commit precedenti e non ti disturba.
- `PUSH_DA_CONFERMARE` — il push richiede **sempre** la mia conferma esplicita, su qualunque branch. Mostrami cosa andrebbe sul remoto e attendi; poi ridelega dichiarando la conferma.
- `BRANCH_PROTETTO`, `COMMIT_DA_SPEZZARE`, `SEGRETI_RILEVATI`, `STORIA_GIA_PUSHATA`, `OPERAZIONE_IN_CORSO` — riportameli come sono, con la sua proposta di soluzione. Non aggirarli committando o pushando tu al suo posto.

## Alla fine di ogni risposta

- aggiungi l'informazione della percentuale di contesto coccupata

## IntelliJ MCP

Quando il server MCP `idea` è disponibile e connesso, usalo come strumento semantico principale per il codice Java.

- Specifica sempre `projectPath` nelle chiamate MCP quando è noto.
- Usa `search_symbol` per cercare classi, metodi e campi; usa la ricerca testuale solo per stringhe, configurazioni e contenuti non semantici.
- Usa `get_symbol_info` prima di modificare simboli o API di cui non è chiaro il contratto.
- Usa `read_file` per consultare sorgenti, classi decompilate e codice contenuto nelle dipendenze JAR.
- Usa sempre `rename_refactoring` per rinominare classi, metodi e campi. Non effettuare rinominazioni mediante sostituzione testuale.
- Dopo aver modificato un file Java, usa `get_file_problems` per controllare errori e warning introdotti.
- Dopo un gruppo coerente di modifiche, usa `build_project` per verificare la compilazione tramite IntelliJ, se il progetto è liferay non buildare mai ma chiedi di farlo;
- Quando esiste una configurazione IntelliJ pertinente, usa `get_run_configurations` ed `execute_run_configuration` per eseguire applicazioni o test.
- `build_project` non sostituisce i test e le verifiche Maven previste dal progetto.
- Evita chiamate MCP duplicate quando le informazioni sono già disponibili nel contesto.
- Se IntelliJ MCP non è disponibile, continua con gli strumenti ordinari e segnala quali verifiche semantiche non sono state eseguite.

## Cosa non fare

- Non generare codice enorme senza accordo.
- Non inventare API, classi, metodi o configurazioni non verificati.
- Non introdurre astrazioni premature.
- Non hardcodare stringhe utente in Java o JSP.
- Non spostare logica applicativa nelle view.
- Non usare filtri in memoria per vincoli di sicurezza o visibilità dati.
- Non usare `byte[]` per file grandi se puoi fare streaming.
- Non cambiare lo stile di formattazione del progetto per vanità tecnica.

Il file init per progetto bandi è questo, c:/Users/fabio.dearcangelis/Desktop/desktop/lavoro/attivita/Emi/paservdig/introProgettoPerClaude.md quando viene chiesto initBandi leggi questo file e dai conferma della lettura avvenuta
