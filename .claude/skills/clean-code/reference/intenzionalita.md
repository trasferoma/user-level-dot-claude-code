# Esempi operativi: SLAP e intenzionalità

## Indice
1. Livelli mescolati contro sequenza di passi
2. Estrarre una riga sola
3. Il test di nominabilità su un frammento che non lo supera
4. L'estrazione che crea stato condiviso
5. Le tre proprietà di un metodo che orchestra

## 1. Livelli mescolati contro sequenza di passi

### Anti-esempio

```java
public void processOrder(Order order) {
    // Validazione
    if (!order.isValid()) {
        throw new IllegalArgumentException("Invalid order");
    }

    // Calcolo del totale
    double total = 0.0;
    for (Item item : order.getItems()) {
        total += item.getPrice();
    }

    // Calcolo delle tasse
    double tax = total * 0.1;

    // Addebito sulla carta
    CreditCard creditCard = order.getCustomer().getCreditCard();
    creditCard.charge(total + tax);
}
```

I quattro commenti sono la prova della violazione: ognuno è il nome di un metodo che non è stato estratto.

### Esempio corretto

```java
public void processOrder(Order order) {
    validateOrder(order);

    double total = calculateTotal(order);
    double tax = calculateTax(total);
    double finalAmount = calculateFinalAmount(total, tax);

    chargeCreditCard(order.getCustomer(), finalAmount);
}
```

## 2. Estrarre una riga sola

Il riuso non serve e la lunghezza non conta: conta che la condizione abbia un nome invece di essere un'espressione da decifrare.

### Anti-esempio

```java
if (unit.tyreWearFraction() > 0.75 && horizon.lapsRemaining() > 4 && !unit.hasPitted()) {
    planPitStop(unit);
}
```

### Esempio corretto

```java
if (isEligibleForPitStop(unit, horizon)) {
    planPitStop(unit);
}

private boolean isEligibleForPitStop(DriverCarUnit unit, StintHorizon horizon) {
    return unit.tyreWearFraction() > 0.75 && horizon.lapsRemaining() > 4 && !unit.hasPitted();
}
```

## 3. Il test di nominabilità su un frammento che non lo supera

### Anti-esempio

```java
private void processStep2(Lap lap) {
    double base = lap.baseTimeSeconds();
    lap.setTimeSeconds(base + trafficPenalty(lap));
}
```

`processStep2` non è un nome: è un numero d'ordine. Il frammento non corrisponde a un concetto del dominio, quindi non andava estratto — oppure il concetto esiste e va trovato:

### Esempio corretto

```java
private void applyTrafficPenalty(Lap lap) {
    double base = lap.baseTimeSeconds();
    lap.setTimeSeconds(base + trafficPenalty(lap));
}
```

Se nessun nome del genere è disponibile, il frammento resta inline.

## 4. L'estrazione che crea stato condiviso

### Anti-esempio

```java
private double lapTimeSeconds;

private void computeLapTime(Lap lap) {
    this.lapTimeSeconds = lap.baseTimeSeconds() + trafficPenalty(lap);
}

private void recordLapTime(Lap lap) {
    lap.setTimeSeconds(this.lapTimeSeconds);
}
```

Due metodi con un bel nome, e un ordine di chiamata obbligatorio che nessuna firma dichiara: invertirli compila e produce un tempo sbagliato.

### Esempio corretto

```java
private double computeLapTimeSeconds(Lap lap) {
    return lap.baseTimeSeconds() + trafficPenalty(lap);
}
```

Il valore viaggia come parametro o come valore di ritorno, mai attraverso un campo.

## 5. Le tre proprietà di un metodo che orchestra

Forma unica per riga, nomi che sono verbi, nessun collaboratore visibile. L'anti-esempio funziona ed è già decomposto: il difetto è solo di leggibilità della procedura.

### Anti-esempio

```java
public OrderTotal calculateOrderTotal(Order order) {
    List<Discount> discounts = new ArrayList<>();
    loyaltyDiscount(order).ifPresent(discounts::add);
    volumeDiscount(order).ifPresent(discounts::add);
    discounts.addAll(couponDiscounts(order, couponCatalog));

    BigDecimal gross = lineTotalCalculator.calculate(order.getLines(), priceList);
    BigDecimal discountTotal = sumAmounts(discounts);
    BigDecimal net = gross.subtract(discountTotal);
    BigDecimal tax = taxCalculator.calculate(net, priceList.taxRate());
    BigDecimal payable = net.add(tax);

    return new OrderTotal(gross, discounts, net, tax, payable);
}
```

Nove righe e cinque forme diverse: creazione di un accumulatore, due `ifPresent(...::add)`, un `addAll`, quattro chiamate a collaboratori con i loro nomi in chiaro, tre operazioni aritmetiche nude. Tre nomi su quattro sono sostantivi (`loyaltyDiscount`, `volumeDiscount`, `couponDiscounts`). E `priceList` è configurazione trascinata come parametro riga per riga.

### Esempio corretto

```java
public OrderTotal calculateOrderTotal(Order order) {
    List<Discount> discounts = collectDiscounts(order);
    BigDecimal gross = calculateGrossAmount(order);
    BigDecimal discountTotal = sumDiscounts(discounts);
    BigDecimal net = calculateNetAmount(gross, discountTotal);
    BigDecimal tax = calculateTax(net);
    BigDecimal payable = calculatePayableAmount(net, tax);

    return new OrderTotal(gross, discounts, net, tax, payable);
}

private List<Discount> collectDiscounts(Order order) {
    List<Discount> discounts = new ArrayList<>();
    applyLoyaltyDiscount(order).ifPresent(discounts::add);
    applyVolumeDiscount(order).ifPresent(discounts::add);
    discounts.addAll(applyCouponDiscounts(order));
    return List.copyOf(discounts);
}

private BigDecimal calculateGrossAmount(Order order) {
    return lineTotalCalculator.calculate(order.getLines(), priceList);
}

private BigDecimal calculateNetAmount(BigDecimal gross, BigDecimal discountTotal) {
    return gross.subtract(discountTotal);
}
```

Sei righe, una forma sola, sei verbi, nessun collaboratore e nessuna aritmetica in vista. `collectDiscounts` raccoglie in un posto tutta la meccanica della collezione, che prima era spalmata sull'elenco dei passi. `calculateGrossAmount` e `calculateNetAmount` sembrano deleghe pure di una riga: lo sono, e il loro lavoro è esattamente quello — il primo nasconde `lineTotalCalculator`, il secondo dà il nome di dominio a una sottrazione. E `priceList`, essendo configurazione, è passata al costruttore e non più a ogni chiamata (regola 18).
