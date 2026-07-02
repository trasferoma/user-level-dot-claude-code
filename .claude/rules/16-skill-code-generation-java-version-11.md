---
id: skill-code-generation-java-version-11
title: Java 11 Code Generation
category: code-generation
priority: 95
version: 1.1
status: active
scope: java-11
supports:
  - skill-code-generation-clean-code
  - skill-code-generation-java-conventions
notes: Applica vincoli e preferenze specifiche per codice Java compatibile con Java 11.
---

# Scopo
Applicare vincoli e preferenze specifiche per la generazione o modifica di codice Java compatibile con Java 11.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede esplicitamente codice compatibile con Java 11
- il progetto target usa Java 11
- il codice deve restare compatibile con una baseline Java 11
- l'utente chiede di evitare feature introdotte in versioni successive

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede esplicitamente Java 17, Java 21 o una versione diversa
- il progetto target consente esplicitamente feature più moderne e l'utente vuole sfruttarle
- l'utente chiede solo una spiegazione teorica senza codice
- il codice richiesto non è Java

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `skill-code-generation-clean-code`
- Questa skill si compone con `skill-code-generation-java-conventions`
- In caso di conflitto con la skill Java generale, prevale questa skill sulle scelte dipendenti dalla versione
- In caso di conflitto con skill più specifiche per framework o librerie, prevale la skill più specifica solo se resta compatibile con Java 11

# Obiettivi
Il codice generato deve essere:
- compatibile con Java 11
- leggibile e idiomatico
- privo di feature introdotte in versioni successive
- coerente con le convenzioni generali Java e con le regole di clean code

# Regole operative

## 1. Baseline del linguaggio

### 1. Regola
- Generare codice compatibile con Java 11
- Preferire costrutti stabili e ampiamente supportati nella piattaforma Java 11
- Evitare qualunque scelta che richieda una versione superiore del linguaggio

### 2. Perché
La compatibilità con Java 11 è un vincolo tecnico, non un'opinione estetica. Un codice formalmente "bello" ma non compilabile sulla baseline reale del progetto è solo rumore costoso.

## 2. Feature consentite

### 1. Regola
- È consentito usare `var` per variabili locali quando il tipo resta immediatamente evidente
- È consentito usare `var` nei parametri di lambda esplicitamente tipizzati solo se migliora davvero leggibilità e coerenza
- È consentito usare lambda, Stream API, Optional e API introdotte prima o entro Java 11 quando migliorano chiarezza e qualità del codice

### 2. Perché
Java 11 supporta già molte feature utili. Il punto non è scrivere Java antico per nostalgia, ma usare bene ciò che esiste davvero senza sconfinare in versioni successive.

### 3. Esempio corretto
```java
var customers = customerRepository.findActiveCustomers();

List<String> emails = customers.stream()
    .map(Customer::getEmail)
    .filter(Objects::nonNull)
    .collect(Collectors.toList());
```

### 4. Eventuale anti-esempio
```java
var result = service.execute(request);
```

In questo caso `var` potrebbe nascondere un tipo poco ovvio o semanticamente importante. Se il tipo conta per capire il codice, meglio dichiararlo esplicitamente.

## 3. Feature da NON usare

### 1. Regola
- Non usare switch expressions
- Non usare text blocks
- Non usare record
- Non usare pattern matching for `instanceof`
- Non usare sealed classes o sealed interfaces
- Non usare pattern matching for `switch`
- Non usare altre feature di linguaggio introdotte dopo Java 11

### 2. Perché
Queste feature non esistono nella baseline Java 11. Inserirle in output "perché più moderne" significa generare codice sbagliato con un'aria molto sicura di sé, che è un vizio tipicamente umano.

### 3. Esempio corretto
```java
public String resolveStatusLabel(Status status) {
  switch (status) {
    case CREATED:
      return "Created";
    case SENT:
      return "Sent";
    case FAILED:
      return "Failed";
    default:
      throw new IllegalArgumentException("Unsupported status: " + status);
  }
}
```

### 4. Eventuale anti-esempio
```java
public String resolveStatusLabel(Status status) {
  return switch (status) {
    case CREATED -> "Created";
    case SENT -> "Sent";
    case FAILED -> "Failed";
  };
}
```

Questa è una switch expression, quindi non compatibile con Java 11.

## 4. Preferenze di modellazione

### 1. Regola
- Per oggetti dati semplici, usare classi tradizionali invece di record
- Per gerarchie di tipi, usare classi e interfacce classiche invece di sealed types
- Per costanti multilinea, usare concatenazione leggibile o builder appropriati invece di text blocks
- Per logiche condizionali, usare `switch` statement tradizionale o `if/else` quando appropriato

### 2. Perché
Quando mancano feature moderne, la soluzione non è simulare male la sintassi nuova. Bisogna scegliere l'alternativa più leggibile e idiomatica disponibile in Java 11.

### 3. Esempio corretto
```java
public class CustomerDto {

  private final String firstName;
  private final String lastName;

  public CustomerDto(String firstName, String lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
  }

  public String getFirstName() {
    return firstName;
  }

  public String getLastName() {
    return lastName;
  }
}
```

```java
String query = "SELECT id, first_name, last_name "
    + "FROM customer "
    + "WHERE active = true";
```

### 4. Eventuale anti-esempio
```java
public record CustomerDto(String firstName, String lastName) {
}
```

```java
String query = """
    SELECT id, first_name, last_name
    FROM customer
    WHERE active = true
    """;
```

`record` e text block non sono compatibili con Java 11.

## 5. Uso di `var`

### 1. Regola
- Usare `var` solo quando il tipo è ovvio dal lato destro dell'assegnazione
- Non usare `var` se nasconde il tipo reale o peggiora la comprensione
- Non usare `var` come scelta automatica o ideologica
- Preferire il tipo esplicito quando migliora leggibilità, manutenzione o chiarezza semantica

### 2. Perché
`var` può alleggerire il codice, ma può anche renderlo più opaco. In Java 11 è utile solo quando fa sparire ridondanza, non quando fa sparire informazione.

### 3. Esempio corretto
```java
var formatter = DateTimeFormatter.ISO_LOCAL_DATE;
var customers = new ArrayList<Customer>();
```

### 4. Eventuale anti-esempio
```java
var value = getConfiguration();
var response = execute();
var data = mapper.map(source);
```

Qui il tipo non è abbastanza evidente. Il lettore è costretto a inseguire il lato destro per capire di cosa si parla.

## 6. API e librerie

### 1. Regola
- Preferire API standard compatibili con Java 11
- Non assumere la disponibilità di metodi o classi introdotti in versioni successive
- Se una soluzione richiede API più recenti, sostituirla con un'alternativa compatibile con Java 11

### 2. Perché
La compatibilità non riguarda solo la sintassi del linguaggio. Anche usare una API standard introdotta più tardi rompe il vincolo, magari in modo meno evidente ma altrettanto fastidioso.

### 3. Esempio corretto
```java
List<String> names = stream.collect(Collectors.toList());
```

### 4. Eventuale anti-esempio
```java
List<String> names = stream.toList();
```

`Stream.toList()` è arrivato dopo Java 11, quindi qui va evitato.

## 7. Compatibilità con le skill di base

### 1. Regola
- Usare `skill-code-generation-clean-code` come base predefinita
- Usare `skill-code-generation-java-conventions` per naming, import, formattazione e convenzioni generali
- Usare questa skill solo per vincoli e scelte specifiche della versione Java 11

### 2. Perché
Questa skill non deve duplicare le regole generali. Serve a specializzarle per la baseline Java 11, non a reinventare tutto il mondo ogni volta.

# Preferenze di output
Quando generi codice Java 11:
- privilegia compatibilità e chiarezza
- preferisci sintassi consolidata a feature moderne non disponibili
- evita soluzioni che sembrano Java 17+ travestito da Java 11
- mantieni il codice semplice da compilare e mantenere in un progetto Java 11

# Vincoli
- Non usare feature di linguaggio introdotte dopo Java 11
- Non usare API standard introdotte dopo Java 11
- Non sacrificare leggibilità solo per restare aderente a una scelta stilistica marginale
- Se la compatibilità con Java 11 confligge con una convenzione più moderna, prevale la compatibilità con Java 11

# Esempi di attivazione
- "Scrivimi una classe compatibile con Java 11"
- "Rifattorizza questo codice mantenendo compatibilità Java 11"
- "Genera un DTO Java 11 senza record"
- "Scrivimi questa logica in Java 11"

# Esempi di non attivazione
- "Scrivimi una record class Java"
- "Usa sealed classes"
- "Fammi vedere una switch expression"
- "Genera codice Java 21"

# Nota finale
Questa skill definisce vincoli specifici per codice Java compatibile con Java 11.
Non sostituisce le skill generali di clean code e convenzioni Java, ma le specializza rispetto alla versione target.
