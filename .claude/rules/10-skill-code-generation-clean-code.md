---
id: skill-code-generation-clean-code
title: Clean Code for Code Generation
category: code-generation
priority: 80
version: 1.1
status: active
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
- evita soluzioni inutilmente dense o “furbe”
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
