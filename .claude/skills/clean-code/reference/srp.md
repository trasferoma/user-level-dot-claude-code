# Esempi operativi: singola responsabilità (SRP)

## Indice
- Come si legge una violazione
- 1. Classe che cresce a ogni feature
- 2. Metodo che valida, trasforma e persiste
- 3. Bassa coesione: campi usati solo da metà dei metodi
- 4. Separazioni da NON fare

---

Il criterio di separazione è sempre lo stesso: **quante ragioni distinte esistono per modificare questa unità**.
Non il numero di righe, non il numero di metodi, non l'eleganza dell'acronimo.

## Come si legge una violazione

Per ogni classe, prova a completare la frase: «Questa classe cambia quando cambia ______».
Se devi usare una congiunzione, hai due classi.

- «`InvoiceService` cambia quando cambiano le regole di calcolo dell'imponibile» → una ragione.
- «`InvoiceService` cambia quando cambiano le regole di calcolo **e** quando cambia il formato del PDF **e** quando cambia il provider di posta» → tre ragioni, tre committenti diversi, tre motivi per rompere le altre due.

---

## 1. Classe che cresce a ogni feature

Il caso più frequente non nasce da una decisione di design: nasce dall'aggiungere alla classe che c'è già,
perché è già iniettata e perché aprire un file nuovo sembra sproporzionato.

### Anti-esempio

```java
@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final JavaMailSender mailSender;
    private final PdfRenderer pdfRenderer;
    private final ExchangeRateClient exchangeRateClient;

    public Order placeOrder(OrderRequest request) {
        validateRequest(request);

        Order order = new Order();
        order.setCustomerId(request.getCustomerId());
        order.setAmount(convertToBaseCurrency(request.getAmount(), request.getCurrency()));
        orderRepository.save(order);

        byte[] confirmationPdf = pdfRenderer.render("order-confirmation", order);
        sendConfirmationMail(order, confirmationPdf);

        return order;
    }

    private BigDecimal convertToBaseCurrency(BigDecimal amount, String currency) { ... }

    private void sendConfirmationMail(Order order, byte[] attachment) { ... }
}
```

Ragioni per cambiare: regole d'ordine, cambio valuta, layout del PDF, configurazione della posta.
Quattro committenti diversi sullo stesso file, e un test del calcolo d'ordine che deve mockare
il mail sender e il renderer.

### Esempio corretto

```java
@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final CurrencyConverter currencyConverter;
    private final OrderConfirmationNotifier confirmationNotifier;

    public Order placeOrder(OrderRequest request) {
        validateRequest(request);

        BigDecimal baseAmount = currencyConverter.toBaseCurrency(request.getAmount(), request.getCurrency());
        Order order = orderRepository.save(newOrder(request, baseAmount));

        confirmationNotifier.notifyPlacedOrder(order);

        return order;
    }
}
```

`OrderConfirmationNotifier` incapsula rendering e invio: chi cambia il layout del PDF non tocca più
la logica d'ordine. Il nome è di business (§ «Preferenze sempre attive» del progetto), non `OrderHelper`.

---

## 2. Metodo che valida, trasforma e persiste

Vale per i metodi quanto per le classi. Tre attività con tre ragioni di cambiare distinte
— regole di business, formato dei dati, schema di persistenza — non stanno nello stesso corpo.

### Anti-esempio

```java
public void importCustomer(CustomerCsvRow row) {
    if (row.getVatNumber() == null || row.getVatNumber().length() != 11) {
        throw new IllegalArgumentException("Invalid VAT number");
    }
    if (row.getEmail() == null || !row.getEmail().contains("@")) {
        throw new IllegalArgumentException("Invalid email");
    }

    Customer customer = new Customer();
    customer.setVatNumber(row.getVatNumber().trim().toUpperCase());
    customer.setEmail(row.getEmail().trim().toLowerCase());
    customer.setRegisteredAt(LocalDateTime.now());

    customerRepository.save(customer);
}
```

### Esempio corretto

```java
public void importCustomer(CustomerCsvRow row) {
    customerRowValidator.validate(row);

    Customer customer = customerRowMapper.toCustomer(row, clock.now());

    customerRepository.save(customer);
}
```

Il metodo si legge come la sequenza dei suoi passi (SLAP, § 17), ogni passo è testabile in isolamento,
e una regola di validazione nuova non tocca il codice di mapping.

---

## 3. Bassa coesione: campi usati solo da metà dei metodi

Quando un sottoinsieme di campi serve solo a un sottoinsieme disgiunto di metodi,
la classe è già due classi che condividono un file.

### Anti-esempio

```java
public class ReportService {

    // usati solo da generateMonthlyReport
    private final ReportRepository reportRepository;
    private final TemplateEngine templateEngine;

    // usati solo da purgeExpiredReports
    private final ArchiveClient archiveClient;
    private final RetentionPolicy retentionPolicy;

    public Report generateMonthlyReport(YearMonth month) { ... }

    public void purgeExpiredReports() { ... }
}
```

Generazione e retention non cambiano mai insieme e non condividono un solo campo.
Sono `MonthlyReportGenerator` e `ReportRetentionService`.

---

## 4. Separazioni da NON fare

SRP è un criterio, non una quota di file da riempire. Non separare quando:

- **Le due parti cambiano sempre insieme.** Un mapper usato da un solo service e modificato
  a ogni modifica di quel service non ha una ragione di cambiare propria: è la stessa responsabilità.
- **L'estrazione produce una classe di passaggio** che si limita a inoltrare la chiamata
  a un collaboratore, senza aggiungere né decisione né nome utile.
- **La seconda responsabilità è ipotetica.** Estrai quando la seconda ragione di cambiare è già
  visibile nel codice presente, non perché «un giorno potremmo avere anche…» (§ 11 Open/Closed, § 13 Refactoring).
- **Il task non tocca quella parte.** La collocazione sbagliata che esisteva già va segnalata,
  non risolta dentro un diff che doveva fare altro (§ 13, refactoring vietato).

### Anti-esempio di frammentazione

```java
// Una classe per operazione: l'acronimo è soddisfatto, il lettore no.
public class OrderAmountCalculator { ... }
public class OrderAmountRounder { ... }
public class OrderAmountFormatter { ... }
```

Arrotondamento e formattazione dell'importo cambiano insieme al calcolo: è un'unica responsabilità
distribuita su tre file, tre iniezioni e tre test per un comportamento solo.
