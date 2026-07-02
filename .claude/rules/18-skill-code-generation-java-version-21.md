---
id: skill-code-generation-java-version-21
title: Java 21 Code Generation
category: code-generation
priority: 95
version: 1.1
status: active
scope: java-21
supports:
  - skill-code-generation-clean-code
  - skill-code-generation-java-conventions
notes: Applica vincoli e preferenze specifiche per codice Java compatibile con Java 21.
---

# Scopo
Applicare vincoli e preferenze specifiche per la generazione o modifica di codice Java compatibile con Java 21.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede esplicitamente codice compatibile con Java 21
- il progetto target usa Java 21
- il codice deve restare compatibile con una baseline Java 21
- l'utente chiede di usare feature disponibili in Java 21 ma non necessariamente in Java 17

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede esplicitamente Java 11, Java 17 o una versione diversa
- l'utente chiede solo una spiegazione teorica senza codice
- il codice richiesto non è Java
- l'utente chiede esplicitamente l'uso di feature preview non abilitate

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `skill-code-generation-clean-code`
- Questa skill si compone con `skill-code-generation-java-conventions`
- In caso di conflitto con la skill Java generale, prevale questa skill sulle scelte dipendenti dalla versione
- In caso di conflitto con skill più specifiche per framework o librerie, prevale la skill più specifica solo se resta compatibile con Java 21

# Obiettivi
Il codice generato deve essere:
- compatibile con Java 21
- leggibile e idiomatico
- coerente con le convenzioni generali Java e con le regole di clean code
- libero da feature preview, salvo richiesta esplicita dell'utente
- capace di sfruttare in modo sobrio le feature stabili disponibili in Java 21

# Regole operative

## 1. Baseline del linguaggio
- Generare codice compatibile con Java 21
- Preferire costrutti stabili e pienamente supportati in Java 21
- Evitare qualunque scelta che richieda una versione superiore del linguaggio o l'abilitazione di preview feature, salvo richiesta esplicita

## 2. Feature consentite

### 1. Regola
- È consentito usare `var` per variabili locali quando il tipo resta immediatamente evidente
- È consentito usare switch expressions quando migliorano chiarezza e riducono rumore
- È consentito usare text blocks per stringhe multilinea leggibili
- È consentito usare record per modelli dati semplici, immutabili e trasparenti
- È consentito usare pattern matching per `instanceof` quando semplifica il codice
- È consentito usare sealed classes e sealed interfaces quando chiariscono e vincolano correttamente la gerarchia dei tipi
- È consentito usare pattern matching for `switch` quando migliora chiarezza, espressività e sicurezza
- È consentito usare record patterns quando semplificano destrutturazione e lettura del codice
- È consentito usare lambda, Stream API e Optional quando migliorano davvero la leggibilità

### 2. Perché
Java 21 offre feature stabili che possono ridurre boilerplate e branching inutile. Vanno usate quando rendono il codice più chiaro, non quando servono a far vedere che si conosce il catalogo delle novità.

### 3. Esempio corretto
```java
public record EmailMessage(String recipient, String subject, String body) {
}

public String describe(Object value) {
  return switch (value) {
    case String text -> "text: " + text;
    case Integer number -> "number: " + number;
    case null -> "missing";
    default -> "unsupported";
  };
}
```

## 3. Feature da NON usare di default

### 1. Regola
- Non usare string templates
- Non usare unnamed patterns
- Non usare unnamed variables
- Non usare unnamed classes o instance main methods
- Non usare altre feature preview senza richiesta esplicita dell'utente

### 2. Perché
Essere su Java 21 non significa che ogni feature associata all'ecosistema Java 21 sia automaticamente disponibile in forma stabile. Confondere feature stabili e preview è un modo molto efficiente per generare codice che non compila nel mondo reale.

### 3. Esempio corretto
```java
String message = "Customer " + customerId + " created successfully";
```

### 4. Anti-esempio
```java
String message = STR."Customer \{customerId} created successfully";
```

## 4. Preferenze di modellazione

### 1. Regola
- Per oggetti dati semplici e immutabili, preferire record rispetto a classi boilerplate tradizionali
- Per gerarchie chiuse e ben definite, valutare sealed classes o sealed interfaces
- Per stringhe multilinea leggibili, preferire text blocks rispetto a concatenazioni verbose
- Per logiche condizionali basate su pattern, valutare pattern matching for `switch` quando migliora chiarezza e manutenzione
- Per accesso strutturato ai componenti di un record, valutare record patterns quando riducono rumore e branching inutile

### 2. Perché
Queste feature permettono di modellare il dominio con meno rumore sintattico. Il vantaggio non è la modernità in sé, ma la riduzione del boilerplate nei casi giusti.

### 3. Esempio corretto
```java
public sealed interface PaymentResult permits PaymentAccepted, PaymentRejected {
}

public record PaymentAccepted(String authorizationCode) implements PaymentResult {
}

public record PaymentRejected(String reason) implements PaymentResult {
}

public String toMessage(PaymentResult result) {
  return switch (result) {
    case PaymentAccepted(String authorizationCode) -> "Accepted: " + authorizationCode;
    case PaymentRejected(String reason) -> "Rejected: " + reason;
  };
}
```

## 5. Uso di `var`

### 1. Regola
- Usare `var` solo quando il tipo è ovvio dal lato destro dell'assegnazione
- Non usare `var` se nasconde il tipo reale o peggiora la comprensione
- Non usare `var` come scelta automatica o ideologica
- Preferire il tipo esplicito quando migliora chiarezza semantica o manutenibilità

### 2. Perché
`var` è utile per eliminare ridondanza, non per nascondere il tipo. Quando costringe il lettore a risalire mentalmente alla firma del metodo o all'inferenza generica, il costo supera il beneficio.

### 3. Esempio corretto
```java
var command = new CreateOrderCommand(customerId, items);
OrderSummary summary = orderService.create(command);
```

### 4. Anti-esempio
```java
var result = load(configuration, strategy, context);
```

## 6. Uso di record

### 1. Regola
- Usare record solo per dati semplici, trasparenti e con semantica prevalentemente immutabile
- Non usare record quando il tipo ha logica mutabile significativa o comportamento dominante rispetto ai dati
- Evitare di forzare record dove una classe tradizionale è più chiara

### 2. Perché
I record sono eccellenti per DTO, messaggi, input e output semplici. Diventano una cattiva scelta quando il tipo è soprattutto comportamento, ciclo di vita o stato mutabile.

### 3. Esempio corretto
```java
public record CustomerDto(long id, String name, String email) {
}
```

### 4. Anti-esempio
```java
public record ShoppingCart(List<CartItem> items) {

  public void addItem(CartItem item) {
    items.add(item);
  }
}
```

## 7. Uso di sealed types

### 1. Regola
- Usare sealed classes o interfaces solo quando il dominio beneficia davvero di una gerarchia esplicitamente chiusa
- Preferire gerarchie tradizionali se il vincolo non aggiunge valore reale
- Mantenere chiaro il rapporto tra tipo sealed e permitted subclasses

### 2. Perché
Una gerarchia sealed comunica al compilatore e al lettore che l'insieme dei casi è chiuso. Se il dominio non è davvero chiuso, il vincolo diventa solo rigidità gratuita.

### 3. Esempio corretto
```java
public sealed interface ExportFormat permits CsvFormat, PdfFormat {
}

public final class CsvFormat implements ExportFormat {
}

public final class PdfFormat implements ExportFormat {
}
```

## 8. Uso di pattern matching for `switch`

### 1. Regola
- Usarlo solo quando riduce cast, `instanceof` ripetuti o branching dispersivo
- Non usarlo se un `if/else` o uno `switch` tradizionale risultano più leggibili
- Mantenere i casi chiari, non sovrapposti e facili da seguire
- Non trasformare un vantaggio espressivo in esibizione sintattica

### 2. Perché
Questa feature è molto utile quando il codice deve distinguere tra forme diverse dello stesso valore. Il guadagno reale è eliminare cast manuali e condizioni sparse, non aumentare la densità sintattica.

### 3. Esempio corretto
```java
public String normalizeValue(Object value) {
  return switch (value) {
    case String text -> text.trim();
    case Integer number -> Integer.toString(number);
    case Long number -> Long.toString(number);
    case null -> "";
    default -> throw new IllegalArgumentException("Unsupported value type: " + value.getClass().getName());
  };
}
```

### 4. Anti-esempio
```java
public String normalizeValue(Object value) {
  return switch (value) {
    case String text when text.isBlank() -> "";
    case String text -> text.trim();
    case Integer number -> Integer.toString(number);
    case Long number -> Long.toString(number);
    default -> String.valueOf(value);
  };
}
```

## 9. Uso di record patterns

### 1. Regola
- Usarli solo quando rendono più chiaro l'accesso ai componenti di un record
- Non usarli se introducono destrutturazioni troppo dense o difficili da leggere
- Preferire una destrutturazione lineare e comprensibile rispetto a pattern annidati inutilmente complessi

### 2. Perché
I record patterns sono ottimi quando evitano accessor ripetitivi e rendono evidenti i dati usati. Se però la destrutturazione si annida troppo, il codice torna a essere un rebus con le parentesi.

### 3. Esempio corretto
```java
public record Address(String city, String zipCode) {
}

public record Customer(String name, Address address) {
}

public String extractCity(Customer customer) {
  return switch (customer) {
    case Customer(String name, Address(String city, String zipCode)) -> city;
  };
}
```

## 10. API e librerie
- Preferire API standard compatibili con Java 21
- Non assumere la disponibilità di API introdotte in versioni successive
- Se una soluzione richiede funzionalità di versioni future o preview, sostituirla con un'alternativa stabile compatibile con Java 21

## 11. Compatibilità con le skill di base
- Usare `skill-code-generation-clean-code` come base predefinita
- Usare `skill-code-generation-java-conventions` per naming, import, formattazione e convenzioni generali
- Usare questa skill solo per vincoli e scelte specifiche della versione Java 21

# Preferenze di output
Quando generi codice Java 21:
- privilegia chiarezza e compatibilità
- usa feature moderne solo quando migliorano davvero il codice
- evita codice che sembri scritto per mostrare feature del linguaggio
- preferisci feature stabili rispetto a preview feature non richieste

# Vincoli
- Non usare preview feature senza richiesta esplicita
- Non usare feature introdotte dopo Java 21
- Non sacrificare leggibilità solo per usare una feature più moderna
- Se la compatibilità con Java 21 confligge con una convenzione più recente, prevale la compatibilità con Java 21

# Esempi di attivazione
- "Scrivimi una record class compatibile con Java 21"
- "Rifattorizza questo codice mantenendo compatibilità Java 21"
- "Usa pattern matching for switch ma resta su Java 21"
- "Scrivimi questa logica in Java 21"

# Esempi di non attivazione
- "Usa string templates"
- "Fammi vedere unnamed variables"
- "Genera codice Java 17"
- "Scrivimi una versione compatibile con Java 11"

# Nota finale
Questa skill definisce vincoli specifici per codice Java compatibile con Java 21.
Non sostituisce le skill generali di clean code e convenzioni Java, ma le specializza rispetto alla versione target.
