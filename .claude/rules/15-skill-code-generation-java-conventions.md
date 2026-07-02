---
id: skill-code-generation-java-conventions
title: Java Code Generation Conventions
category: code-generation
priority: 90
version: 1.2
status: active
scope: java
supports:
  - skill-code-generation-clean-code
notes: Applica convenzioni generali del linguaggio Java valide indipendentemente dalla versione target, salvo override di skill più specifiche.
---

# Scopo
Applicare convenzioni generali del linguaggio Java quando il modello genera o modifica codice sorgente Java.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di generare codice Java
- l'utente chiede di modificare o rifattorizzare codice Java
- l'utente chiede esempi, classi, metodi o test in Java
- la risposta finale contiene codice Java

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede solo una spiegazione teorica senza codice
- l'utente chiede codice in un linguaggio diverso da Java
- l'utente chiede pseudocodice o esempi volutamente agnostici rispetto al linguaggio
- esiste una skill più specifica per un sotto-contesto Java che impone regole incompatibili
- l'utente richiede esplicitamente uno stile diverso

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill prevale sulle skill generiche di code generation quando il codice richiesto è Java
- Questa skill definisce convenzioni generali Java e deve comporsi con `skill-code-generation-clean-code`
- In caso di conflitto con skill Java più specifiche per versione, framework, testing o persistence, prevale la skill più specifica
- Le scelte dipendenti dalla versione Java non devono essere governate da questa skill, ma da skill dedicate o da istruzioni esplicite

# Obiettivi
Il codice Java generato deve essere:
- idiomatico
- leggibile
- coerente con convenzioni Java ampiamente riconosciute
- facile da navigare e mantenere
- compatibile con le regole di clean code già definite altrove
- neutrale rispetto a feature non disponibili in tutte le versioni Java usate nel progetto

# Regole operative

## 1. Struttura del file

### Regola
- Generare una sola top-level declaration per file, salvo casi esplicitamente richiesti
- Usare un nome file coerente con il nome della top-level declaration
- Organizzare il file con questo ordine logico:
  1. eventuale header di licenza
  2. package
  3. import
  4. singola dichiarazione top-level
- Separare le sezioni del file con una riga vuota

### Perché
Una struttura prevedibile riduce il rumore, rende i file più facili da leggere e aiuta a trovare subito ciò che conta senza fare archeologia nel sorgente.

### Esempio corretto
```java
package com.example.invoice;

import java.math.BigDecimal;
import java.time.LocalDate;

public class InvoiceService {

  public Invoice create(BigDecimal amount, LocalDate dueDate) {
    return new Invoice(amount, dueDate);
  }
}
```

### Anti-esempio
```java
import java.math.BigDecimal;

package com.example.invoice;

public class InvoiceService {
  public Invoice create(BigDecimal amount, LocalDate dueDate) {
    return new Invoice(amount, dueDate);
  }
}
```

## 2. Encoding e caratteri

### Regola
- Assumere UTF-8 per i file sorgente
- Non usare tab per l'indentazione
- Usare caratteri Unicode reali solo quando migliorano davvero la leggibilità
- Evitare escape Unicode inutili o che rendono il codice meno comprensibile

### Perché
Il file deve restare leggibile e stabile su strumenti diversi. Quando la rappresentazione del testo diventa un problema, il codice smette di essere codice e comincia a sembrare una punizione amministrativa.

## 3. Import

### Regola
- Non usare wildcard imports
- Non spezzare gli import su più righe
- Raggruppare prima gli import static
- Raggruppare poi gli import non static
- Separare i due gruppi con una sola riga vuota
- Ordinare alfabeticamente gli import all'interno di ciascun gruppo
- Evitare import inutili o ridondanti
- Non usare static import per classi annidate statiche

### Perché
Import espliciti e ordinati rendono più chiaro da dove arrivano i simboli, riducono ambiguità e semplificano manutenzione e review.

### Esempio corretto
```java
import static java.util.stream.Collectors.toList;

import java.time.LocalDate;
import java.util.List;
```

### Anti-esempio
```java
import java.time.*;
import java.util.*;
import static java.util.stream.Collectors.*;
```

## 4. Indentazione e formattazione

### Regola
- Usare indentazione di 2 spazi
- Usare una istruzione per riga
- Mantenere il limite di 100 caratteri per riga quando ragionevolmente possibile
- Quando una riga va spezzata, preferire rotture su livelli sintattici alti
- Indentare le continuation lines in modo chiaro e coerente
- Non comprimere il codice per ridurre il numero di righe a scapito della leggibilità

### Perché
La formattazione non rende il codice giusto, ma rende molto più facile capire se è giusto. Che già sarebbe un progresso non banale.

## 5. Brace e blocchi

### Regola
- Usare sempre le brace con `if`, `else`, `for`, `do`, `while`
- Usare uno stile coerente per l'apertura e chiusura dei blocchi
- Evitare blocchi vuoti concisi nei costrutti multi-blocco come `try/catch` o `if/else`
- Mantenere la formattazione dei blocchi coerente in tutto il file

### Perché
Le brace esplicite riducono ambiguità e rendono più sicure le modifiche successive, soprattutto quando il codice evolve e qualcuno aggiunge una riga in più credendo di essere ancora al sicuro.

### Esempio corretto
```java
if (customer.isActive()) {
  sendNotification(customer);
}
```

### Anti-esempio
```java
if (customer.isActive())
  sendNotification(customer);
```

## 6. Ordinamento dei membri

### Regola
- Mantenere un ordine logico e spiegabile dei membri della classe
- Evitare di aggiungere nuovi metodi semplicemente in fondo per ordine cronologico
- Tenere gli overload contigui, senza altri membri in mezzo
- Mantenere vicini i membri che collaborano tra loro
- Separare chiaramente costanti, campi, costruttori e metodi

### Perché
L'ordine dei membri influenza la navigabilità della classe. Una classe ordinata racconta la propria struttura, una disordinata costringe a cercare i pezzi come se fossero sparsi sul pavimento.

### Esempio corretto
```java
public class PriceCalculator {

  private static final BigDecimal VAT_RATE = new BigDecimal("0.22");

  private final CurrencyService currencyService;

  public PriceCalculator(CurrencyService currencyService) {
    this.currencyService = currencyService;
  }

  public BigDecimal calculateGross(BigDecimal netAmount) {
    return netAmount.add(calculateVat(netAmount));
  }

  private BigDecimal calculateVat(BigDecimal netAmount) {
    return netAmount.multiply(VAT_RATE);
  }
}
```

## 7. Naming Java

### Regola
- Usare convenzioni standard Java:
  - classi, interfacce, enum, annotation: `UpperCamelCase`
  - metodi e variabili: `lowerCamelCase`
  - costanti: `UPPER_SNAKE_CASE`
  - package: minuscolo, senza caratteri inutili
- Usare nomi descrittivi e coerenti col dominio
- Evitare abbreviazioni opache, salvo convenzioni Java universalmente note
- Privilegiare nomi che rendano il codice comprensibile senza commenti aggiuntivi

### Perché
Le convenzioni di naming Java sono un contratto implicito con chi legge. Romperlo raramente produce originalità, di solito produce solo attrito.

## 8. Commenti e Javadoc

### Regola
- Scrivere commenti solo quando aggiungono contesto utile
- Preferire codice chiaro a commenti compensativi
- Usare Javadoc per API pubbliche quando chiarisce contratto, comportamento o vincoli
- Evitare commenti ovvi, ridondanti o rumorosi
- Aggiornare o rimuovere i commenti che non corrispondono più al codice

### Perché
Commenti e Javadoc servono a spiegare intenzioni, vincoli e contratti. Se descrivono solo ciò che il codice già dice, diventano rumore destinato a marcire.

### Esempio corretto
```java
/**
 * Restituisce la data di scadenza calcolata nel fuso orario applicativo.
 * Non usa il fuso del server per mantenere comportamento deterministico.
 */
public LocalDate calculateDueDate(LocalDate issueDate) {
  return issueDate.plusDays(30);
}
```

### Anti-esempio
```java
// Add 30 days to issueDate
public LocalDate calculateDueDate(LocalDate issueDate) {
  return issueDate.plusDays(30);
}
```

## 9. Espressività del codice

### Regola
- Preferire costrutti Java leggibili e idiomatici
- Non usare stream, lambda, ternarie o Optional se peggiorano la comprensione
- Usare la forma più semplice che mantenga chiarezza e correttezza
- Preferire variabili locali intermedie o metodi estratti rispetto a espressioni troppo dense
- Evitare catene troppo lunghe o costrutti che richiedano decodifica mentale inutile

### Perché
Essere moderni non significa comprimere tutto in una riga. Il codice deve essere letto molte più volte di quante venga scritto, che è una delle poche tragedie davvero costanti dell'ingegneria del software.

### Esempio corretto
```java
List<String> activeCustomerNames = customers.stream()
    .filter(Customer::isActive)
    .map(Customer::getName)
    .toList();
```

### Anti-esempio
```java
String result = customer != null ? customer.isActive()
    ? customer.getName() != null ? customer.getName().trim() : ""
    : ""
    : "";
```

## 10. Tipi e API Java

### Regola
- Usare le astrazioni standard del linguaggio in modo coerente
- Preferire interfacce nei punti di utilizzo quando migliora flessibilità e leggibilità
- Usare tipi concreti solo quando aggiungono reale valore semantico
- Evitare scelte inutilmente sofisticate o poco idiomatiche
- Favorire immutabilità e chiarezza delle responsabilità quando il contesto lo consente

### Perché
La scelta del tipo comunica intenzione. Dichiarare tutto con classi concrete senza motivo lega il codice a dettagli che spesso non interessano a chi lo usa.

### Esempio corretto
```java
List<String> customerNames = new ArrayList<>();
```

### Anti-esempio
```java
ArrayList<String> customerNames = new ArrayList<>();
```

## 11. Compatibilità con clean code

### Regola
- Applicare sempre questa skill insieme alle regole generali di clean code quando il task richiede codice Java
- Usare questa skill per le convenzioni specifiche del linguaggio
- Usare la skill clean code per responsabilità, testabilità, duplicazione, struttura e leggibilità generale
- Se una regola di clean code e una convenzione Java sono entrambe applicabili, devono essere composte e non trattate come alternative

### Perché
Questa skill definisce convenzioni Java, non sostituisce i principi generali di progettazione e leggibilità. Il linguaggio è il contenitore, il design resta il contenuto.

# Preferenze di output
Quando generi codice Java:
- privilegia codice idiomatico e sobrio
- evita soluzioni troppo compatte
- evita import inutili
- mantieni ordine e coerenza strutturale del file
- preferisci semplicità, leggibilità e convenzioni riconoscibili
- non introdurre feature di linguaggio solo per modernità apparente

# Vincoli
- Non sacrificare correttezza semantica per aderire rigidamente allo stile
- Non introdurre convenzioni Java non richieste se il contesto impone uno stile diverso
- Non usare feature di linguaggio o libreria che dipendono da una versione Java specifica se questa skill è usata da sola
- Se la versione target è rilevante, demandare le scelte dipendenti dalla versione a una skill Java più specifica
- Non degradare leggibilità e manutenibilità per rispettare formalismi marginali

# Esempi di attivazione
- "Scrivimi una classe Java che valida un input"
- "Rifattorizza questo service Java"
- "Scrivimi un test JUnit in Java"
- "Migliora questo codice Java"
- "Genera una utility Java leggibile e coerente"

# Esempi di non attivazione
- "Spiegami cos'è una record class"
- "Dammi pseudocodice per questo algoritmo"
- "Traduci questo snippet Java in Kotlin"
- "Scrivimi la stessa logica in Python"

# Nota finale
Questa skill definisce convenzioni generali per il codice Java.
Non introduce scelte dipendenti da versioni specifiche del linguaggio.
Non sostituisce skill più specifiche per versione Java, framework, librerie, test, persistence o performance.
