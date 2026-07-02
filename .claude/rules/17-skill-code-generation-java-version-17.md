---
id: skill-code-generation-java-version-17
title: Java 17 Code Generation
category: code-generation
priority: 95
version: 1.1
status: active
scope: java-17
supports:
  - skill-code-generation-clean-code
  - skill-code-generation-java-conventions
notes: Applica vincoli e preferenze specifiche per codice Java compatibile con Java 17.
---

# Scopo
Applicare vincoli e preferenze specifiche per la generazione o modifica di codice Java compatibile con Java 17.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede esplicitamente codice compatibile con Java 17
- il progetto target usa Java 17
- il codice deve restare compatibile con una baseline Java 17
- l'utente chiede di usare feature disponibili in Java 17 ma non necessariamente in Java 11

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede esplicitamente Java 11, Java 21 o una versione diversa
- l'utente chiede solo una spiegazione teorica senza codice
- il codice richiesto non è Java
- l'utente chiede esplicitamente l'uso di feature preview non abilitate

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `skill-code-generation-clean-code`
- Questa skill si compone con `skill-code-generation-java-conventions`
- In caso di conflitto con la skill Java generale, prevale questa skill sulle scelte dipendenti dalla versione
- In caso di conflitto con skill più specifiche per framework o librerie, prevale la skill più specifica solo se resta compatibile con Java 17

# Obiettivi
Il codice generato deve essere:
- compatibile con Java 17
- leggibile e idiomatico
- coerente con le convenzioni generali Java e con le regole di clean code
- libero da feature preview o dipendenze implicite da versioni successive, salvo richiesta esplicita

# Regole operative

## 1. Baseline del linguaggio
- Generare codice compatibile con Java 17
- Preferire costrutti stabili e pienamente supportati in Java 17
- Evitare qualunque scelta che richieda una versione superiore del linguaggio o l'abilitazione di preview feature

## 2. Feature consentite

### 1. Regola
- È consentito usare `var` per variabili locali quando il tipo resta immediatamente evidente
- È consentito usare switch expressions quando migliorano chiarezza e riducono rumore
- È consentito usare text blocks per stringhe multilinea leggibili
- È consentito usare record per modelli dati semplici, immutabili e trasparenti
- È consentito usare pattern matching per `instanceof` quando semplifica il codice
- È consentito usare sealed classes e sealed interfaces quando chiariscono e vincolano correttamente la gerarchia dei tipi
- È consentito usare lambda, Stream API e Optional quando migliorano davvero la leggibilità

### 2. Perché
Java 17 offre feature moderne stabili che possono ridurre boilerplate e rumore. Vanno però usate per chiarire il codice, non per trasformarlo in una sfilata di linguaggio moderno.

### 3. Esempio corretto
```java
public String toLabel(Status status) {
  return switch (status) {
    case CREATED -> "Created";
    case IN_PROGRESS -> "In progress";
    case COMPLETED -> "Completed";
  };
}
```

## 3. Feature da NON usare

### 1. Regola
- Non usare pattern matching for `switch`
- Non usare record patterns
- Non usare string templates
- Non usare unnamed patterns, unnamed variables o altre feature introdotte dopo Java 17
- Non usare preview feature senza richiesta esplicita dell'utente

### 2. Perché
Il codice deve compilare e restare coerente con una baseline Java 17 reale, non con una versione immaginaria o con flag speciali abilitati. Le preview feature creano fragilità inutile se non sono richieste esplicitamente.

### 3. Esempio corretto
```java
public String describe(Object value) {
  if (value instanceof String text) {
    return "String: " + text;
  }

  if (value instanceof Integer number) {
    return "Integer: " + number;
  }

  return "Unknown";
}
```

### 4. Anti-esempio
```java
public String describe(Object value) {
  return switch (value) {
    case String text -> "String: " + text;
    case Integer number -> "Integer: " + number;
    default -> "Unknown";
  };
}
```

## 4. Preferenze di modellazione

### 1. Regola
- Per oggetti dati semplici e immutabili, preferire record rispetto a classi boilerplate tradizionali
- Per gerarchie chiuse e ben definite, valutare sealed classes o sealed interfaces
- Per stringhe multilinea leggibili, preferire text blocks rispetto a concatenazioni verbose
- Per logiche condizionali basate su un valore, valutare switch expressions se migliorano chiarezza e compattezza

### 2. Perché
Java 17 permette di rappresentare meglio alcune intenzioni del dominio: dato semplice, gerarchia chiusa, testo multilinea, mapping da valore a risultato. Usare queste feature nei casi giusti rende il codice più esplicito e meno cerimonioso.

### 3. Esempio corretto
```java
public record CustomerSummary(long id, String name, String email) {
}
```

### 4. Anti-esempio
```java
public class CustomerSummary {

  private final long id;
  private final String name;
  private final String email;

  public CustomerSummary(long id, String name, String email) {
    this.id = id;
    this.name = name;
    this.email = email;
  }

  public long getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public String getEmail() {
    return email;
  }
}
```

## 5. Uso di `var`

### 1. Regola
- Usare `var` solo quando il tipo è ovvio dal lato destro dell'assegnazione
- Non usare `var` se nasconde il tipo reale o peggiora la comprensione
- Non usare `var` come scelta automatica o ideologica
- Preferire il tipo esplicito quando migliora chiarezza semantica o manutenibilità

### 2. Perché
`var` riduce rumore solo quando il tipo è evidente. Se costringe il lettore a decodificare l'espressione a destra per capire che cosa sta succedendo, allora sta peggiorando il codice invece di migliorarlo. Straordinario ma vero.

### 3. Esempio corretto
```java
var customerIds = new ArrayList<Long>();
var createdAt = LocalDateTime.now();
```

### 4. Anti-esempio
```java
var result = service.execute(request, configuration, retryPolicy);
```

## 6. Uso di record

### 1. Regola
- Usare record solo per dati semplici, trasparenti e con semantica prevalentemente immutabile
- Non usare record quando il tipo ha logica mutabile significativa o comportamento dominante rispetto ai dati
- Evitare di forzare record dove una classe tradizionale è più chiara

### 2. Perché
Un record comunica che il tipo è principalmente un contenitore di dati immutabili. Quando il comportamento diventa dominante o lo stato deve evolvere nel tempo, una classe tradizionale è più onesta e più leggibile.

### 3. Esempio corretto
```java
public record Money(BigDecimal amount, Currency currency) {
}
```

### 4. Anti-esempio
```java
public record ShoppingCart(List<Item> items) {

  public void addItem(Item item) {
    items.add(item);
  }

  public void clear() {
    items.clear();
  }
}
```

## 7. Uso di sealed types

### 1. Regola
- Usare sealed classes o interfaces solo quando il dominio beneficia davvero di una gerarchia esplicitamente chiusa
- Preferire gerarchie tradizionali se il vincolo non aggiunge valore reale
- Mantenere chiaro il rapporto tra tipo sealed e permitted subclasses

### 2. Perché
Un tipo sealed ha senso quando l'insieme delle varianti è noto, stabile e parte del modello. Se il dominio è aperto o destinato a crescere senza controllo centrale, il vincolo diventa solo una complicazione decorativa.

### 3. Esempio corretto
```java
public sealed interface PaymentResult
    permits PaymentSucceeded, PaymentRejected {
}

public record PaymentSucceeded(String authorizationCode) implements PaymentResult {
}

public record PaymentRejected(String reason) implements PaymentResult {
}
```

## 8. API e librerie

### 1. Regola
- Preferire API standard compatibili con Java 17
- Non assumere la disponibilità di API introdotte in versioni successive
- Se una soluzione richiede funzionalità di Java 21+, sostituirla con un'alternativa compatibile con Java 17

### 2. Perché
La compatibilità di versione non riguarda solo la sintassi. Anche le API standard devono essere realmente disponibili nella baseline target, altrimenti ottieni codice formalmente elegante e praticamente inutilizzabile.

### 3. Esempio corretto
```java
List<String> names = stream.collect(Collectors.toUnmodifiableList());
```

## 9. Compatibilità con le skill di base
- Usare `skill-code-generation-clean-code` come base predefinita
- Usare `skill-code-generation-java-conventions` per naming, import, formattazione e convenzioni generali
- Usare questa skill solo per vincoli e scelte specifiche della versione Java 17

# Preferenze di output
Quando generi codice Java 17:
- privilegia chiarezza e compatibilità
- usa feature moderne solo quando migliorano davvero il codice
- evita codice che sembri scritto per mostrare feature del linguaggio
- preferisci sintassi stabile rispetto a preview feature non richieste

# Vincoli
- Non usare feature preview senza richiesta esplicita
- Non usare feature introdotte dopo Java 17
- Non sacrificare leggibilità solo per usare una feature più moderna
- Se la compatibilità con Java 17 confligge con una convenzione più recente, prevale la compatibilità con Java 17

# Esempi di attivazione
- "Scrivimi una record class compatibile con Java 17"
- "Rifattorizza questo codice mantenendo compatibilità Java 17"
- "Usa sealed classes ma resta su Java 17"
- "Scrivimi questa logica in Java 17"

# Esempi di non attivazione
- "Fammi vedere pattern matching for switch"
- "Genera codice Java 21"
- "Scrivimi una versione compatibile con Java 11"
- "Usa feature preview"

# Nota finale
Questa skill definisce vincoli specifici per codice Java compatibile con Java 17.
Non sostituisce le skill generali di clean code e convenzioni Java, ma le specializza rispetto alla versione target.
