---
name: clean-code
description: Usa per generare codice nuovo, rifattorizzare, migliorare leggibilità o manutenibilità, qualsiasi task il cui output finale contiene codice. Applica regole di clean code quando generi o modifichi codice sorgente. Realizza metodi piccoli e focalizzati, singola responsabilità per classe e per metodo (SRP, una sola ragione per cambiare), naming chiaro, basso annidamento, singolo livello di astrazione per metodo (SLAP), estrazione di metodi per dare un nome all'intenzione anche senza riuso, commenti e Javadoc quasi a zero (il default è non commentare, il commento è un'eccezione da giustificare), Optional solo come valore di ritorno e mai come parametro o campo, dependency injection, gestione delle eccezioni, pochi parametri di ingresso con classi aggregatrici al posto delle liste lunghe, testabilità, anti-densità (early return, variabili esplicative, condizioni complesse spezzate in flag boolean). Da comporre con skill di linguaggio o framework (java-conventions, springboot, liferay).
---

# Scopo
Applicare regole di clean code quando il modello genera o modifica codice sorgente.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di generare codice nuovo
- l'utente chiede di rifattorizzare codice esistente
- l'utente chiede miglioramenti di leggibilità, manutenibilità o qualità del codice
- la risposta finale contiene codice sorgente

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede solo una spiegazione teorica senza codice
- l'utente chiede una trascrizione letterale di codice già fornito
- esiste una skill più specifica per il linguaggio o framework che impone regole incompatibili
- l'utente richiede esplicitamente uno stile diverso

# Regole di precedenza
- Questa skill è la base predefinita per ogni task che richiede generazione o modifica di codice.
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e vincoli globali hanno priorità superiore
- In caso di conflitto con skill generiche di scrittura, questa skill prevale per il codice
- In caso di conflitto con skill più specifiche di linguaggio o framework, prevale la skill più specifica

# Obiettivi
Il codice generato deve essere:
- leggibile
- coeso
- poco annidato
- facile da testare
- con nomi chiari
- con responsabilità ben separate

# Regole operative

## 1. Funzioni e metodi

### Regola
- Devono fare una cosa sola
- Devono essere piccoli
- Spezzare metodi con responsabilità multiple
- Favorire early return o early continue per ridurre annidamento

### Perché
Metodi piccoli e focalizzati rendono il flusso più leggibile, semplificano i test e riducono il rischio di effetti collaterali nascosti.

### Esempio corretto
```java
public void process(Order order) {
    if (!isProcessable(order)) {
        return;
    }

    validate(order);
    enrich(order);
    save(order);
}

private boolean isProcessable(Order order) {
    return order != null && !order.isArchived();
}
```

### Anti-esempio
```java
public void process(Order order) {
    if (order != null) {
        if (!order.isArchived()) {
            validate(order);
            enrich(order);
            save(order);
            audit(order);
            notifyWarehouse(order);
        }
    }
}
```

## 2. Optional — solo come valore di ritorno (priorità molto alta)

### Regola
- `Optional` è ammesso **esclusivamente come tipo di ritorno** di un metodo, quando l'assenza del valore fa parte del contratto.
- **Vietato** `Optional` come **parametro** di metodo o costruttore, pubblico o privato che sia.
- **Vietato** `Optional` come **campo** di classe e come tipo di elemento in collezioni (`List<Optional<T>>`, `Map<K, Optional<V>>`).
- Chi chiama scioglie l'`Optional` **prima** di invocare: passa il valore, oppure niente. Se un parametro è davvero facoltativo, le alternative corrette sono due metodi con nomi di business distinti (spesso la scelta migliore: il nome dichiara il caso), un parametro nullable gestito subito nel corpo, un value object che modella esplicitamente il caso "assente", oppure spostare la decisione nel chiamante eliminando del tutto il ramo condizionale dal metodo.
- La regola vale in ogni linguaggio con un tipo opzionale analogo (`Optional`, `Option`, `Maybe`): il tipo opzionale descrive un *risultato*, non un *ingresso*.
- È un vincolo non negoziabile: quando incontri una firma che lo viola in codice che stai già modificando, segnalalo e proponi la correzione.

### Perché
Un parametro `Optional` moltiplica gli stati di ingresso invece di ridurli: il chiamante può passare `null`, `Optional.empty()` o un valore presente, quindi il metodo deve difendersi da tre casi anziché due, e il `null` resta possibile perché `Optional` non è mai vincolato a essere non-nullo. In più maschera che il metodo fa due cose diverse a seconda della presenza del valore: quel ramo condizionale appartiene al chiamante o a due metodi distinti, non a una firma ambigua. Come tipo di ritorno, invece, `Optional` comunica esattamente una cosa utile: "questo valore può non esserci".

### Esempio corretto
Due metodi con nomi distinti; il chiamante scioglie l'`Optional` una volta sola, dove la decisione ha senso.
```java
private String describeVerdict(CombatResult result) { ... }

private String describeVerdictWithFavorite(CombatResult result, Fighter favorite) { ... }

String verdict = findFavorite(result)
        .map(favorite -> describeVerdictWithFavorite(result, favorite))
        .orElseGet(() -> describeVerdict(result));
```

### Anti-esempio
Tre stati di ingresso possibili (`null`, `empty`, presente) e un ramo condizionale che appartiene al chiamante.
```java
private String describeVerdict(CombatResult result, Optional<Fighter> favorite) {
    if (favorite != null && favorite.isPresent()) {
        return withFavorite(result, favorite.get());
    }
    return noFavorite(result);
}
```

## 3. Naming

### Regola
- Usare nomi espliciti e coerenti
- Evitare abbreviazioni oscure
- Privilegiare chiarezza rispetto a brevità inutile

### Perché
Un buon naming riduce la necessità di commenti e rende il codice comprensibile anche fuori dal contesto immediato.

## 4. Commenti — il default è nessun commento (priorità molto alta)

### Regola
- **Il codice non si commenta.** Il commento è un'eccezione da giustificare, non una buona abitudine: se non supera il test di ammissione, non si scrive. Vale in ogni linguaggio.
- **Test di ammissione**: il commento spiega un *perché* che il lettore non può dedurre da nomi, tipi e struttura, e che **nessuna riscrittura del codice renderebbe evidente**. Se alla domanda «si capirebbe da solo con un nome migliore o un metodo estratto?» la risposta è sì, si estrae o si rinomina, non si commenta.
- **Casi ammessi, elenco chiuso**: vincolo esterno non evidente (bug noto di una libreria, limite di un'API, requisito normativo o contrattuale); workaround deliberato, con la ragione per cui la via ovvia non funziona; scelta contro-intuitiva che un manutentore «correggerebbe» rompendo qualcosa; riferimento tracciabile (ticket, issue, RFC, pagina di documentazione); invariante o precondizione non esprimibile nel tipo; formula o algoritmo la cui derivazione non sta nel codice; `TODO`/`FIXME` con riferimento tracciabile.
- **Vietati sempre**: etichette di blocco (`// Validazione`, `// Calcolo del totale`) — sono metodi da estrarre; narrazione passo per passo; riformulazione della firma o del nome; commenti che compensano nomi o logica scadenti; commenti su codice ovvio; codice commentato; separatori decorativi; codice o tag HTML dentro i blocchi di commento.
- **I commenti già presenti non si toccano**: niente passate di pulizia sui file che il task non deve cambiare. Unica eccezione: se la modifica rende **falso** un commento esistente, si aggiorna o si elimina — un commento che mente è peggio di nessun commento.
- **Nel dubbio non si commenta.** Un commento mancante costa due righe di codice lette; un commento inutile lo paga ogni lettura futura, e il prezzo cresce quando invecchia.

### Javadoc
- **Nessuna Javadoc di default**, nemmeno sui metodi e sui tipi pubblici. Una Javadoc che riformula la firma (`@param order l'ordine`, `@return il risultato`) è rumore con una sintassi più costosa.
- Ammessa solo per la parte di contratto **non deducibile dalla firma**: eccezioni lanciate e in quali condizioni, nullabilità, unità di misura o formato atteso, range ammessi, effetti collaterali, garanzie di thread-safety o transazionali, ordinamento e mutabilità del valore di ritorno. Si documenta quella parte, non il resto.
- Mai come decorazione sugli helper privati.
- Se il progetto ha già una policy Javadoc uniforme, prevale la coerenza col progetto: seguirla senza richiederla di nuovo.

### Perché
Il codice è l'unica descrizione del comportamento che non può mentire, perché è quella eseguita. Ogni commento è una seconda descrizione, non verificata da niente, che diverge alla prima modifica. Un nome giusto e un metodo estratto ottengono lo stesso risultato senza aprire quel debito.

### Anti-esempio
```java
// Incrementa il contatore degli utenti.
userCount++;

// Validazione
if (order == null || order.isArchived()) {
```

### Esempio corretto
```java
// L'API remota rifiuta i batch oltre 500 elementi con un 400 privo di messaggio (ticket PSD-1174).
List<List<Item>> batches = partition(items, MAX_BATCH_SIZE);
```

## 5. Controllo di flusso

### Regola
- Ridurre i livelli di annidamento
- Evitare condizioni booleane difficili da leggere
- Estrarre predicati complessi in metodi con nome chiaro

### Perché
Un flusso poco annidato si legge più velocemente, si testa meglio e riduce gli errori introdotti da condizioni opache.

### Esempi completi
Annidamento eliminato con early return e predicato estratto con nome di business: vedi [reference/examples.md](reference/examples.md), casi 1, 3 e 4.

## 6. Error handling

### Regola
- Preferire eccezioni significative a codici di ritorno opachi
- Fallire presto sugli input pubblici non validi
- Non silenziare eccezioni e non catturare eccezioni troppo generiche senza motivo
- Preservare l'eccezione originale quando è utile alla diagnosi
- Fornire messaggi di errore comprensibili
- Non restituire `null` per casi eccezionali, salvo convenzione esplicita del progetto
- Loggare ai boundary applicativi, non ovunque; non loggare e rilanciare la stessa eccezione senza valore aggiunto

### Dove si valida
La guardia sta **dove il valore entra sotto il tuo controllo**, non a ogni metodo che lo attraversa.

- **Sì**: metodi pubblici che sono punto d'ingresso di un modulo o di un'API — controller, endpoint, resource command, facciata di un modulo, metodo pubblico invocato da un altro package.
- **Sì**: costruttori dei tipi che portano un invariante — value object, `record` con vincoli di dominio, tipi che rappresentano un valore che non può essere qualunque cosa.
- **No**: metodi privati, quando i chiamanti sono già controllati.
- **No**: salti interni di delega. Se `A.esegui(x)` ha già validato `x` e chiama `B.calcola(x)` nello stesso perimetro, `B` non rivalida. Tre guardie sullo stesso valore non sono tre volte più sicure: insegnano a non leggere le guardie.
- **No**: tipi che sono dettagli implementativi interni — record annidati privati, classi package-private con un solo chiamante già controllato.
- **Meglio della guardia ripetuta**: far portare l'invariante al tipo. Se un valore non può essere nullo o fuori intervallo, il posto della verifica è il costruttore del tipo che lo rappresenta, una volta sola.

### Forma della guardia
- Null → `Objects.requireNonNull(x, "x must not be null")`, oppure `Assert.notNull` sui progetti Spring. **Non** `IllegalArgumentException` per un null.
- Valore presente ma non valido nel dominio → `IllegalArgumentException`, con il vincolo violato nel messaggio.
- Stato dell'oggetto incompatibile con l'operazione richiesta → `IllegalStateException`.
- Il messaggio dichiara il **vincolo**, non il nome della classe: lo stack trace la dice già, e al primo rinominamento il prefisso mente.

### Perché
Gli errori devono essere leggibili e diagnosticabili. Un'eccezione generica o silenziata rende il debugging più lento e fragile.

### Esempio corretto
```java
public Customer loadCustomer(long customerId) {
    return repository.findById(customerId)
            .orElseThrow(() -> new CustomerNotFoundException(
                    "Customer not found: " + customerId));
}
```

### Anti-esempio
```java
public Customer loadCustomer(long customerId) {
    try {
        return repository.findById(customerId).get();
    } catch (Exception ex) {
        return null;
    }
}
```

## 7. Classi e singola responsabilità

### Regola
- Un'unità ha **una sola ragione per cambiare**. Il criterio non è quante cose fa, ma quanti committenti diversi possono chiederne la modifica: se per dire quando cambia servono due frasi unite da «e», sono due unità.
- Prima di aggiungere un metodo o un campo a una classe esistente, verifica che appartenga alla sua ragione di cambiare. Se non ci appartiene, la collocazione giusta è un'altra classe, anche quando quella esistente è già iniettata e comoda.
- Il criterio di separazione è la ragione di cambiare, non il numero di righe né di metodi: due responsabilità che cambiano sempre insieme sono una responsabilità sola.
- Vale per i metodi quanto per le classi: un metodo che valida, trasforma e persiste ha tre ragioni per cambiare (regole di business, formato dei dati, schema di persistenza).
- Nome coerente col ruolo effettivo. Un nome che non riesci a dare senza `And` o senza un termine generico è la prima diagnosi di responsabilità multipla.
- **I dati di configurazione di un dominio sono una ragione di cambiare a sé.** Listini, tariffe, aliquote, soglie, cataloghi e tabelle di corrispondenza non stanno nella classe che li interroga: chi rivede i prezzi e chi cambia il modo di leggerli sono due committenti diversi. La classe che legge **riceve** i dati dal costruttore; a produrli è un collaboratore separato. Il segnale è meccanico e si conta a occhio: i metodi che costruiscono i dati pesano più di quelli che li usano.
- **Una classe che si costruisce da sola i propri dati non ha cuciture.** `this.listino = costruisciListino()` dentro il costruttore impedisce di fornirne uno diverso — per un secondo mercato, per una prova, per la sorgente esterna che prima o poi arriverà. Vale anche quando oggi i dati sono costanti: il giorno in cui verranno da un file o da una tabella si dovrà modificare la classe che sa **leggere** per cambiare quella che **contiene**.

### Segnali di violazione
- La classe cresce a **ogni** feature nuova, qualunque sia la feature.
- Nome cumulativo o vuoto: `Manager`, `Helper`, `Utils`, `Handler`, o un nome con `And`.
- Un metodo mescola attività di natura diversa: validazione, mapping, accesso a dati, notifica.
- Un sottoinsieme di campi è usato solo da un sottoinsieme disgiunto di metodi (bassa coesione).
- Testare un comportamento obbliga a mockare collaboratori che con quel comportamento non c'entrano.
- Commenti che etichettano blocchi (`// invio mail`, `// calcolo importi`) separano ciò che potrebbero essere unità distinte.
- Import di package eterogenei nello stesso file: persistence, web e formattazione insieme.

### Perché
La ragione di cambiare è ciò che determina chi rompe cosa. Una classe con tre committenti diversi obbliga chi ne serve uno a leggere e rischiare gli altri due, e rende ogni test una cerimonia di mock. Contare le righe invece delle ragioni produce l'errore opposto: file microscopici che cambiano sempre insieme.

### Quando NON separare
- Le due parti cambiano sempre insieme: è una responsabilità sola distribuita male.
- L'estrazione produce una classe di passaggio che inoltra la chiamata senza aggiungere decisione né nome utile.
- La seconda responsabilità è ipotetica e non ancora visibile nel codice presente (§ 11 Open/Closed, § 13).
- Il task corrente non tocca quella parte: la collocazione sbagliata preesistente va segnalata, non risolta dentro un diff che doveva fare altro (§ 13, refactoring vietato).

### Esempi completi
Cinque casi svolti con anti-esempio e versione corretta — classe che cresce a ogni feature, metodo che valida/trasforma/persiste, bassa coesione dei campi, frammentazione eccessiva, catalogo di dati dentro la classe che lo interroga: vedi [reference/srp.md](reference/srp.md).

## 8. Dipendenze

### Regola
- Preferire dependency injection
- Evitare creazione diretta di dipendenze dentro la logica
- Isolare framework e servizi esterni dietro boundary chiari
- **Un collaboratore è un oggetto, non una classe di metodi statici.** Le classi che svolgono un compito — parser, validatori, calcolatori, aggregatori, formattatori, orchestratori, policy — si istanziano **anche quando non hanno stato**, e ricevono le proprie dipendenze dal costruttore. Una classe `final` con costruttore privato e soli metodi `static` non è una semplificazione: è un collaboratore a cui sono state tolte le cuciture.
- **Restano legittimamente `static`, elenco chiuso**: le costanti; i factory method sul tipo che costruiscono (`Costi.nessuno()`); i metodi di un `enum`; i metodi privati di supporto interni a una classe. Tutto il resto è un oggetto.
- **Non mescolare i due stili nello stesso codebase.** Metà statico e metà iniettato non ha né le cuciture dell'uno né la semplicità dell'altro. Se il progetto esistente adotta già una convenzione diversa, quella vince: vale la precedenza del comportamento esistente.

### Perché
Le dipendenze esplicite migliorano testabilità, sostituibilità e controllo del comportamento.

### Esempi completi
Constructor injection contro istanziazione diretta dentro la logica, e collaboratore statico contro collaboratore oggetto, con anti-esempio e versione corretta: vedi [reference/dependencies.md](reference/dependencies.md).

## 9. Duplicazione

### Regola
- Evitare copia-incolla
- Estrarre logica comune solo quando migliora davvero il design
- Non introdurre astrazioni premature

### Perché
La duplicazione vera genera divergenze e manutenzione ripetuta. Però non tutto ciò che si assomiglia va astratto: forzare un'astrazione troppo presto peggiora il design.

### Esempio corretto
```java
private BigDecimal calculateNetAmount(BigDecimal grossAmount, BigDecimal taxRate) {
    return grossAmount.divide(BigDecimal.ONE.add(taxRate), 2, RoundingMode.HALF_UP);
}

public BigDecimal calculateOrderNetAmount(BigDecimal grossAmount) {
    return calculateNetAmount(grossAmount, ORDER_TAX_RATE);
}

public BigDecimal calculateInvoiceNetAmount(BigDecimal grossAmount) {
    return calculateNetAmount(grossAmount, INVOICE_TAX_RATE);
}
```

### Anti-esempio
```java
public BigDecimal calculateOrderNetAmount(BigDecimal grossAmount) {
    return grossAmount.divide(BigDecimal.ONE.add(ORDER_TAX_RATE), 2, RoundingMode.HALF_UP);
}

public BigDecimal calculateInvoiceNetAmount(BigDecimal grossAmount) {
    return grossAmount.divide(BigDecimal.ONE.add(INVOICE_TAX_RATE), 2, RoundingMode.HALF_UP);
}
```

## 10. Testabilità

### Regola
- Generare codice semplice da testare
- Evitare accoppiamenti inutili
- Favorire metodi deterministici e prevedibili
- Preferire test focalizzati sul comportamento, non sui dettagli implementativi privati
- Coprire gli edge case rilevanti per la modifica
- Mantenere i test leggibili e deterministici
- Usare stile, framework, fixture e naming dei test già presenti nel progetto
- Se i test mancano o non sono eseguibili, segnalarlo esplicitamente invece di dichiararli superati

### Perché
Un codice testabile tende a essere anche più pulito, più modulare e meno dipendente dal contesto esterno.

## 11. Principi SOLID

### Regola
Applicare i principi SOLID con pragmatismo, non come dogma.

- **Single Responsibility**: regole operative, segnali di violazione e limiti alla separazione stanno nella § 7, che è la sede unica del principio. Non riapplicarlo qui in forma ridotta.
- **Open/Closed**: prevedere punti di estensione quando la variabilità è reale o probabile, non per futuri ipotetici.
- **Liskov Substitution**: i sottotipi devono preservare il comportamento atteso; non usare l'ereditarietà per riuso quando la composizione è più chiara.
- **Interface Segregation**: preferire interfacce focalizzate; attenzione alle "interfacce implicite" nascoste in data class con troppi campi nullable o dipendenti dal contesto.
- **Dependency Inversion**: dipendere da astrazioni stabili quando riducono l'accoppiamento, senza creare un'interfaccia per ogni classe per riflesso.

### Perché
SOLID migliora manutenibilità e testabilità solo se applicato dove c'è una pressione di design reale. Applicato per abitudine produce solo cerimonia e file in più.

## 12. Design pattern

### Regola
- Usare un design pattern solo quando risolve una pressione di design reale: variazione esplicita, riduzione di duplicazione o di complessità condizionale, migliore testabilità.
- Non usare pattern come decorazione, né trasformare una logica semplice in sei file e un'emicrania.
- Preferire un metodo, un enum, una mappa o una semplice condizione quando sono più chiari di un pattern.

### Perché
I pattern comunicano intento quando calzano sul problema. Usati come etichetta, aggiungono solo strati e nomi altisonanti senza valore.

### Pattern da preferire quando giustificati
- **Strategy**: comportamento che varia per tipo, regola, configurazione o contesto.
- **Factory**: creazione di oggetti con regole significative.
- **Builder**: costruzione con molti parametri opzionali o denominati.
- **Adapter**: isolamento di API esterne o modelli incompatibili.
- **Facade**: semplificazione dell'interazione con un sottosistema complesso.
- **Template Method**: algoritmo con passi stabili e variazione controllata.
- **Decorator**: aggiunta di comportamento senza modificare l'oggetto core.
- **Command**: azioni da accodare, loggare, ritentare o passare in giro.
- **Specification**: predicati di business riusabili e componibili.

## 13. Refactoring

### Regola
Rifattorizzare solo quando supporta la modifica richiesta o previene un danno evidente.

Refactoring consentito:
- estrarre metodi per chiarire il comportamento;
- ridurre duplicazione toccata direttamente dal task;
- semplificare condizioni;
- isolare effetti collaterali;
- migliorare nomi fuorvianti;
- spostare codice solo quando la nuova posizione è chiaramente migliore.

Refactoring vietato:
- grandi pulizie non correlate;
- riscritture solo di stile;
- riformattazione di interi file senza necessità;
- riorganizzazione di package o moduli senza bisogno;
- astrazioni per requisiti futuri immaginari;
- modifiche silenziose al comportamento pubblico.

### Perché
Il refactoring opportunistico e non richiesto aumenta il rischio e sporca i diff, nascondendo la modifica reale dentro rumore non correlato.

## 14. Performance e complessità

### Regola
- Non peggiorare le performance senza motivo, ma non ottimizzare prematuramente.
- Preferire algoritmi leggibili, restando attenti a: cicli annidati accidentali su collezioni grandi, chiamate ripetute a database, chiamate di rete non necessarie, lavoro costoso dentro i loop, serializzazione o parsing inefficienti, chiamate bloccanti in codice async/reattivo, hazard di concorrenza, trasformazioni pesanti in memoria.

### Perché
Sia l'ottimizzazione prematura sia l'inefficienza evidente sono errori costosi. La leggibilità viene prima, ma un'inefficienza ovvia non va ignorata.

## 15. Sicurezza

### Regola
- Non introdurre comportamenti insicuri.
- Prestare attenzione a: validazione degli input, boundary di autenticazione e autorizzazione, SQL injection, command injection, path traversal, deserializzazione insicura, segreti nel codice o nei log, reflection non sicura, permessi troppo ampi, race condition.
- Se il codice richiesto crea un rischio di sicurezza, rifiutare la parte rischiosa e fornire un'implementazione più sicura.

### Perché
Le vulnerabilità sono difetti di qualità del codice a tutti gli effetti, spesso più costosi di un bug funzionale.

## 16. Anti-densità

### Regola
- Tenere il numero degli annidamenti il più basso possibile. Quando il flusso diventa complesso, usare early return, early continue oppure estrarre metodi privati con nomi chiari.
- **Ogni valore prodotto da una chiamata che calcola, costruisce, recupera o interroga ha un nome.** Lo assegni a una variabile esplicativa, poi passi la variabile. Vale **anche quando la chiamata è una sola e non annidata**: la densità non si conta in livelli di annidamento, si misura chiedendosi se ogni valore intermedio ha un nome. `list.add(compute(a, b, c))`, `new Foo(build(x))` e `service.call(map(dto))` sono già troppo densi.
- **Un'istruzione che non entra in una riga chiede una variabile, non un ritorno a capo.** Se il wrap nasce da una chiamata dentro gli argomenti, estrai quel valore; se nasce solo dal numero di argomenti già nominati, il wrap va bene.
- Ammesso passare direttamente, elenco chiuso: accessor e getter semplici (`request.getId()`), costanti e letterali, argomenti di **chiamate di log** (`log.info`, `logger.debug`) e di **messaggi d'eccezione**, passaggi intermedi di una catena Stream, `return` di una sola chiamata.
- **L'eccezione sui messaggi non copre la costruzione di stringhe di output.** `String.format`, `printf`, `println`, `StringBuilder.append` e i formattatori applicativi sono chiamate ordinarie: i valori calcolati che ricevono hanno un nome come tutti gli altri.
- **Il cablaggio manuale di un grafo di oggetti non è esente.** Ogni collaboratore costruito riceve una variabile con un nome. Se la delega `this(...)` impedisce di dichiarare variabili prima della chiamata — in Java non sono ammesse istruzioni prima di `this(...)` — il cablaggio va in un metodo factory nominato, non annidato negli argomenti.
- Il nome della variabile può essere il concetto stesso in lowerCamelCase (`characteristicContribution`): non deve essere originale per guadagnarsi il posto.
- Evitare condizioni `if` complesse. Calcolare prima i blocchi logici significativi in variabili boolean con nomi di business, poi usare quei flag nel controllo di flusso.

### Perché
L'obiettivo non è codice più "furbo", ma codice meno denso e più facile da verificare. Una variabile locale che dà nome a un valore vale più delle righe che risparmia: il nome dice cosa è quel valore senza rileggere la firma del metodo che l'ha prodotto, e resta un punto dove fermarsi a leggere, a ispezionare e a mettere un breakpoint.

### Esempi completi
Cinque casi svolti con anti-esempio e versione corretta a confronto — annidamenti, densità delle chiamate, valore senza nome passato a un `add`, condizioni composte, early return più variabili esplicative: vedi [reference/examples.md](reference/examples.md).

## 17. SLAP e intenzionalità del codice

### Regola
- **Estrarre un metodo per dare un nome a un passo è una ragione sufficiente.** Il riuso non è richiesto: un metodo chiamato da un solo punto è legittimo quando il suo nome dice ciò che il corpo si capisce solo leggendolo. Vale **anche per una riga sola** o per una singola condizione (`if (isEligibleForPitStop(unit))`): il criterio è il nome, non la lunghezza del frammento.
- **Test di nominabilità — è la condizione dell'estrazione, non un dettaglio.** Si estrae se e solo se il frammento ha un nome nel linguaggio del dominio. Se il miglior nome disponibile è `processStep2()`, `handleData()`, `doCalculation()` o `applyPart1()`, il frammento **non è un concetto**: hai spezzato una frase a metà e obblighi il lettore a ricomporla saltando nel file. Il nome non è la ricompensa dell'estrazione, è il suo permesso.
- **Variabile o metodo**: a un *valore* si dà un nome con una variabile esplicativa (regola 16); a un *comportamento* o a un passo del flusso si dà un nome con un metodo estratto.
- Ogni metodo opera a **un solo livello di astrazione**: le operazioni al suo interno stanno allo stesso grado di dettaglio. Non mescolare la sequenza dei passi di alto livello con i dettagli che li realizzano.
- **Un metodo di orchestrazione si legge come l'elenco dei suoi passi**, e il file si legge dall'alto verso il basso: ogni metodo è seguito da quelli al livello di astrazione immediatamente inferiore. Tre proprietà lo rendono tale, e si verificano una per una guardando il corpo del metodo.
- **Una sola forma per riga.** Ogni passo è `Tipo nome = verbo(...)`. Rompono la forma, e vanno spostati *dentro* il passo: la creazione di un accumulatore mutabile, `x(...).ifPresent(lista::add)`, `lista.addAll(y(...))`, `List.copyOf(...)`, e l'**aritmetica nuda** (`a.add(b)`, `a + b`) quando le altre righe sono chiamate nominate. Il criterio è meccanico: se sei righe su otto hanno la forma `Tipo nome = verbo(...)`, le altre due la devono avere.
- **I nomi dei passi sono verbi, non sostantivi.** `mountEngine(chassis)`, non `engineMount(chassis)`; `calculateSurcharges(shipment)`, non `surcharges(shipment)`. Un sostantivo che si legge come una chiamata nomina il valore restituito invece dell'azione, e obbliga chi legge a ricostruire il verbo.
- **Uniformità: o tutti i passi sono chiamate incapsulate, o nessuno.** Il criterio non è vietare il collaboratore in assoluto, è la coerenza dentro il metodo. Se gli altri passi sono chiamate a metodi privati che nominano l'intenzione, anche `attackRollResolver.resolve(turn)` deve diventare `resolveAttackRoll(turn)`; se il metodo è fatto di istruzioni dirette, la chiamata diretta al collaboratore va bene. **Si conta, non si giudica**: quante righe sono chiamate incapsulate e quante espongono un campo iniettato, un tipo tecnico o un'API di collezioni o di `Optional`. Mescolate, è un rilievo. È questa la ragione per cui un metodo privato che sembra una delega pura — `mountEngine(chassis)` il cui corpo è `engine.mountEngine(chassis)` — **è legittimo e non ridondante**: il suo lavoro è tenere il corpo su un solo livello nascondendo l'identità del collaboratore. Vale anche quando il corpo è una riga sola.
- **Le guardie in testa al metodo non sono passi.** Una precondizione (`requireDefenderAlive(...)`, `Objects.requireNonNull(...)`) in cima si legge come preambolo e non entra nel conteggio dell'uniformità. Una guardia **in mezzo** ai passi sì: lì smette di essere un preambolo e diventa una riga di forma diversa dalle altre.
- **L'estrazione non deve creare stato condiviso.** Se per estrarre devi trasformare una variabile locale in un campo, l'estrazione è sbagliata: passa il valore o restituiscilo. Metodi privati che comunicano attraverso i campi impongono un ordine di chiamata che nessuna firma dichiara (regola 18).
- **Quando i metodi privati diventano molti, manca una classe, non un metodo.** Il segnale è che si raggruppano attorno a sottoinsiemi disgiunti dei campi: la risposta è un collaboratore nuovo, non un altro `private` (regola 7).
- Segnali di violazione: commenti che spezzano il metodo in fasi (`// Validazione`, `// Calcolo del totale`), un loop o un calcolo inline dentro un metodo che per il resto delega, literal di dominio (aliquote, formati, chiavi) accanto a chiamate di servizio.

### Perché
Mescolare i livelli obbliga chi legge a cambiare continuamente scala mentale e nasconde la sequenza del processo dentro i suoi dettagli. Estratto, il livello basso diventa testabile in isolamento e il livello alto si legge come la descrizione del processo. Questa regola è anche ciò che rende sostenibile il divieto di commenti della regola 4: l'etichetta di blocco vietata (`// Calcolo del totale`) va sostituita dal nome di un metodo, altrimenti il commento sparisce e non lo rimpiazza niente.

I nomi ufficiali dei pattern applicati: *Composed Method* (Beck, «dividi il programma in metodi che eseguono un compito identificabile, mantenendo tutte le operazioni allo stesso livello di astrazione»), *Extract Function* di Fowler, la cui motivazione dichiarata è separare l'intenzione dall'implementazione, la *stepdown rule* e «One Level of Abstraction per Function» di *Clean Code* cap. 3, e le *Intention-Revealing Interfaces* di Evans per la superficie pubblica.

### Esempi completi
Livelli mescolati contro sequenza di passi, estrazione di una condizione di una riga, il test di nominabilità applicato a un frammento che non lo supera, l'anti-esempio dei metodi privati che comunicano attraverso i campi, e le tre proprietà di un metodo che orchestra a confronto: vedi [reference/intenzionalita.md](reference/intenzionalita.md).

## 18. Numero di parametri

### Regola
- **La tendenza è zero.** Il conteggio ideale di parametri è nessuno, e ci si arriva iniettando dipendenze e configurazione nel **costruttore**, non accumulando nei campi i dati della singola chiamata. Un campo che trasporta lo stato di una chiamata è un parametro nascosto: crea accoppiamento temporale (`setCella()` prima di `percorri()`), sottrae un input alla firma e rende l'oggetto non riusabile fra chiamanti diversi. **Vietato.**
- **Da 1 a 6 parametri: normale.** Nessun rilievo, nessuna azione richiesta.
- **Da 7 in su: la firma va segnalata.** Non si scrive in silenzio. Vedi «Oltre il limite».
- **Oltre il limite non si tagliano parametri: si aggregano quelli che formano un concetto.** Il criterio per riconoscerli è il **data clump**: un gruppo di parametri che viaggia sempre insieme, tipicamente ripetuto in più di una firma, è un tipo che chiede di nascere.
- **Prima di creare un tipo nuovo**, verifica le vie più economiche: passare l'oggetto intero invece di due suoi campi (`cell` invece di `cell` + `cellLengthKm`); ricavare nel corpo un parametro derivabile dagli altri; **spostare il metodo nella classe che possiede già quei dati** — un conteggio alto dice spesso che il metodo è nel posto sbagliato, non che serve una classe in più.
- **Esenti dal limite**: costruttori canonici di `record`, value object e DTO; builder; firme imposte dall'esterno (implementazione di un'interfaccia di libreria, callback di framework, entry point).
- **Conteggio**: tutti i parametri dichiarati, un varargs conta 1. Indipendentemente dal numero, i flag booleani come parametro restano vietati e `Optional` come parametro resta vietato (regola 2).

### Oltre il limite
Quando la firma che stai scrivendo arriva a 7 parametri o più:
1. Individua i gruppi che viaggiano insieme e dai un nome di dominio a ciascuno.
2. Se il tipo aggregatore sta **dentro i file del task**, crealo, scrivi la firma corretta e **dichiara nell'output** cosa hai aggregato e perché.
3. Se la correzione richiede di toccare firme pubbliche o chiamanti **fuori dal perimetro del task**, non la applichi: scrivi la firma e riporta la proposta con impatto e costo.

Due firme reali con 11 e 7 parametri, il data clump che condividono e la versione aggregata: vedi [reference/parametri.md](reference/parametri.md).

### Perché
Il conteggio è il sintomo, il data clump è la malattia: una regola che vincola solo il numero insegna a impacchettare parametri estranei in un contenitore per scendere sotto la soglia, che è l'anti-pattern e non la cura. La scala di riferimento è quella di *Clean Code* cap. 3, «Function Arguments» (zero ideale, poi uno, poi due, tre da evitare); il tetto a 6 è la soglia di casa, fra il 3 di Martin e il 7 di `ParameterNumber` (Checkstyle) e `java:S107` (Sonar); il gruppo ripetuto in più firme è il test di Fowler per i «Data Clumps».


# Preferenze di output
Quando generi codice:
- privilegia leggibilità e semplicità
- evita soluzioni inutilmente dense o "furbe"
- usa strutture idiomatiche del linguaggio
- non introdurre pattern complessi senza motivo

# Vincoli
- **Mai `Optional` come parametro di metodo o costruttore, né come campo di classe**: solo come tipo di ritorno (regola 2, priorità molto alta)
- Non sacrificare correttezza per eleganza
- Non applicare refactoring che cambi il comportamento richiesto
- Non estrarre metodi che non hanno un nome nel linguaggio del dominio: il criterio è il test di nominabilità (regola 17), non la lunghezza del frammento né il numero di metodi privati
- **Mai scrivere in silenzio una firma con 7 o più parametri**: si aggregano i parametri che formano un concetto e si dichiara l'aggregazione, oppure si riporta la proposta se la correzione esce dal perimetro del task (regola 18)
- Non trasformare i dati di una chiamata in campi della classe per abbassare il conteggio dei parametri (regola 18)

# Esempi di attivazione
- "Scrivimi un service Spring Boot"
- "Rifattorizza questo metodo"
- "Migliora questo codice Java"
- "Genera una classe pulita e testabile"

# Esempi di non attivazione
- "Spiegami cos'è il clean code"
- "Riassumi questo file"
- "Traduci questo snippet"

# Nota finale
Questa skill guida lo stile e la struttura del codice generato.
Non sostituisce skill più specifiche per Java, Spring, Hibernate, testing o performance.
