---
name: clean-code
description: Usa per generare codice nuovo, rifattorizzare, migliorare leggibilità o manutenibilità, qualsiasi task il cui output finale contiene codice. Applica regole di clean code quando generi o modifichi codice sorgente. Realizza metodi piccoli e focalizzati, singola responsabilità per classe e per metodo (SRP, una sola ragione per cambiare), naming chiaro, basso annidamento, singolo livello di astrazione per metodo (SLAP), commenti e Javadoc quasi a zero (il default è non commentare, il commento è un'eccezione da giustificare), Optional solo come valore di ritorno e mai come parametro o campo, dependency injection, gestione delle eccezioni, testabilità, anti-densità (early return, variabili esplicative, condizioni complesse spezzate in flag boolean). Da comporre con skill di linguaggio o framework (java-conventions, springboot, liferay).
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
Quattro casi svolti con anti-esempio e versione corretta — classe che cresce a ogni feature, metodo che valida/trasforma/persiste, bassa coesione dei campi, frammentazione eccessiva: vedi [reference/srp.md](reference/srp.md).

## 8. Dipendenze

### Regola
- Preferire dependency injection
- Evitare creazione diretta di dipendenze dentro la logica
- Isolare framework e servizi esterni dietro boundary chiari

### Perché
Le dipendenze esplicite migliorano testabilità, sostituibilità e controllo del comportamento.

### Esempi completi
Constructor injection contro istanziazione diretta dentro la logica, con anti-esempio e versione corretta: vedi [reference/dependencies.md](reference/dependencies.md).

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
- Ammesso passare direttamente, elenco chiuso: accessor e getter semplici (`request.getId()`), costanti e letterali, argomenti di log e di messaggi d'eccezione, passaggi intermedi di una catena Stream, `return` di una sola chiamata.
- Il nome della variabile può essere il concetto stesso in lowerCamelCase (`characteristicContribution`): non deve essere originale per guadagnarsi il posto.
- Evitare condizioni `if` complesse. Calcolare prima i blocchi logici significativi in variabili boolean con nomi di business, poi usare quei flag nel controllo di flusso.

### Perché
L'obiettivo non è codice più "furbo", ma codice meno denso e più facile da verificare. Una variabile locale che dà nome a un valore vale più delle righe che risparmia: il nome dice cosa è quel valore senza rileggere la firma del metodo che l'ha prodotto, e resta un punto dove fermarsi a leggere, a ispezionare e a mettere un breakpoint.

### Esempi completi
Cinque casi svolti con anti-esempio e versione corretta a confronto — annidamenti, densità delle chiamate, valore senza nome passato a un `add`, condizioni composte, early return più variabili esplicative: vedi [reference/examples.md](reference/examples.md).

## 17. SLAP — Single Level of Abstraction Principle

### Regola
- Ogni metodo opera a un solo livello di astrazione: le operazioni al suo interno stanno allo stesso grado di dettaglio.
- Non mescolare la sequenza dei passi di alto livello con i dettagli che li realizzano: estrarre il dettaglio in metodi privati il cui nome dichiari l'intento.
- Un metodo di orchestrazione deve leggersi come l'elenco dei suoi passi.
- Segnali di violazione: commenti che spezzano il metodo in fasi (`// Validazione`, `// Calcolo del totale`), un loop o un calcolo inline dentro un metodo che per il resto delega, literal di dominio (aliquote, formati, chiavi) accanto a chiamate di servizio.

### Perché
Mescolare i livelli obbliga chi legge a cambiare continuamente scala mentale e nasconde la sequenza del processo dentro i suoi dettagli. Estratto, il livello basso diventa riutilizzabile e testabile in isolamento, e il livello alto si legge come la descrizione del processo.

### Esempio corretto
```java
public void processOrder(Order order) {
    validateOrder(order);

    double total = calculateTotal(order);
    double tax = calculateTax(total);
    double finalAmount = total + tax;

    chargeCreditCard(order.getCustomer(), finalAmount);
}
```

### Anti-esempio
```java
public void processOrder(Order order) {
    // Validazione
    if (!order.isValid()) {
        throw new IllegalArgumentException("Invalid order");
    }

    // Calcolo del totale
    double total = 0.0;
    for (Item item : order.getItems()) {
        total += item.getPrice();
    }

    // Calcolo delle tasse
    double tax = total * 0.1;

    // Addebito sulla carta
    CreditCard creditCard = order.getCustomer().getCreditCard();
    creditCard.charge(total + tax);
}
```


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
- Non frammentare il codice in troppi micro-metodi se peggiora la comprensione

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
