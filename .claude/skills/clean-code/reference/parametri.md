# Esempi operativi: numero di parametri

Le due firme di partenza sono reali; i tipi aggregatori sono illustrativi e servono a mostrare il ragionamento, non a prescrivere quei nomi.

## 1. Firma a 11 parametri

### Anti-esempio

```java
private CellTraversalResult traverseConstrainedCell(Cell cell, double cellLengthKm,
        double exitSpeedCapMetersPerSecond, DriverCarUnit unit, DrivingObjective objective,
        StintHorizon horizon, double marginAtLapStart, PerformanceFactors performanceFactors,
        double budgetDifficultyUnits, CarState state, double nominalLostLimitFraction) {
```

Undici posizioni, sette delle quali sono `double` nudi: l'ordine degli argomenti non è verificabile dal compilatore e uno scambio fra `marginAtLapStart` e `budgetDifficultyUnits` compila e produce numeri plausibili.

### Gruppi che viaggiano insieme

| Gruppo | Concetto | Azione |
|--------|----------|--------|
| `cell` + `cellLengthKm` | la lunghezza è geometria della cella | *Preserve Whole Object*: si ricava da `cell`, non si passa |
| `exitSpeedCapMetersPerSecond` + `nominalLostLimitFraction` | i vincoli imposti alla percorrenza | `TraversalConstraints` |
| `unit` + `objective` + `horizon` | chi guida e con quale obiettivo sullo stint | `DrivingMandate` |
| `marginAtLapStart` + `budgetDifficultyUnits` | il margine disponibile e il suo consumo | `MarginBudget` |

### Esempio corretto

```java
private CellTraversalResult traverseConstrainedCell(Cell cell, TraversalConstraints constraints,
        DrivingMandate mandate, MarginBudget marginBudget, PerformanceFactors performanceFactors,
        CarState state) {
```

Sei posizioni, tutte con un tipo che nomina il proprio concetto. Nessuna aggregazione forzata: `performanceFactors` e `state` restano separati perché non formano un concetto comune con nient'altro nella firma.

## 2. Il data clump si riconosce dalla ripetizione

Nella stessa area di codice, un secondo metodo:

```java
public ForcingDecision decide(Cell cell, DriverCarUnit unit, DrivingObjective objective, StintHorizon horizon,
        double marginRemaining, double marginAtLapStart, double budgetDifficultyUnits) {
```

`cell`, `unit`, `objective`, `horizon`, `marginAtLapStart` e `budgetDifficultyUnits` sono **gli stessi sei** della firma precedente. Un gruppo che compare identico in due firme non è una coincidenza di chiamata: è un tipo che esiste già nel dominio e non è ancora stato dichiarato.

```java
public ForcingDecision decide(Cell cell, DrivingMandate mandate, MarginBudget marginBudget) {
```

`marginRemaining` entra in `MarginBudget` insieme agli altri due valori di margine, dove ha un nome e un invariante verificabile alla costruzione.

## 3. Criterio pratico

1. Conta i parametri. Fino a 6, si va avanti.
2. Da 7, cerca i gruppi che viaggiano insieme e verifica se compaiono anche in altre firme.
3. Prima di creare un tipo: si può passare l'oggetto intero? si può ricavare nel corpo? il metodo è nella classe giusta?
