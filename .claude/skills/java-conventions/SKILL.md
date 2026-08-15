---
name: java-conventions
description: Applica le convenzioni generali del linguaggio Java. Usa per qualsiasi task di scrittura o rifattorizzazione di codice Java. Copre struttura del file, import (niente wildcard, ordinati, static prima), naming (UpperCamelCase, lowerCamelCase, UPPER_SNAKE_CASE), ordinamento dei membri, Javadoc, espressività idiomatica, scelta di tipi e API, e la formattazione fine: spaziatura orizzontale, graffe K&R, line wrapping, una dichiarazione per riga, ordine dei modificatori, switch e annotazioni. Da comporre con clean-code e una skill java-version-* (11, 17 o 21). NON usare per linguaggi diversi da Java.
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
- Questa skill definisce convenzioni generali Java e deve comporsi con `clean-code`
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
- **Se scrivere il commento** lo decide `clean-code` §4, che vale anche qui: il default è **nessun commento e nessuna Javadoc**, nemmeno sui metodi e sui tipi pubblici. Questa sezione governa solo la **forma** del commento che ha già superato quel test.
- Non aggiungere Javadoc a un metodo pubblico solo perché è pubblico, e non aggiungerla mai agli helper privati.
- Quando la Javadoc è ammessa, documenta la sola parte di contratto non deducibile dalla firma; ometti i tag che non aggiungono niente: `@param order l'ordine` e `@return il risultato` si cancellano, non si compilano.
- Non lasciare tag vuoti (`@throws` senza condizione, `@param` senza descrizione) né tag su parametri che non esistono più.
- Non usare `/** ... */` per commenti interni al corpo di un metodo: la Javadoc documenta dichiarazioni.

### Perché
La Javadoc è una seconda descrizione del contratto, non verificata dal compilatore, che diverge alla prima modifica della firma. Ha senso solo dove dice qualcosa che la firma non può dire.

### Esempio corretto
```java
/**
 * @throws OptimisticLockException se l'ordine è stato modificato da un'altra transazione.
 */
public void confirm(Order order) {
```

### Anti-esempio
```java
/**
 * Calcola la data di scadenza.
 *
 * @param issueDate la data di emissione
 * @return la data di scadenza
 */
public LocalDate calculateDueDate(LocalDate issueDate) {
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

## 12. Spaziatura orizzontale

### Regola
Uno spazio singolo appare in questi punti, e NON altrove:
- dopo le keyword di controllo di flusso prima della `(`: `if`, `for`, `while`, `switch`, `try`, `catch`, `synchronized`
- prima della graffa aperta `{`
- attorno a ogni operatore binario e ternario, incluso `&` nei type bound (`<T extends Foo & Bar>`), `|` nel multi-catch (`catch (FooException | BarException e)`), i due punti del for-each (`for (String s : list)`), la freccia lambda (`str -> str.length()`)
- dopo `,` `;` `:` e dopo la `)` di un cast (`(String) value`)
- tra tipo e identificatore (`List<String> list`)
- attorno a `//` e tra `//` e il testo del commento

NON mettere spazio:
- tra nome di metodo/costruttore e la `(` degli argomenti: `save(order)`, non `save (order)`
- subito dopo `(` o prima di `)`: `foo(a, b)`, non `foo( a, b )`
- prima di `,` `;` `:`
- attorno a `.` e a method reference `::`
- prima delle quadre di indicizzazione: `array[i]`, non `array [i]`

### Perché
Le regole di spaziatura sono il livello di formattazione più visibile e più facilmente incoerente. Fissarle esplicitamente elimina un'intera classe di divergenze silenziose tra un file e l'altro.

### Esempio corretto
```java
if (customer.isActive()) {
  for (Order order : customer.getOrders()) {
    total = total + order.getAmount();
  }
}
```

### Anti-esempio
```java
if(customer.isActive()){
  for(Order order:customer.getOrders()){
    total = total+order.getAmount();
  }
}
```

## 13. Graffe in stile K&R

### Regola
- Nessun a-capo prima della graffa aperta; a-capo dopo `{`; a-capo prima di `}`
- A-capo dopo `}` solo se chiude un'istruzione, un metodo o una classe: `else`, `catch`, `finally` restano sulla stessa riga della graffa chiusa precedente
- Blocco vuoto ammesso come `{}` sulla stessa riga, ma non compattare i blocchi vuoti nei costrutti multi-blocco (`if/else`, `try/catch`) in modo da rompere la leggibilità della catena

### Perché
Uno stile di graffe coerente rende la struttura dei blocchi immediatamente leggibile e riduce i diff spuri quando il codice evolve.

### Esempio corretto
```java
if (condition) {
  doSomething();
} else {
  doOtherThing();
}
```

### Anti-esempio
```java
if (condition)
{
  doSomething();
}
else { doOtherThing(); }
```

## 14. Line wrapping

### Regola
- Preferire la rottura al livello sintattico più alto disponibile
- Spezzare **prima** di un operatore non di assegnazione (`+`, `&&`, `.`): il simbolo apre la riga successiva
- Spezzare **dopo** un operatore di assegnazione (`=`)
- Il nome di metodo/costruttore resta attaccato alla `(` che segue
- La virgola resta attaccata al token che la precede: si va a capo dopo la virgola, mai prima
- Le continuation lines sono indentate più delle righe di un normale blocco annidato, così "riga spezzata" e "nuovo blocco" restano visivamente distinti

⚠️ **Override delegato**: il **carattere e l'ampiezza dell'indentazione** (spazi vs tab, 2 vs 4) e il **limite di colonna** (80 / 100 / 120) dipendono dal progetto e sono governati dalle skill `springboot`, `liferay` o `java-version-*`. Questa sezione fissa il *principio* di wrapping, non i valori numerici. Restano fuori dal limite di colonna, a prescindere dal valore scelto: righe `package`/`import`, URL in Javadoc, text block.

### Perché
Il punto di rottura comunica la struttura dell'espressione. Regole di rottura coerenti rendono prevedibile dove cercare la continuazione di uno statement lungo.

### Esempio corretto
```java
List<String> activeCustomerNames = customers.stream()
    .filter(Customer::isActive)
    .map(Customer::getName)
    .collect(Collectors.toList());
```

## 15. Dichiarazioni, modificatori, array e literal

### Regola
- Una sola variabile per dichiarazione: `int a = 1;` su una riga, `int b = 2;` sulla successiva; mai `int a = 1, b = 2;` (eccezione ammessa: header del `for`)
- Ordine dei modificatori secondo la JLS: `public protected private abstract default static final transient volatile synchronized native strictfp`
- Le quadre appartengono al tipo: `String[] args`, non `String args[]`
- Suffisso dei literal `long` sempre `L` maiuscola: `3_000_000_000L`, mai `l`

### Perché
Sono convenzioni prive di ambiguità e senza costo di leggibilità: uniformarle elimina rumore gratuito nelle review.

### Esempio corretto
```java
public static final long MAX_SIZE = 2_000_000_000L;
String[] names = new String[0];
```

### Anti-esempio
```java
static public final long MAX_SIZE = 2000000000l;
String names[] = new String[0];
```

## 16. Switch

### Regola
- Le label `case`/`default` sono indentate di un livello dentro il blocco `switch`
- In uno `switch` statement old-style, ogni gruppo termina in modo brusco (`break`, `return`, `throw`, `continue`) oppure è marcato con un commento di fall-through esplicito (es. `// fall through`)
- Prevedere sempre un `default`, anche solo per lanciare un'eccezione su un caso non gestito

### Perché
Il `default` esplicito e i fall-through commentati rendono lo switch autodocumentante e proteggono da casi dimenticati quando l'enum o il dominio cresce.

### Esempio corretto
```java
switch (status) {
  case CREATED:
    return "Created";
  case SENT:
    return "Sent";
  default:
    throw new IllegalArgumentException("Unsupported status: " + status);
}
```

## 17. Posizione delle annotazioni

### Regola
- Le annotazioni su classe, metodo o costruttore vanno subito dopo l'eventuale Javadoc, ciascuna su una riga propria
- Eccezione: una singola annotazione senza parametri può stare sulla stessa riga della firma (es. `@Override public int hashCode() {`)
- Su un field, più annotazioni possono stare sulla stessa riga
- Le annotazioni type-use precedono immediatamente il tipo annotato (`final @Nullable String name`)

### Perché
Una annotazione per riga sulle dichiarazioni rende leggibile l'elenco quando cresce; l'eccezione per la singola annotazione senza parametri evita verbosità inutile sui casi banali come `@Override`.

### Esempio corretto
```java
@Override
public boolean equals(Object other) {
  return super.equals(other);
}
```

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
