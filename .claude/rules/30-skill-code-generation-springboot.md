---
id: skill-code-generation-springboot
title: Spring Boot Code Generation
category: code-generation
priority: 97
version: 1.1
status: active
scope: spring-boot
supports:
  - skill-code-generation-clean-code
  - skill-code-generation-java-conventions
  - skill-code-generation-java-version-11
  - skill-code-generation-java-version-17
  - skill-code-generation-java-version-21
notes: Applica convenzioni Spring-style adattate alla generazione di codice Spring Boot, sulla base della code style del progetto Spring Framework.
---

# Scopo
Applicare convenzioni specifiche dell'ecosistema Spring alla generazione o modifica di codice Spring Boot.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di generare codice Spring Boot
- l'utente chiede componenti tipici Spring Boot come controller, service, configuration, repository, converter o utility
- l'utente chiede test Spring Boot o test di componenti Spring
- la risposta finale contiene codice Java fortemente legato a Spring Boot o al modello di sviluppo Spring

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede solo Java generico senza contesto Spring
- l'utente chiede solo una spiegazione teorica senza codice
- il codice richiesto non è Java
- l'utente richiede esplicitamente uno stile diverso da quello Spring-style
- il task riguarda esclusivamente convenzioni di versione Java, che devono essere governate da skill più specifiche

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `skill-code-generation-clean-code`
- Questa skill si compone con `skill-code-generation-java-conventions`
- In caso di conflitto con la skill Java generale, questa skill prevale sulle convenzioni specifiche Spring-style
- In caso di conflitto con una skill versione-specifica Java, la skill versione-specifica prevale sulle sole scelte dipendenti dalla compatibilità del linguaggio
- In caso di conflitto con skill più specifiche per sottodomini Spring, prevale la skill più specifica

# Obiettivi
Il codice Spring Boot generato deve essere:
- idiomatico per l'ecosistema Spring
- coerente con la style guide del progetto Spring Framework, dove applicabile
- leggibile, ordinato e facile da mantenere
- compatibile con le regole generali di clean code
- allineato a convenzioni di test e documentazione comunemente usate nei progetti Spring

# Regole operative

## 1. Struttura del file
- Usare UTF-8 per i file sorgente
- Usare line ending Unix (`LF`)
- Eliminare trailing whitespace
- Mantenere la struttura del file in questo ordine:
  1. eventuale header di licenza
  2. package
  3. import
  4. una sola top-level class, interface, enum o annotation
- Separare le sezioni del file con una sola riga vuota

## 2. Indentazione e formattazione
- Usare tab per l'indentazione, non spazi
- Applicare K&R style per i blocchi non vuoti
- Mantenere 90 caratteri come lunghezza preferita della riga
- Considerare accettabili linee tra 90 e 105 caratteri se migliorano leggibilità
- Evitare linee oltre 120 caratteri
- Quando si spezza una riga, mettere i separatori alla fine della riga corrente, non all'inizio di quella successiva
- Nei Javadoc, mirare a righe intorno a 80 caratteri

## 3. Import

### 1. Regola
- Non usare wildcard imports
- Organizzare gli import in questo ordine:
  1. `java.*`
  2. riga vuota
  3. `javax.*` e `jakarta.*`
  4. riga vuota
  5. tutti gli altri import
  6. riga vuota
  7. `org.springframework.*`
  8. riga vuota
  9. static import non-Spring
- Non usare static import nel production code, salvo casi limitati e molto chiari come costanti o static factory methods di DSL esterne
- Nei test, usare static import quando migliorano leggibilità, ad esempio per AssertJ
- Non usare static import wildcard neppure nei test

### 2. Perché
L'ordine degli import deve essere prevedibile e stabile. Riduce rumore nei diff, evita riordini casuali dell'IDE e rende subito visibile cosa appartiene al JDK, cosa al progetto e cosa a Spring.

### 3. Esempio corretto
```java
package com.example.orders;

import java.time.Clock;
import java.time.LocalDate;

import jakarta.validation.Valid;

import com.example.orders.domain.Order;
import com.example.orders.service.OrderService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
```

### 4. Anti-esempio
```java
package com.example.orders;

import static org.assertj.core.api.Assertions.*;
import org.springframework.web.bind.annotation.*;
import java.time.*;
import com.example.orders.service.OrderService;
import jakarta.validation.Valid;
```

## 4. Organizzazione dei membri

### 1. Regola
- Ordinare i membri della classe in modo naturale e spiegabile
- Usare come ordine preferenziale:
  1. static fields
  2. normal fields
  3. constructors
  4. private methods chiamati dai constructors
  5. static factory methods
  6. JavaBean properties
  7. metodi implementati da interfacce o superclassi
  8. template methods private o protected associati ai metodi pubblici
  9. altri metodi
  10. `equals`, `hashCode`, `toString`
- Posizionare i metodi di supporto immediatamente sotto il metodo che li usa, quando migliora leggibilità
- Non aggiungere nuovi setter o nuovi metodi semplicemente in fondo per ordine cronologico

### 2. Perché
L'ordine dei membri deve raccontare la classe. Se campi, costruttori e metodi sono sparsi in ordine cronologico di modifica, il file diventa un archivio di incidenti più che una struttura leggibile.

### 3. Esempio corretto
```java
@Service
public class InvoiceService {

	private static final String DEFAULT_CURRENCY = "EUR";

	private final InvoiceRepository invoiceRepository;
	private final Clock clock;

	public InvoiceService(InvoiceRepository invoiceRepository, Clock clock) {
		this.invoiceRepository = invoiceRepository;
		this.clock = clock;
	}

	public Invoice create(CreateInvoiceCommand command) {
		Invoice invoice = buildInvoice(command);
		return this.invoiceRepository.save(invoice);
	}

	private Invoice buildInvoice(CreateInvoiceCommand command) {
		return new Invoice(command.customerId(), this.clock.instant(),
				DEFAULT_CURRENCY);
	}
}
```

### 4. Anti-esempio
```java
@Service
public class InvoiceService {

	private final InvoiceRepository invoiceRepository;

	public Invoice create(CreateInvoiceCommand command) {
		return this.invoiceRepository.save(buildInvoice(command));
	}

	private static final String DEFAULT_CURRENCY = "EUR";

	private final Clock clock;

	private Invoice buildInvoice(CreateInvoiceCommand command) {
		return new Invoice(command.customerId(), this.clock.instant(),
				DEFAULT_CURRENCY);
	}

	public InvoiceService(InvoiceRepository invoiceRepository, Clock clock) {
		this.invoiceRepository = invoiceRepository;
		this.clock = clock;
	}
}
```

## 5. Blank lines e leggibilità strutturale
- Aggiungere due righe vuote prima di:
  - blocchi `static {}`
  - fields
  - constructors
  - inner classes
- Aggiungere una riga vuota dopo una method signature multilinea
- Non spezzare artificialmente elementi che appartengono insieme
- Il file deve sembrare scritto da un singolo autore coerente, non da una cronologia di commit sovrapposti

## 6. Naming
- Usare `CONSTANT_CASE` solo per vere costanti
- Non trattare ogni `static final` come costante se non lo è semanticamente
- Evitare nomi di variabile a singolo carattere
- Privilegiare nomi espliciti, soprattutto in codice infrastrutturale o framework-facing
- Mantenere coerenza tra ordine dei fields e ordine dei setter correlati

## 7. Riferimenti a campi, metodi e utility classes

### 1. Regola
- Riferire sempre i campi con `this`
- Non riferire i metodi con `this`
- Una utility class composta solo da metodi statici deve:
  - avere suffisso `Utils`
  - avere costruttore `private`
  - essere `abstract`

### 2. Perché
L'uso coerente di `this` sui campi aiuta a distinguere subito stato e variabili locali. Applicarlo anche ai metodi aggiunge rumore senza chiarire nulla. Le utility class vanno rese non istanziabili in modo esplicito.

### 3. Esempio corretto
```java
public abstract class HeaderUtils {

	private HeaderUtils() {
	}

	public static String normalize(String headerName) {
		return trimToNull(headerName);
	}

	private static String trimToNull(String value) {
		if (value == null) {
			return null;
		}
		return value.trim().isEmpty() ? null : value.trim();
	}
}

@Service
public class TokenService {

	private final TokenRepository tokenRepository;

	public TokenService(TokenRepository tokenRepository) {
		this.tokenRepository = tokenRepository;
	}

	public Token load(String tokenId) {
		return this.tokenRepository.findById(tokenId)
				.orElseThrow(() -> new IllegalArgumentException("tokenId must not be null"));
	}
}
```

### 4. Anti-esempio
```java
public final class HeaderUtils {

	public static String normalize(String headerName) {
		return HeaderUtils.trimToNull(headerName);
	}

	private static String trimToNull(String value) {
		return value == null ? null : value.trim();
	}
}

@Service
public class TokenService {

	private final TokenRepository tokenRepository;

	public TokenService(TokenRepository tokenRepository) {
		this.tokenRepository = tokenRepository;
	}

	public Token load(String tokenId) {
		return this.tokenRepository.findById(tokenId)
				.orElseThrow(this::buildException);
	}

	private IllegalArgumentException buildException() {
		return new IllegalArgumentException("tokenId must not be null");
	}
}
```

## 8. Null checks e contratti

### 1. Regola
- Quando serve una validazione programmatica esplicita di argomenti non null in codice Spring-style, preferire `Assert.notNull(...)`
- Quando serve verificare uno stato interno, preferire `Assert.state(...)`
- Formattare i messaggi come `Parameter must not be null` o `Value must not be null`, con il nome o identificatore prima e iniziale maiuscola
- Usare annotazioni di nullability solo se il progetto le adotta esplicitamente
- Se il progetto usa JSpecify/null-safety, mantenere coerenza tra package defaults e `@Nullable`

### 2. Perché
`Assert.notNull(...)` e `Assert.state(...)` esprimono bene l'intento nel contesto Spring. Separare validazione di input e controllo dello stato rende il contratto più chiaro e aiuta anche chi legge il codice a capire che tipo di violazione si è verificata.

### 3. Esempio corretto
```java
public class SessionService {

	public Session start(String userId) {
		Assert.notNull(userId, "userId must not be null");
		Assert.state(isGatewayAvailable(), "Gateway must be available");

		return new Session(userId);
	}

	private boolean isGatewayAvailable() {
		return true;
	}
}
```

### 4. Anti-esempio
```java
public class SessionService {

	public Session start(String userId) {
		if (userId == null) {
			throw new IllegalArgumentException("bad input");
		}
		if (!isGatewayAvailable()) {
			throw new IllegalStateException("bad state");
		}
		return new Session(userId);
	}

	private boolean isGatewayAvailable() {
		return true;
	}
}
```

## 9. Uso di annotazioni e override
- Aggiungere sempre `@Override` ai metodi che overrideano o implementano un metodo del supertipo
- Usare `@since` quando il contesto del progetto lo richiede per nuove API pubbliche o protette
- Non aggiungere annotazioni inutili o ridondanti che non portano valore reale

## 10. Ternary operator e stile espressivo

### 1. Regola
- Racchiudere il ternary operator tra parentesi
- Mettere la condizione non-null o positiva per prima, quando applicabile
- Non usare ternarie se peggiorano leggibilità
- Preferire codice lineare e facile da seguire rispetto a compattezza artificiale

### 2. Perché
La ternaria è utile per casi semplici e lineari. Senza parentesi e senza una condizione leggibile, però, diventa subito una micro-trappola sintattica, il passatempo preferito di chi confonde compattezza con qualità.

### 3. Esempio corretto
```java
public String resolveDisplayName(User user) {
	return (user != null ? user.getDisplayName() : "anonymous");
}
```

### 4. Anti-esempio
```java
public String resolveDisplayName(User user) {
	return user == null ? "anonymous" : user.isDeleted() ? "deleted" :
			user.getDisplayName();
}
```

## 11. Uso di `var`

### 1. Regola
- Non usare `var` nel production code Spring Boot
- È ammesso nei test solo se usato con coerenza e senza peggiorare la leggibilità
- Preferire il tipo esplicito o l'interfaccia nei punti di utilizzo

### 2. Perché
Nel production code Spring Boot la chiarezza del tipo conta più della brevità. Nei test il compromesso è più tollerabile, ma solo se il tipo resta ovvio e non costringe a inseguire l'inferenza con gli occhi.

### 3. Esempio corretto
```java
@Test
void shouldCreateInvoice() {
	var command = new CreateInvoiceCommand("customer-1");

	Invoice invoice = this.invoiceService.create(command);

	assertThat(invoice.customerId()).isEqualTo("customer-1");
}
```

### 4. Anti-esempio
```java
@Service
public class InvoiceService {

	public var create(var command) {
		var invoice = new Invoice(command.customerId());
		return this.invoiceRepository.save(invoice);
	}
}
```

## 12. Javadoc

### 1. Regola
- Usare uno stile imperativo nella prima frase
- Non inserire righe vuote tra descrizione e tag `@param`
- Se ci sono più paragrafi, iniziare ciascun paragrafo con `<p>`
- Se una descrizione di parametro va a capo, non indentare ulteriormente le linee successive
- Per Javadoc di classe:
  - includere `@since` quando il contesto del progetto lo richiede
  - usare l'ordine dei tag: `@author`, `@since`, `@param`, `@see`, `@deprecated`
- Per Javadoc di costruttori, metodi e campi, usare l'ordine:
  - `@param`, `@return`, `@throws`, `@since`, `@see`, `@deprecated`
- Usare `{@code}` per valori o frammenti di codice come `null`
- Se un tipo è citato solo in `{@link}`, preferire il nome fully qualified per evitare import inutili

### 2. Perché
La Javadoc in stile Spring deve essere uniforme e leggibile. Il primo periodo deve descrivere l'azione o il contratto, non divagare. L'ordine coerente dei tag evita file dove ogni classe sembra scritta da una tastiera diversa.

### 3. Esempio corretto
```java
/**
 * Create an {@link com.example.orders.api.OrderResponse} for the given order.
 * <p>Use this mapper only for REST output models.
 * @param order the source order
 * @return the mapped response
 */
public OrderResponse toResponse(Order order) {
	return new OrderResponse(order.id(), order.status());
}
```

### 4. Anti-esempio
```java
/**
 * This method is used to map the order.
 *
 * @return response
 * @param order input order
 */
public OrderResponse toResponse(Order order) {
	return new OrderResponse(order.id(), order.status());
}
```

## 13. Testing in stile Spring

### 1. Regola
- Per i test, usare JUnit Jupiter
- Terminare i nomi delle classi di test con suffisso `Tests`
- Usare AssertJ per le assertion
- Usare Mockito per mock e spy
- Nei test, gli static import sono incoraggiati quando migliorano leggibilità

### 2. Perché
Questa combinazione è coerente con l'ecosistema Spring moderno ed evita test scritti come un collage di stili. Static import mirati rendono le assertion più leggibili, mentre wildcard e mix casuali di framework peggiorano rapidamente il file.

### 3. Esempio corretto
```java
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class InvoiceServiceTests {

	private final InvoiceRepository invoiceRepository =
			Mockito.mock(InvoiceRepository.class);

	private final InvoiceService invoiceService =
			new InvoiceService(this.invoiceRepository, Clock.systemUTC());

	@Test
	void shouldLoadInvoice() {
		Invoice invoice = new Invoice("inv-1");
		when(this.invoiceRepository.findById("inv-1"))
				.thenReturn(Optional.of(invoice));

		Invoice result = this.invoiceService.load("inv-1");

		assertThat(result).isSameAs(invoice);
	}
}
```

## 14. Compatibilità con clean code e Java conventions
- Applicare sempre questa skill insieme a `skill-code-generation-clean-code`
- Applicare questa skill come specializzazione Spring-style sopra `skill-code-generation-java-conventions`
- Le convenzioni generali Java restano valide salvo override esplicito di questa skill
- Le scelte dipendenti dalla versione Java devono essere delegate alla skill versione-specifica attiva

# Preferenze di output
Quando generi codice Spring Boot:
- privilegia classi sobrie, focalizzate e ben organizzate
- usa convenzioni Spring-style coerenti con la code style ufficiale Spring
- evita sintassi “furba” che riduce leggibilità
- non usare `var` nel production code
- usa test con JUnit Jupiter, AssertJ e Mockito quando il task richiede test
- mantieni il codice coerente tra componenti Spring diversi

# Vincoli
- Non usare wildcard imports
- Non usare static imports nel production code salvo casi limitati e chiaramente giustificati
- Non usare `var` nel production code
- Non usare spazi al posto dei tab per l'indentazione in codice Spring-style
- Non superare 120 caratteri per riga
- Non introdurre convenzioni interne del team Spring Framework che dipendono da tool non presenti nel progetto, salvo richiesta esplicita
- Non assumere JSpecify, NullAway o `@since` come obbligo universale in ogni progetto Spring Boot: usarli solo se coerenti col contesto del progetto

# Esempi di attivazione
- "Scrivimi un service Spring Boot"
- "Genera un controller REST Spring Boot"
- "Crea una @Configuration Spring Boot"
- "Scrivimi un test per questo service Spring con AssertJ e Mockito"
- "Rifattorizza questa classe Spring Boot seguendo lo stile Spring"

# Esempi di non attivazione
- "Scrivimi una utility Java generica"
- "Dammi pseudocodice"
- "Spiegami cos'è Spring Boot"
- "Genera codice Kotlin con Spring"
- "Scrivimi solo SQL"

# Nota finale
Questa skill adatta alla generazione di codice Spring Boot le convenzioni ufficiali della code style del progetto Spring Framework.
Non sostituisce le skill generali di clean code, convenzioni Java o compatibilità di versione Java, ma le specializza per il contesto Spring.
