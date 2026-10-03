# Esempi operativi: dipendenze

Caso svolto a supporto della § 8 di `SKILL.md`: dependency injection contro istanziazione diretta dentro la logica.

## Constructor injection

Le dipendenze arrivano dal costruttore e sono `final`. Il tempo è una dipendenza come le altre: iniettato, il comportamento diventa deterministico e testabile senza trucchi sull'orologio di sistema.

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

## Anti-esempio

L'implementazione concreta e l'orologio di sistema sono cablati dentro il metodo: la classe non è sostituibile, non è testabile in isolamento e nasconde le sue dipendenze a chi la legge dall'esterno.

```java
public class InvoiceService {

    public Invoice create(Invoice invoice) {
        InvoiceRepository invoiceRepository = new JdbcInvoiceRepository();
        invoice.setCreatedAt(LocalDateTime.now());
        return invoiceRepository.save(invoice);
    }
}
```

## Collaboratore statico contro collaboratore oggetto

Una classe di soli metodi statici non si sostituisce, non si sdoppia in un test, e rende ogni suo metodo pubblico un punto d'ingresso raggiungibile da chiunque — che è anche il motivo per cui i codebase tutti statici finiscono pieni di guardie difensive: senza un cablaggio che dica chi chiama chi, ogni metodo si difende da tutti.

### Anti-esempio

```java
public final class AmountRounding {

    private AmountRounding() {
    }

    public static BigDecimal round(BigDecimal amount) {
        return amount.setScale(2, RoundingMode.HALF_UP);
    }
}

public final class InvoiceTotalCalculator {

    private InvoiceTotalCalculator() {
    }

    public static BigDecimal total(Invoice invoice) {
        BigDecimal netAmount = sumOfLines(invoice);
        return AmountRounding.round(netAmount);
    }
}
```

`InvoiceTotalCalculator` è inchiodato a `AmountRounding`: la politica di arrotondamento non è sostituibile nemmeno quando ne serve una diversa, e chi legge la firma non vede da cosa dipende il risultato.

### Esempio corretto

```java
public class AmountRounding {

    private final RoundingMode roundingMode;
    private final int scale;

    public AmountRounding(RoundingMode roundingMode, int scale) {
        this.roundingMode = roundingMode;
        this.scale = scale;
    }

    public BigDecimal round(BigDecimal amount) {
        return amount.setScale(scale, roundingMode);
    }
}

public class InvoiceTotalCalculator {

    private final AmountRounding amountRounding;

    public InvoiceTotalCalculator(AmountRounding amountRounding) {
        this.amountRounding = amountRounding;
    }

    public BigDecimal total(Invoice invoice) {
        BigDecimal netAmount = sumOfLines(invoice);
        return amountRounding.round(netAmount);
    }
}
```

Un collaboratore che non ha dipendenze si istanzia comunque, e senza scrivere un costruttore: `new InvoiceLineParser()`. Il costo è una parola in più al punto di cablaggio; il guadagno è che la classe resta sostituibile e che chi la riceve dichiara di dipenderne.
