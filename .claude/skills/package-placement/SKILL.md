---
name: package-placement
description: Decide dove collocare le classi e i file nuovi di un task - quale package Java, quale modulo, quale cartella - e quando serve crearne uno nuovo invece di riusarne uno esistente. Usa prima di scrivere il primo file, ogni volta che il task crea file nuovi. Impone di scegliere per concetto e non per somiglianza, vieta di parcheggiare le classi nel «migliore fra i package disponibili» e nei contenitori generici util, common, misc o helper, riconosce i segnali che chiedono un sottopackage nuovo (coesione lessicale di tre o più classi, ragione di cambiare diversa, assenza di dipendenza), obbliga a rispettare l'asse di organizzazione del codebase, definisce l'escalation PACKAGE_DA_CONFERMARE per package top-level e spostamenti, e impone di dichiarare la collocazione scelta nell'output. Vale per package Java, moduli OSGi, namespace e cartelle JavaScript. Da comporre con clean-code. NON riguarda il naming delle classi né la riorganizzazione di package che il task non tocca.
---

# Scopo
Stabilire dove va collocato un file nuovo, e quando la collocazione giusta è un package che ancora non esiste.

# Quando usare questa skill
Usa questa skill se:
- il task crea una o più classi, interfacce, enum o file nuovi
- il task sposta codice esistente e va deciso dove finisce
- va verificata la collocazione di classi appena scritte, in fase di revisione
- va compilata la sezione «file da creare» di una specifica

# Quando NON usare questa skill
Non usare questa skill se:
- il task modifica solo file già esistenti senza crearne di nuovi
- il task chiede una riorganizzazione dei package come obiettivo dichiarato: quella è una richiesta esplicita, non una decisione di collocazione
- il task riguarda solo analisi, spiegazione o documentazione

# Regole di precedenza
- Le istruzioni esplicite dell'utente sulla collocazione prevalgono su questa skill.
- La tassonomia già adottata dal codebase prevale sulle preferenze generali di questa skill: si sceglie dentro l'organizzazione esistente, non contro.
- Il divieto di refactoring non richiesto (`clean-code` § 13) resta valido: questa skill governa **dove nasce il codice nuovo**, non la riorganizzazione di quello vecchio.
- Su Liferay e su ogni progetto a moduli, i vincoli del framework (struttura del modulo, package esportati nel `bnd.bnd`, confine api/impl) prevalgono.

# Regole operative

## 1. Il package è un nome, non un contenitore

### Regola
- La domanda giusta non è «a quale package assomiglia di più questa classe», ma **«di che cosa parla questo package, e la classe nuova parla di quello?»**.
- «Il migliore fra i package disponibili» **non è un criterio**. Se nessun package esistente descrive la classe nuova, l'esito corretto non è il meno peggio: è un package nuovo.
- Se per dire cosa contiene il package servisse una congiunzione — «risultati **e** telemetria» — il package sta accogliendo due concetti e ne serve un secondo.

### Perché
Un package è la prima informazione che il lettore riceve su una classe, prima ancora del suo nome. Un package che mente costa a ogni lettura futura e, peggio, invita chi arriva dopo ad aggiungerci la classe successiva per lo stesso motivo sbagliato: la collocazione approssimativa si autoalimenta.

## 2. Procedura, prima di scrivere il primo file nuovo

1. **Mappa la tassonomia esistente.** Con `Glob` sui sorgenti, ricostruisci l'asse di organizzazione (per layer? per feature? per dominio?), la profondità tipica dei package e i nomi già in uso.
2. **Elenca i file nuovi e il concetto che condividono.** Se non riesci a nominare quel concetto con un sostantivo, il problema non è la collocazione: sono le classi.
3. **Applica i test della § 3.** Basta un test positivo per aprire la questione; due o più la chiudono.
4. **Decidi** fra le tre uscite della § 5.
5. **Dichiara la scelta** nell'output secondo la § 6, sempre — anche quando il package esiste già.

## 3. I test che chiedono un package nuovo

### Coesione lessicale
Tre o più file nuovi che condividono un termine di dominio nel nome — `TelemetrySnapshot`, `TelemetryCollector`, `TelemetryEvent` — stanno già dichiarando il nome del sottopackage che manca. È il segnale più meccanico e il più affidabile: quel prefisso ripetuto è un package non scritto.

### Ragione di cambiare
È la SRP applicata al package (`clean-code` § 7). Le classi già presenti e quelle nuove cambiano per la stessa ragione, su richiesta dello stesso committente? Le classi in `result` cambiano quando cambia il modello di elaborazione; quelle di telemetria quando cambia cosa si misura. Due ragioni, due package.

### Dipendenza
Le classi nuove usano, o sono usate da, le classi già presenti nel package? Se non c'è nessuna relazione in nessuna delle due direzioni, con quelle classi condividono soltanto una directory.

### Asse di organizzazione
Il package proposto sta sullo stesso asse degli altri. In un codebase organizzato per feature non si introduce un package per layer, e viceversa. Un sottopackage nuovo si aggancia alla tassonomia esistente: non ne apre una seconda in parallelo.

### Ritrovabilità
Chi cerca queste classi fra sei mesi, senza conoscerle, dove guarderebbe per prima cosa? Se la risposta non è il package scelto, la scelta è sbagliata anche quando supera tutti gli altri test.

## 4. Quando NON creare un package nuovo

- **Una sola classe** che parla dello stesso concetto del package esistente: un package per classe è rumore, non struttura.
- **Crescita futura ipotetica**: il package si crea quando le classi ci sono, non per accoglierle un giorno.
- **Nome tecnico invece che concettuale**: se il package si potrebbe descrivere solo come «le classi che servono a X», non è un concetto, è un elenco.
- **Confini del framework**: quando il package è vincolato (package esportati OSGi, convenzioni di scansione dei componenti, entry point attesi dal framework), il vincolo vince.

### Nomi vietati come destinazione
`util`, `utils`, `common`, `commons`, `misc`, `helper`, `helpers`, `base`, `shared`, `core` usati come contenitori generici: sono «il migliore fra i disponibili» in forma pura, e per definizione non hanno una ragione di cambiare. Se un package esistente ha uno di questi nomi, non è una destinazione ammessa per codice nuovo, e nemmeno un nome ammesso per un package nuovo. Fa eccezione solo un package con quel nome che il codebase usa già con un significato preciso e circoscritto, verificabile leggendo cosa contiene.

## 5. Le tre uscite, e quando fermarsi

**A — Package esistente.** Nessun test è scattato, o il concetto è già quello del package. Si procede e si dichiara.

**B — Sottopackage nuovo sotto il genitore ovvio.** I test sono scattati e il genitore corretto è già identificato (`result` → `result/telemetry`). **Lo crei e lo dichiari nell'output, senza fermarti**: è una decisione locale e reversibile, e bloccarla ogni volta costa più di quanto valga.

**C — Escalation.** Ti fermi **prima di scrivere** e restituisci il blocco qui sotto quando la collocazione richiede: un package **top-level** nuovo, un **modulo** nuovo, lo **spostamento di classi esistenti**, oppure quando due genitori sono difendibili in modo equivalente e la scelta cambia il disegno.

```text
PACKAGE_DA_CONFERMARE

File nuovi: <elenco>
Concetto condiviso: <sostantivo>
Asse di organizzazione del codebase: <per layer | per feature | per dominio | misto>

Alternative:
1. <package> — <perché> — costo: <file toccati, impatti>
2. <package> — <perché> — costo: <...>

Raccomandata: 1
```

Non aggirare l'escalation scegliendo un package esistente «per non bloccare»: è esattamente il difetto che questa skill esiste per impedire.

## 6. Dichiarazione obbligatoria nell'output

Ogni task che crea file nuovi riporta, in una riga per gruppo di file:

```text
Collocazione: <package> — <motivazione in una riga>
```

Vale anche per l'uscita A. Una decisione dichiarata è una decisione che qualcuno può correggere; oggi la collocazione è invisibile e per questo non viene mai rivista.

## 7. Fuori da Java

La regola è la stessa; cambia l'unità. Moduli OSGi e Maven: un modulo nuovo è sempre uscita C, mai una decisione autonoma. Cartelle JavaScript, TypeScript e risorse statiche: valgono coesione lessicale, asse di organizzazione e divieto dei nomi contenitore. Namespace e directory di altri linguaggi: identico.

# Esempio svolto

Un task produce `TelemetrySnapshot`, `TelemetryCollector` e `TelemetryEvent`. Il codebase ha un package `result`, dove stanno le classi che rappresentano l'esito dell'elaborazione.

**Sbagliato** — tutte e tre in `result`: sono «risultati» in senso lato, ed è il package più vicino fra quelli disponibili.

**Giusto** — `result/telemetry`. Coesione lessicale: tre classi con lo stesso termine di dominio nel nome. Ragione di cambiare: le classi di `result` cambiano col modello di elaborazione, queste cambiano con ciò che si decide di misurare. Dipendenza: nessuna classe di `result` le usa. Il genitore resta `result` perché la telemetria descrive comunque un esito, quindi è l'uscita B: si crea e si dichiara, senza fermarsi.

```text
Collocazione: it.esempio.result.telemetry — tre classi nuove con termine di dominio comune, ragione di cambiare distinta da result (cosa si misura vs modello di elaborazione).
```

# Vincoli
- Non collocare file nuovi in un package solo perché è il più somigliante fra quelli esistenti.
- Non usare `util`, `common`, `misc`, `helper`, `base`, `shared` o `core` come destinazione di codice nuovo, né come nome di un package nuovo.
- Non creare package top-level né moduli senza escalation.
- Non spostare classi esistenti dentro il diff corrente senza escalation: la collocazione sbagliata preesistente si segnala, non si corregge di nascosto.
- Non introdurre un asse di organizzazione diverso da quello già adottato dal codebase.
- Non creare un package per una classe sola, né per crescita futura ipotetica.
- Non omettere la riga di dichiarazione della collocazione, nemmeno quando il package esiste già.

# Esempi di attivazione
- «Aggiungi le classi di telemetria dell'applicazione»
- «Crea il service e il mapper per la nuova funzionalità»
- «Dove metto questa classe?»
- «Verifica che le classi appena scritte siano collocate bene»

# Esempi di non attivazione
- «Rifattorizza questo metodo»
- «Correggi il messaggio di errore in questa classe»
- «Riorganizza i package del modulo» — richiesta esplicita di riorganizzazione, non una decisione di collocazione
