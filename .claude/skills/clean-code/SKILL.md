---
name: clean-code
description: Usa per generare codice nuovo, rifattorizzare, migliorare leggibilità o manutenibilità, qualsiasi task il cui output finale contiene codice. Applica regole di clean code quando generi o modifichi codice sorgente. Realizza metodi piccoli e focalizzati, naming chiaro, basso annidamento, dependency injection, gestione delle eccezioni, testabilità, anti-densità (early return, variabili esplicative, condizioni complesse spezzate in flag boolean). Da comporre con skill di linguaggio o framework (java-conventions, springboot, liferay).
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

## 2. Naming

### Regola
- Usare nomi espliciti e coerenti
- Evitare abbreviazioni oscure
- Privilegiare chiarezza rispetto a brevità inutile

### Perché
Un buon naming riduce la necessità di commenti e rende il codice comprensibile anche fuori dal contesto immediato.

## 3. Commenti

### Regola
- Commentare il perché, non il cosa
- Non usare commenti per compensare nomi o logica scadenti
- Evitare commenti ridondanti

### Perché
I commenti utili spiegano decisioni, vincoli o trade-off. I commenti che descrivono il codice riga per riga invecchiano in fretta e spesso peggiorano la leggibilità.

### Esempio corretto
```java
// Usiamo il clock applicativo per rendere il comportamento deterministico nei test.
LocalDate today = clock.today();
```

### Anti-esempio
```java
// Increment user count
userCount++;
```

## 4. Controllo di flusso

### Regola
- Ridurre i livelli di annidamento
- Evitare condizioni booleane difficili da leggere
- Estrarre predicati complessi in metodi con nome chiaro

### Perché
Un flusso poco annidato si legge più velocemente, si testa meglio e riduce gli errori introdotti da condizioni opache.

### Esempio corretto
```java
public void sendReminder(User user) {
    if (!canReceiveReminder(user)) {
        return;
    }

    notificationGateway.sendReminder(user);
}

private boolean canReceiveReminder(User user) {
    return user != null
            && user.isActive()
            && user.getEmail() != null
            && !user.isReminderDisabled();
}
```

### Anti-esempio
```java
public void sendReminder(User user) {
    if (user != null) {
        if (user.isActive()) {
            if (user.getEmail() != null && !user.isReminderDisabled()) {
                notificationGateway.sendReminder(user);
            }
        }
    }
}
```

## 5. Error handling

### Regola
- Preferire eccezioni significative a codici di ritorno opachi
- Non silenziare eccezioni
- Fornire messaggi di errore comprensibili

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

## 6. Classi

### Regola
- Una responsabilità principale
- Nome coerente con il ruolo
- Evitare classi contenitore con troppi compiti

### Perché
Una classe focalizzata è più semplice da comprendere, testare e modificare senza impatti collaterali.

## 7. Dipendenze

### Regola
- Preferire dependency injection
- Evitare creazione diretta di dipendenze dentro la logica
- Isolare framework e servizi esterni dietro boundary chiari

### Perché
Le dipendenze esplicite migliorano testabilità, sostituibilità e controllo del comportamento.

### Esempio corretto
```java
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final Clock clock;

    public InvoiceService(InvoiceRepository invoiceRepository, Clock clock) {
        this.invoiceRepository = invoiceRepository;
        this.clock = clock;
    }

    public Invoice create(Invoice invoice) {
        invoice.setCreatedAt(clock.now());
        return invoiceRepository.save(invoice);
    }
}
```

### Anti-esempio
```java
public class InvoiceService {

    public Invoice create(Invoice invoice) {
        InvoiceRepository invoiceRepository = new JdbcInvoiceRepository();
        invoice.setCreatedAt(LocalDateTime.now());
        return invoiceRepository.save(invoice);
    }
}
```

## 8. Duplicazione

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

## 9. Testabilità

### Regola
- Generare codice semplice da testare
- Evitare accoppiamenti inutili
- Favorire metodi deterministici e prevedibili

### Perché
Un codice testabile tende a essere anche più pulito, più modulare e meno dipendente dal contesto esterno.

# Preferenze di output
Quando generi codice:
- privilegia leggibilità e semplicità
- evita soluzioni inutilmente dense o "furbe"
- usa strutture idiomatiche del linguaggio
- non introdurre pattern complessi senza motivo

# Vincoli
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

---

# Esempi operativi (regole anti-densità)

Questi esempi guidano la generazione e modifica del codice quando il task richiede codice.
L'obiettivo non è codice più "furbo", ma codice più leggibile, meno denso e più facile da verificare.

## Linee guida operative
- Tenere il numero degli annidamenti il più basso possibile. Quando il flusso diventa complesso, usare early return, early continue oppure estrarre metodi privati con nomi chiari.
- Tenere bassa la densità del codice. Evitare di passare direttamente chiamate a metodo complesse come parametri di altri metodi. Recuperare prima i valori in variabili esplicative e poi passarli.
- Evitare condizioni `if` complesse. Calcolare prima i blocchi logici significativi usando variabili boolean con nomi di business, poi usare quei flag nel controllo di flusso.

---

## 1. Ridurre gli annidamenti

Preferire un flusso lineare con uscite anticipate rispetto a blocchi `if` annidati.
Se per capire il metodo bisogna seguire una scala di `if` dentro altri `if`, il metodo sta già chiedendo pietà.

### Anti-esempio

```java
public void processRequest(Request request) {
    if (request != null) {
        if (request.isEnabled()) {
            if (!request.isExpired()) {
                if (request.hasValidOwner()) {
                    validate(request);
                    execute(request);
                    notifyOwner(request);
                }
            }
        }
    }
}
```

### Esempio corretto

```java
public void processRequest(Request request) {
    if (!isProcessable(request)) {
        return;
    }

    validate(request);
    execute(request);
    notifyOwner(request);
}

private boolean isProcessable(Request request) {
    return request != null
            && request.isEnabled()
            && !request.isExpired()
            && request.hasValidOwner();
}
```

### Criterio pratico
Quando un metodo supera un livello di annidamento, valutare:
- invertire la condizione e uscire prima;
- estrarre un predicato privato;
- estrarre una fase del processo in un metodo dedicato;
- estrarre una nuova classe se emerge una responsabilità autonoma.

---

## 2. Abbassare la densità del codice

Non comprimere troppe operazioni in una singola riga o chiamata.
Le chiamate annidate nei parametri rendono il codice più difficile da leggere, debuggare e modificare.

### Anti-esempio

```java
protocolService.register(
        protocolRequestBuilder.build(
                practiceService.getPractice(request.getPracticeId()),
                userService.getUser(themeDisplay.getUserId()),
                documentService.getDocument(request.getDocumentId()),
                configurationProvider.getGroupConfiguration(groupId)));
```

### Esempio corretto

```java
Practice practice = practiceService.getPractice(request.getPracticeId());
User user = userService.getUser(themeDisplay.getUserId());
Document document = documentService.getDocument(request.getDocumentId());
GroupConfiguration configuration = configurationProvider.getGroupConfiguration(groupId);

ProtocolRequest protocolRequest = protocolRequestBuilder.build(
        practice,
        user,
        document,
        configuration);

protocolService.register(protocolRequest);
```

### Criterio pratico
Una chiamata può ricevere direttamente un metodo come parametro solo se il valore è immediato e ovvio.
Se il metodo chiamato recupera dati, costruisce oggetti, interroga servizi o applica logica, assegnare prima il risultato a una variabile esplicativa.

Un'eccezione tollerabile per casi banali:
```java
logger.info("Processing request {}", request.getId());
```

---

## 3. Evitare condizioni `if` complesse

Quando una condizione contiene più blocchi logici, calcolare prima ogni blocco con una variabile boolean dal nome chiaro.
Il nome della variabile deve spiegare il significato di business della condizione, non ripetere meccanicamente i campi usati.

### Anti-esempio

```java
if (request != null
        && request.getStatus() == RequestStatus.SUBMITTED
        && request.getOwnerId() == user.getUserId()
        && !request.isArchived()
        && permissionChecker.hasPermission(groupId, resourceName, request.getId(), ActionKeys.UPDATE)) {
    approve(request);
}
```

### Esempio corretto

```java
boolean isSubmittedRequest = request != null
        && request.getStatus() == RequestStatus.SUBMITTED;

boolean isOwnedByCurrentUser = request != null
        && request.getOwnerId() == user.getUserId();

boolean isEditableRequest = request != null
        && !request.isArchived();

boolean canUpdateRequest = permissionChecker.hasPermission(
        groupId,
        resourceName,
        request.getId(),
        ActionKeys.UPDATE);

if (isSubmittedRequest && isOwnedByCurrentUser && isEditableRequest && canUpdateRequest) {
    approve(request);
}
```

### Variante migliore quando la logica cresce

```java
public void approve(Request request, User user) {
    if (!canApprove(request, user)) {
        return;
    }

    approve(request);
}

private boolean canApprove(Request request, User user) {
    boolean isSubmittedRequest = request != null
            && request.getStatus() == RequestStatus.SUBMITTED;

    boolean isOwnedByCurrentUser = request != null
            && request.getOwnerId() == user.getUserId();

    boolean isEditableRequest = request != null
            && !request.isArchived();

    boolean canUpdateRequest = hasUpdatePermission(request);

    return isSubmittedRequest
            && isOwnedByCurrentUser
            && isEditableRequest
            && canUpdateRequest;
}
```

### Nota: niente boolean inutili per condizioni banali

```java
// NO - aggiunge burocrazia senza chiarire
boolean isActive = user.isActive();
if (isActive) {
    sendNotification(user);
}

// SI - già chiaro
if (user.isActive()) {
    sendNotification(user);
}
```

---

## 4. Combinare early return e variabili esplicative

### Anti-esempio

```java
public void download(Document document, User user) {
    if (document != null && user != null && document.isAvailable() && !document.isDeleted()) {
        if (user.isActive() && user.hasAcceptedTerms()) {
            if (permissionService.canDownload(user, document)) {
                streamDocument(document);
            }
        }
    }
}
```

### Esempio corretto

```java
public void download(Document document, User user) {
    if (!canDownload(document, user)) {
        return;
    }

    streamDocument(document);
}

private boolean canDownload(Document document, User user) {
    boolean isAvailableDocument = document != null
            && document.isAvailable()
            && !document.isDeleted();

    boolean isValidUser = user != null
            && user.isActive()
            && user.hasAcceptedTerms();

    if (!isAvailableDocument || !isValidUser) {
        return false;
    }

    return permissionService.canDownload(user, document);
}
```

Vantaggi:
- Il metodo pubblico resta leggibile.
- La logica di accesso ha un nome preciso: `canDownload`.
- Le condizioni sono divise in blocchi concettuali.
- L'annidamento viene eliminato.
- La chiamata costosa o esterna a `permissionService` avviene solo dopo i controlli locali.

---

## 5. Regola sintetica

Quando generi o modifichi codice:

1. Prima riduci l'annidamento.
2. Poi riduci la densità delle chiamate.
3. Poi assegna nomi chiari ai blocchi logici.
4. Poi valuta se estrarre metodi o classi.
5. Non rendere il codice più lungo se non diventa anche più leggibile.

Il codice corretto non deve sembrare compresso per risparmiare righe.
Deve sembrare facile da leggere, facile da testare e difficile da fraintendere.
