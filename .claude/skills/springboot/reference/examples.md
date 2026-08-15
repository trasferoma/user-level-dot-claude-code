# Esempi estesi: code style Spring

## Indice
- Organizzazione dei membri della classe (§4)
- Riferimenti a campi, metodi e utility classes (§7)

Ogni voce mostra la versione corretta e l'anti-esempio a confronto. Le regole e il «perché» stanno in `SKILL.md`.

---

## Organizzazione dei membri della classe (§4)

### Esempio corretto
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

### Anti-esempio
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


---

## Riferimenti a campi, metodi e utility classes (§7)

### Esempio corretto
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

### Anti-esempio
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

