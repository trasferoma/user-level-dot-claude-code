# Esempi operativi: lambda al posto delle classi anonime

Caso svolto a supporto della § 7 di `SKILL.md`: un `enum` in cui ogni costante porta la propria regola.

## Anti-esempio — constant-specific class body

```java
public enum CombatInvariant {

    DAMAGE_APPLIED_NOT_NEGATIVE("Il danno applicato non può essere negativo") {
        @Override
        public boolean isSatisfiedBy(TurnOutcome outcome) {
            return outcome.damageApplied() >= 0;
        }
    },
    MISS_IMPLIES_NO_DAMAGE("Un esito MISS non deve applicare alcun danno") {
        @Override
        public boolean isSatisfiedBy(TurnOutcome outcome) {
            return outcome.hitOutcome() != HitOutcome.MISS || outcome.damageApplied() == 0;
        }
    };

    private final String description;

    CombatInvariant(String description) {
        this.description = description;
    }

    public abstract boolean isSatisfiedBy(TurnOutcome outcome);
}
```

Una sottoclasse anonima per costante, quindi un `.class` in più ciascuna. E la dichiarazione
`public abstract boolean isSatisfiedBy(...)` sta **sotto** tutte le implementazioni che la
realizzano: chi legge scopre il contratto dopo averne visto le realizzazioni.

## Esempio corretto

```java
public enum CombatInvariant {

    DAMAGE_APPLIED_NOT_NEGATIVE(
            "Il danno applicato non può essere negativo",
            outcome -> outcome.damageApplied() >= 0),

    MISS_IMPLIES_NO_DAMAGE(
            "Un esito MISS non deve applicare alcun danno",
            outcome -> outcome.hitOutcome() != HitOutcome.MISS || outcome.damageApplied() == 0);

    private final String description;
    private final Predicate<TurnOutcome> rule;

    CombatInvariant(String description, Predicate<TurnOutcome> rule) {
        this.description = description;
        this.rule = rule;
    }

    public String description() {
        return description;
    }

    public boolean isSatisfiedBy(TurnOutcome outcome) {
        return rule.test(outcome);
    }
}
```

Descrizione e regola stanno una accanto all'altra: l'enum si legge come la tabella che è, e
aggiungere un invariante è aggiungere una riga.

## I due modi di sbagliare la conversione

### `Function<T, Boolean>` invece di `Predicate<T>`

```java
private final Function<TurnOutcome, Boolean> rule;   // NO
```

A ogni valutazione il `boolean` restituito dalla lambda viene incapsulato in un `Boolean`. E
`Boolean` ammette `null`: una lambda che per errore lo restituisce fa esplodere il chiamante con
un `NullPointerException` all'unboxing, lontano dalla causa. Con `Predicate<TurnOutcome>` quel caso
non è rappresentabile e non c'è boxing. Vale allo stesso modo per `Supplier<T>` contro
`Function<Void, T>` e per le varianti primitive.

### Function object esposto

```java
public final Function<TurnOutcome, Boolean> isSatisfiedBy;   // NO: campo pubblico
public Function<TurnOutcome, Boolean> getIsSatisfiedBy() { … } // NO: getter sul meccanismo
```

Il chiamante è costretto a scrivere `invariant.getIsSatisfiedBy().apply(outcome)` invece di
`invariant.isSatisfiedBy(outcome)`. La lambda è un dettaglio implementativo dell'enum: fuori si
vede solo il verbo. Esporla scambia una classe anonima con un meccanismo in vista, e la
leggibilità peggiora invece di migliorare.

## Quando il cancello si chiude

Se il corpo della regola non è un'espressione o poche righe, o se per costante variano due o più
metodi, non serve né la lambda né la classe anonima: serve un **collaboratore con un nome**. Una
lambda lunga dentro la lista delle costanti non si può spezzare in metodi privati con nomi di
dominio, e la lista smette di leggersi come una tabella — che era l'unica ragione per cui la
conversione conveniva.
