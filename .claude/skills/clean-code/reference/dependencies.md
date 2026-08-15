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
