---
name: java-functional-style
description: Applica uno stile funzionale pragmatico quando SCRIVI o modifichi codice Java. Copre il pensare in trasformazioni (Stream per map/filter/group/aggregazioni semplici) invece che in mutazioni, funzioni pure e separazione dei side-effect (niente effetti dentro map/filter/flatMap/peek), immutabilità pragmatica (final e collezioni immutabili quando chiariscono un invariante), espressioni invece di statement, Optional come tipo di ritorno solo quando l'assenza è parte del contratto, lambda e method reference puri e leggibili, niente astrazioni funzionali premature. È guida alla scrittura, e si applica anche quando l'utente chiede esplicitamente di rifattorizzare un pezzo di codice in stile funzionale. Delega i vincoli di sintassi a java-version-11/17/21. Da comporre con clean-code e java-conventions. NON usare per linguaggi diversi da Java, né come revisione sistematica di codice che il task non tocca.
---

# Scopo
Guidare la generazione o modifica di codice Java verso uno stile funzionale pragmatico **al momento della scrittura**, così che il codice nasca già chiaro, testabile e con side-effect visibili, senza dover essere rifatto dopo.

Lo stile funzionale è uno strumento, non l'obiettivo. Un `for` leggibile che comunica bene l'intento vale più di uno `stream()` scritto solo per non usare un ciclo.

# Quando usare questa skill
Usa questa skill se:
- stai scrivendo o rifattorizzando codice Java e devi decidere come modellare trasformazioni di dati, gestione dell'assenza, immutabilità o side-effect
- il task produce codice Java che manipola collezioni, mappa DTO/entità, calcola o classifica valori
- vuoi separare logica pura (calcolo, decisione) dagli effetti (I/O, persistence, logging) per renderla testabile

Componila sempre con `clean-code` e `java-conventions`, e con la skill di versione attiva (`java-version-11`, `java-version-17` o `java-version-21`).

# Quando NON usare questa skill
Non usare questa skill se:
- il codice richiesto non è Java
- il task è di sola analisi, spiegazione o diagnosi senza produrre codice
- devi passare in rassegna codice Java già scritto e funzionante che il task corrente non tocca: non è una skill di revisione sistematica
- l'utente ha chiesto esplicitamente uno stile imperativo o un vincolo incompatibile

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore.
- Le regole di sicurezza e i vincoli globali hanno priorità superiore.
- Questa skill si compone con `clean-code` (base) e `java-conventions` (convenzioni di linguaggio) e non le sostituisce.
- I **vincoli di sintassi dipendenti dalla versione** (record, switch expression, text block, pattern matching, `Stream.toList()`) sono governati dalle skill `java-version-*`: se una tecnica funzionale suggerita qui non è disponibile nella versione target, prevale la skill di versione.
- In caso di conflitto con `springboot` o `liferay` su transazioni, boundary, persistence o stile di formattazione, prevale la skill più specifica.
- Correttezza e leggibilità prevalgono sempre sulla "purezza" funzionale.

# Obiettivi
Il codice Java generato deve:
- rendere esplicite le trasformazioni di dati e nascondere il meno possibile
- tenere i side-effect visibili e fuori dalle pipeline funzionali
- separare la logica deterministica dagli effetti, per renderla testabile senza mock inutili
- usare immutabilità dove riduce un rischio reale, non per moda
- restare idiomatico per uno sviluppatore Java medio del progetto, senza catene illeggibili

# Regole operative

## 1. Pensa in trasformazioni, non in mutazioni

### Regola
Per operazioni di **map, filter, grouping e aggregazioni semplici** su collezioni, preferisci una pipeline Stream a un loop che accumula in una collezione mutabile.
Mantieni invece il loop esplicito quando c'è: controllo di flusso complesso, più mutazioni coordinate, gestione di checked exception, early exit o dipendenza dall'ordine, side-effect centrali all'operazione, codice performance-critical, o punti di debug importanti.

### Perché
Una pipeline dichiarativa dice *cosa* si ottiene senza costringere il lettore a ricostruire lo stato passo passo. Ma un loop resta più onesto quando l'operazione è intrinsecamente imperativa: forzarla in uno stream la rende più difficile, non più chiara.

### Esempio corretto
```java
List<String> activeEmails = customers.stream()
        .filter(Customer::isActive)
        .map(Customer::getEmail)
        .filter(Objects::nonNull)
        .collect(Collectors.toList());
```

### Anti-esempio
```java
List<String> activeEmails = new ArrayList<>();
for (Customer customer : customers) {
    if (customer.isActive()) {
        String email = customer.getEmail();
        if (email != null) {
            activeEmails.add(email);
        }
    }
}
```

## 2. Funzioni pure e side-effect visibili

### Regola
Separa il **calcolo/decisione** (puro, deterministico) dagli **effetti** (I/O, persistence, chiamate remote, logging).
Non mettere side-effect dentro `map`, `filter`, `flatMap` o `peek`. Usa `forEach` solo quando l'effetto è esplicito e voluto; se l'effetto è la parte centrale dell'operazione, un loop esplicito comunica meglio.

### Perché
Le lambda di trasformazione lette da chi mantiene il codice sono assunte pure. Un effetto nascosto dentro `map` è un bug latente e rende la pipeline non riproducibile. Tenere il calcolo puro lo rende testabile senza infrastruttura.

### Esempio corretto
```java
List<Invoice> overdue = invoices.stream()
        .filter(invoice -> invoice.isOverdue(today))
        .collect(Collectors.toList());

for (Invoice invoice : overdue) {
    notificationGateway.notifyOverdue(invoice);
}
```

### Anti-esempio
```java
invoices.stream()
        .filter(invoice -> invoice.isOverdue(today))
        .peek(notificationGateway::notifyOverdue) // effetto nascosto nella pipeline
        .collect(Collectors.toList());
```

## 3. Immutabilità pragmatica

### Regola
Preferisci valori immutabili quando chiariscono una transizione di stato. Usa `final` sui locali solo quando marca un invariante reale o è già convenzione del progetto, non meccanicamente.
Restituisci collezioni immutabili come output quando è compatibile con framework, serializzazione e dominio. **Non** rendere immutabili collezioni gestite da Hibernate senza aver verificato lazy loading e dirty checking.

### Perché
L'immutabilità elimina una classe di bug (stato condiviso mutato). Ma applicata a oggetti gestiti dal framework rompe comportamenti attesi. Il valore sta nel ridurre un rischio concreto, non nell'aggiungere `final` ovunque.

### Esempio corretto
```java
BigDecimal net = calculateNet(gross, taxRate);
BigDecimal rounded = net.setScale(2, RoundingMode.HALF_UP);
return rounded;
```

## 4. Espressioni invece di statement

### Regola
Preferisci costrutti che **producono un valore** rispetto a mutare una variabile in rami separati: ternaria semplice, oppure switch expression se la versione target lo consente (`java-version-17`/`java-version-21`).
Non spingere fino alla densità: se l'espressione diventa difficile da leggere, torna a variabili intermedie con nome parlante (vedi anti-densità in `clean-code`).

### Perché
Un valore calcolato in un'unica espressione riduce le variabili mutabili e i rami che si dimenticano di assegnare. Ma un'espressione troppo densa sposta solo il problema: diventa un rebus.

### Esempio corretto (Java 11, ternaria)
```java
String displayName = (user != null) ? user.getDisplayName() : "anonymous";
```

### Esempio corretto (Java 17+, switch expression — solo se consentito dalla skill di versione)
```java
String label = switch (status) {
    case CREATED -> "Created";
    case SENT -> "Sent";
    case FAILED -> "Failed";
};
```

### Anti-esempio
```java
String displayName;
if (user != null) {
    displayName = user.getDisplayName();
} else {
    displayName = "anonymous";
}
```

## 5. Gestione dell'assenza e dell'errore

### Regola
Usa `Optional` **come tipo di ritorno** quando l'assenza è parte del contratto dell'API. Non usare `Optional` come campo di classe né come parametro di metodo.
Non introdurre `Optional` per sostituire un null-check locale banale. Non nascondere regole di business dentro catene `map`/`orElseGet` illeggibili: un `if` esplicito che rende visibile la regola è preferibile.
Per gli errori tecnici usa eccezioni significative (vedi `clean-code`): non mascherarli con `Optional.empty()` o `null` opachi.

### Perché
`Optional` comunica bene "questo valore può non esserci" all'uscita di un metodo. Usato come campo o parametro complica l'API senza guadagno. E una catena di `map`/`filter` che incapsula una regola di dominio la nasconde a chi legge.

### Esempio corretto
```java
public Optional<Customer> findActiveCustomer(long customerId) {
    return repository.findById(customerId)
            .filter(Customer::isActive);
}
```

### Anti-esempio
```java
public class OrderRequest {
    private Optional<String> couponCode; // Optional come campo: da evitare
}
```

## 6. Lambda e method reference leggibili

### Regola
Usa method reference quando è più leggibile della lambda equivalente (`Customer::getEmail` invece di `c -> c.getEmail()`).
Estrai un predicato o una funzione in un metodo con nome quando il nome espone l'intento. Le lambda di trasformazione e i predicati devono essere **puri**.
Non passare lambda solo per far sembrare generico codice superficialmente simile: è un'astrazione senza variazione stabile.

### Perché
Il method reference riduce rumore quando non c'è logica aggiuntiva. Un predicato con nome (`isEligibleForReminder`) è documentazione eseguibile. Una lambda impura o una finta generalizzazione aumentano solo il carico cognitivo.

### Esempio corretto
```java
List<Customer> eligible = customers.stream()
        .filter(this::isEligibleForReminder)
        .collect(Collectors.toList());

private boolean isEligibleForReminder(Customer customer) {
    return customer.isActive()
            && customer.getEmail() != null
            && !customer.isReminderDisabled();
}
```

### Anti-esempio
```java
List<Customer> eligible = customers.stream()
        .filter(c -> c.isActive() && c.getEmail() != null && !c.isReminderDisabled())
        .collect(Collectors.toList());
```

## 7. Niente astrazioni funzionali premature

### Regola
Non introdurre strategie a lambda solo per eliminare uno `switch` o una piccola duplicazione. Non creare `Function`/`BiFunction` di supporto prima che esista una variazione stabile e reale.
Non introdurre dipendenze funzionali esterne (Vavr, Reactor, jOOλ) se non sono già nel progetto e giustificate dal task.

### Perché
Un'astrazione creata prima che il punto di variazione sia stabile costa più di quanto renda: va mantenuta, capita e spesso disfatta. La duplicazione visibile è più economica di un'astrazione sbagliata.

## 8. Rispetto di versione Java, framework e persistence

### Regola
La scelta tra Stream/loop e la modellazione funzionale **non** deve violare i vincoli della versione target: per record, switch expression, text block, pattern matching e `Stream.toList()` rispetta la skill `java-version-*` attiva.
Nei contesti Spring Boot e Liferay non spostare logica oltre i boundary transazionali, non nascondere chiamate a repository o servizi remoti dentro trasformazioni generiche, e non introdurre stream paralleli in codice di request/transazione/persistence/sicurezza.
Con Hibernate/JPA evita pipeline che oscurano query N+1 o accesso al database.

### Perché
Uno stile funzionale che ignora versione, transazioni o lazy loading produce codice elegante e rotto. La compatibilità e la semantica del framework vengono prima dell'estetica.

# Preferenze di output
Quando generi codice Java in stile funzionale:
- privilegia pipeline corte e leggibili; spezza in variabili intermedie con nome quando la catena si allunga
- tieni i side-effect fuori dalle trasformazioni e visibili nel flusso
- preferisci funzioni pure e piccole con nome che espone l'intento
- usa `Optional` solo come valore di ritorno e solo quando l'assenza è contrattuale
- non sacrificare leggibilità, correttezza o semantica del framework per compattezza o purezza

# Vincoli
- Non usare feature di linguaggio non disponibili nella versione target (delega a `java-version-*`).
- Non nascondere side-effect dentro `map`, `filter`, `flatMap` o `peek`; non usare `peek` per logica di business.
- Non usare stream paralleli se non esplicitamente richiesto e dimostrato sicuro.
- Non usare `Optional` come campo o parametro.
- Non introdurre nuove dipendenze funzionali esterne.
- Non creare astrazioni funzionali speculative.
- Non trasformare un loop leggibile in una pipeline solo per evitare il `for`.
- Non applicare queste regole come revisione sistematica di codice già scritto e funzionante: la pipeline non prevede un passaggio di revisione funzionale automatico, e riscrivere in stile funzionale codice imperativo che nessuno ha chiesto di toccare è refactoring non richiesto (`clean-code` § 13).

# Dove si applica
Questa skill guida la **scrittura**: `clean-code-implementer` la seleziona mentre genera o modifica codice Java, così il codice nasce già in stile funzionale pragmatico. Si applica anche quando l'utente chiede esplicitamente di rifattorizzare un pezzo di codice in stile funzionale.

Fuori da questi due casi non si attiva da sola: la revisione a posteriori prevista dalla pipeline ha una lente diversa (collocazione delle responsabilità) e non passa da qui.

# Esempi di attivazione
- "Scrivi un mapper che converte queste entità in DTO"
- "Genera un service che filtra e aggrega questi ordini"
- "Rifattorizza questo metodo che accumula in una lista dentro un for"
- "Separa il calcolo puro dagli effetti in questo metodo Java"

# Esempi di non attivazione
- "Spiegami cos'è una funzione pura"
- "Scrivi la stessa logica in Kotlin"
- "Fai solo l'analisi, non scrivere codice"

# Nota finale
Questa skill definisce come scrivere codice Java in stile funzionale pragmatico.
Non sostituisce `clean-code` e `java-conventions` e non governa i vincoli di versione, delegati a `java-version-*`.
