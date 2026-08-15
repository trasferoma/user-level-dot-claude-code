---
name: cyclomatic-complexity
description: Misura la complessità ciclomatica (CCN, metrica di McCabe) dei soli metodi e funzioni creati o modificati nella sessione corrente, senza toccare il codice, e produce un report. Usa al termine di una fase di scrittura o di verifica, quando serve sapere quanto è complesso ciò che si è appena scritto, quando un metodo nuovo risulta difficile da testare, o quando l'utente chiede la complessità ciclomatica di una modifica. Definisce il perimetro (file toccati dal task, oppure git diff), le regole di conteggio dei punti di decisione per Java, Groovy, JavaScript e Python, le soglie di rilievo e il formato del report. NON misura classi intere né codice preesistente che il task non ha toccato, non rifattorizza, non modifica alcun file.
allowed-tools: Read, Grep, Glob, Bash
---

# Complessità ciclomatica del codice di sessione

Skill di **sola lettura**. Misura, riporta, propone. Non tocca nulla.

## Regola zero: la misura non modifica nulla

Questa skill produce **un report**, mai una modifica. Vale per tutta la sessione, non solo per il turno in cui viene invocata.

- Non usare `Edit`, `Write`, `MultiEdit` per applicare ciò che rilevi.
- Non riscrivere un metodo «per mostrare come sarebbe meglio»: descrivi la direzione a parole e cita il pattern.
- Se stai per correggere qualcosa **mentre misuri**, ti sei mosso fuori mandato: fermati e mettilo nel report.

**Cosa accade dopo il report dipende da chi ti ha invocato.** Sono due casi distinti:

| Chi invoca | Dopo il report |
|------------|----------------|
| **L'utente, a mano** (`/cyclomatic-complexity`) | Nulla. Consegni il report e ti fermi. Nessuna modifica, nemmeno se un rilievo è evidente e la correzione sarebbe banale: se la vuole, la chiede. |
| **Un agente con un proprio mandato di correzione** (`clean-code-implementer` in modalità verifica) | Può correggere, secondo le regole della **sua** fase — non secondo questa skill, che ha già esaurito il suo compito con il report. |

In entrambi i casi la sequenza è la stessa e non si inverte: **prima la misura, senza toccare nulla; poi il report; poi, solo se il mandato lo prevede, la decisione di correggere.** Misurare e correggere nello stesso gesto è ciò che va evitato: lì il numero smette di essere una misura e diventa la giustificazione di una modifica già decisa.

## Passo 1 — Definisci il perimetro

Misuri **solo il codice scritto o modificato in questa sessione**, e dentro quel codice **solo i metodi toccati**, mai il file intero né la classe intera.

Determina il perimetro in questo ordine, fermandoti al primo che dà un risultato:

1. **I file e i metodi che il task ha creato o modificato**, se li conosci dalla conversazione o se chi ti invoca te li elenca. È la via preferita: è la più precisa.
2. **Il working tree rispetto a `HEAD`**, se il primo punto non è determinabile:
   ```bash
   git status --porcelain
   git diff --stat HEAD
   git diff -U0 HEAD -- <file>
   ```
   `git diff -U0` ti dà le righe cambiate senza contorno: da lì ricavi quali metodi sono stati toccati.
3. **Chiedi.** Se non hai né l'uno né l'altro, chiedi quali file o quali metodi misurare. **Non ripiegare mai sull'intero repository o sull'intera classe**: è il fallimento tipico di questa skill, e produce un report di 200 righe che nessuno legge.

### Cosa entra e cosa no

| Caso | In perimetro | Come lo tratti |
|------|--------------|----------------|
| Metodo nuovo creato dal task | sì | CCN assoluto |
| Metodo preesistente modificato dal task | sì | **delta**: CCN prima → CCN dopo |
| Metodo preesistente non toccato, nello stesso file | no | non lo misuri, non lo nomini |
| Metodo solo rinominato o riformattato | no | la complessità non è cambiata |
| Metodo di cui il task ha solo cambiato la firma | sì, se il corpo è cambiato | altrimenti no |
| Test scritti dal task | sì, ma in una sezione separata | le soglie dei test sono più permissive |

Per il CCN «prima» di un metodo modificato, leggi la versione precedente:

```bash
git show HEAD:percorso/del/File.java
```

Se il file è nuovo nel working tree, non esiste un «prima»: il CCN è assoluto.

## Passo 2 — Conta

**Via primaria: conteggio a mano.** Su pochi metodi è affidabile, non richiede alcun tool installato e funziona su qualunque progetto. È il caso normale di questa skill.

**Via secondaria: conferma con un tool**, quando il perimetro supera la decina di metodi o quando il progetto ha già un analizzatore configurato. Comandi verificati e configurazione per linguaggio in [reference/strumenti-e-soglie.md](reference/strumenti-e-soglie.md).

### Formula

```
CCN = 1 + numero di punti di decisione nel metodo
```

Un metodo senza rami vale **1**, non 0.

### Punti di decisione, per linguaggio

Ogni occorrenza vale **+1**.

| Costrutto | Java | Groovy | JS/TS | Python |
|-----------|:----:|:------:|:-----:|:------:|
| `if`, `else if` | sì | sì | sì | `if`, `elif` |
| `else` | **no** | no | no | no |
| `for`, `while`, `do-while` | sì | sì | sì | `for`, `while` |
| `case` di uno `switch` | sì | sì | sì | `case` di `match` |
| `default` dello `switch` | **no** | no | no | `case _` no |
| `catch` | sì | sì | sì | `except` |
| `try`, `finally` | **no** | no | no | no |
| `&&`, `\|\|` | sì | sì | sì | `and`, `or` |
| operatore ternario `? :` | sì | sì | sì | espressione condizionale |
| `?:` elvis, `?.` safe navigation | — | sì | `??`, `?.` sì | — |
| comprehension con `if` | — | — | — | sì |
| `assert` | no | no | no | no |

**Convenzioni da applicare sempre, per avere numeri riproducibili.** Coincidono con quelle dell'ispezione nativa di IntelliJ IDEA, così il conteggio a mano e l'IDE danno lo stesso numero:

- I punti di decisione dentro una **lambda o una closure** contano nel metodo che la contiene.
- I punti di decisione dentro una **classe anonima** **non** contano nel metodo che la contiene: la classe anonima è un'unità a sé, e se serve la misuri come tale. È l'opposto delle lambda, ed è la distinzione che si sbaglia più spesso su codice Java 11 e Liferay.
- Le operazioni di **Stream** non contano di per sé: conta ciò che sta dentro i predicati (`filter(x -> a && b)` vale +1 per `&&`).
- Un **catch multi-tipo** (`catch (A | B e)`) vale +1, non +2: è un solo blocco `catch`.
- In uno **switch classico**, un gruppo di `case` in fall-through vale **+1 in totale**, non uno per etichetta: `case A: case B: return x;` è un solo ramo. In uno **switch a freccia** (`case X ->`) il fall-through non esiste, quindi ogni regola vale +1.
- Una catena di operatori booleani vale **un punto per operatore**: `a && b && c` vale +2.
- **Dichiara nel report la convenzione usata.** Altri strumenti contano diversamente — alcuni ignorano gli operatori booleani, alcuni contano ogni etichetta `case`, alcuni contano `default`. Senza la convenzione dichiarata, due misure non sono confrontabili.

### Esempio di conteggio

```java
public void processOrder(Order order) {          // base                    1
    if (order == null || order.getItems() == null) {   // if +1, || +1      3
        throw new IllegalArgumentException("Ordine non valorizzato");
    }
    for (OrderItem item : order.getItems()) {          // for +1            4
        if (item.isDiscounted() && item.getQuantity() > 1) {  // if +1, && +1  6
            applyDiscount(item);
        }
    }
    try {
        repository.save(order);
    } catch (PersistenceException e) {                 // catch +1          7
        throw new OrderException("Salvataggio fallito", e);
    }
}
// CCN = 7
```

Conteggi derivati riga per riga sui casi che sbagliano più spesso — lambda e Stream, `switch`,
ternari annidati, `catch` multi-tipo, safe navigation Groovy — in
[examples/conteggio-e-report.md](examples/conteggio-e-report.md).

## Passo 3 — Valuta

Scala unica, valida per tutto il report:

| CCN | Livello | Cosa scrivi |
|-----|---------|-------------|
| 1–10 | **ok** | nessun rilievo |
| 11–15 | **attenzione** | segnali il metodo e indichi la direzione, senza insistere |
| 16–25 | **alto** | rilievo esplicito con il pattern di riduzione suggerito |
| 26+ | **critico** | rilievo che riporti in evidenza a chi ti ha invocato |

«Critico» significa **da riportare**, non «da rifattorizzare adesso»: la decisione non è tua (vedi Regola zero).

### Le quattro regole di giudizio

**1. Il delta conta più del valore assoluto.** Un metodo che il task ha portato da 8 a 14 è un rilievo anche se 14 è sotto la soglia alta: la sessione ha aggiunto 6 punti di decisione a qualcosa che era sano. Un metodo che era 22 ed è rimasto 22 non è un rilievo di questo task.

**2. Il numero è un segnale, non una sentenza.** Un metodo a 12 chiaro, lineare e coperto da test non ha bisogno di nulla. Un metodo a 8 illeggibile sì. Se segnali un metodo, di' **perché** è un problema, non solo quanto vale.

**3. Il CCN non misura la leggibilità.** Non cattura la profondità di annidamento, i nomi, la densità delle espressioni. Quando trovi CCN basso ma codice ostico, il rilievo esiste lo stesso: dillo, e attribuiscilo alla causa giusta (annidamento, naming, densità). Vale anche l'inverso: quindici validazioni sequenziali fanno CCN 16 e si leggono benissimo.

**4. Estrarre metodi non riduce il totale, e va bene così.** Spezzare un metodo da 12 in quattro metodi lascia il totale a 12, ma ogni pezzo diventa testabile da solo. Non presentare come peggioramento la somma dei CCN dopo un'estrazione.

### Quando un CCN alto è legittimo

Non alzare un rilievo, o abbassane il tono, quando la complessità è **intrinseca al dominio** e la forma alternativa sarebbe peggiore:

- macchine a stati con stati espliciti e ben definiti
- validazione di input con molte regole indipendenti e sequenziali
- mappatura di configurazioni o di codici con casi espliciti
- dispatch di comandi
- calcoli con vincoli normativi (fiscali, contabili, regolamentari)

In questi casi scrivi nel report **perché** lo consideri accettabile. Non chiedere di documentarlo con un commento nel codice: il default di progetto è nessun commento, e la giustificazione vive nel report, non nel sorgente.

## Passo 4 — Riporta

Usa questa struttura. Se non c'è nessun rilievo, il report è di tre righe: è un esito valido e frequente.

```markdown
## Complessità ciclomatica — codice di sessione

**Perimetro**: <come l'hai determinato: file del task / git diff HEAD>
**Convenzione di conteggio**: McCabe, operatori booleani inclusi, `else` e `default` esclusi
**Metodi misurati**: N

| File | Metodo | CCN | Delta | Livello |
|------|--------|----:|------:|---------|
| `.../OrderService.java` | `processOrder` | 7 | nuovo | ok |
| `.../OrderService.java` | `validateItems` | 14 | 8 → 14 | attenzione |

### Rilievi

**`OrderService.validateItems` — 14 (da 8)**
Il task ha aggiunto quattro rami di validazione dentro un metodo che ne aveva già tre.
Direzione: guard clause per i casi di scarto in testa, oppure estrazione delle regole
in metodi separati con nome di dominio.

### Esito
<una riga: nessun rilievo / N rilievi di cui M sopra soglia alta>
```

Riporta il **livello più grave** in evidenza per chi legge di fretta. Non elencare i metodi «ok» uno per uno se sono più di cinque: basta il conteggio.

Report completi — con rilievi, senza rilievi, e l'anti-esempio del perimetro allargato a tutta
la classe — in [examples/conteggio-e-report.md](examples/conteggio-e-report.md).

### Direzioni da suggerire

Solo come indicazione nel report, mai da applicare.

| Situazione | Direzione |
|------------|-----------|
| Condizionali profondamente annidati | guard clause / early return in testa |
| Il metodo fa più cose in sequenza | estrazione di metodi con nome di dominio |
| Catena lunga di `if/else if` o `switch` | tabella di lookup, mappa, o polimorfismo |
| Condizione booleana lunga | variabile booleana esplicativa con nome parlante |
| Rami che si distinguono solo per un valore | parametrizzazione |

L'ultima riga di questa tabella e la penultima sono coerenti con `clean-code`: dare un nome a una condizione è un miglioramento, non un modo per «nascondere» complessità.

## Uso

### Invocazione manuale

`/cyclomatic-complexity`, eventualmente con il perimetro: «solo `OrderService`», «tutto ciò che ho toccato oggi».

Il frontmatter dichiara `allowed-tools: Read, Grep, Glob, Bash`: nel turno in cui la skill viene invocata a mano gli strumenti di scrittura **non sono disponibili**, quindi la Regola zero è garantita dall'ambiente e non dalla sola disciplina. Se in quello stesso turno serve anche correggere qualcosa, la correzione avviene al turno successivo.

La restrizione non tocca l'altro caso: un agente non invoca la skill, la **legge da disco** come file, e conserva quindi il proprio mandato di correzione.

### Consegna a un subagent

I subagent non hanno il tool `Skill`: leggono le skill da disco. Per consegnare questa skill a un agente, passagli il percorso e il mandato:

> Leggi `~/.claude/skills/cyclomatic-complexity/SKILL.md` e applicala ai file che hai
> appena modificato: <elenco>. Sei in sola lettura, restituisci solo il report.

Elencagli sempre i file: senza quell'informazione l'agente cade sul `git diff`, che in un working tree sporco include lavoro non suo.

### Collocazione nella pipeline

Va **dopo** la fase di scrittura: è lo strumento di misura della fase di verifica, oppure un controllo a sé.

Chi scrive può conoscere le soglie e tenerne conto mentre lavora — è utile, ed è un ordine di grandezza, non un calcolo. Quello che non deve fare è **misurare mentre scrive**: un implementatore che insegue la cifra rifattorizza per la metrica, ed è il difetto che questa skill esiste per non provocare. La misura arriva dopo, su codice fermo.

## Vincoli

- Non misurare codice che il task non ha toccato.
- Non misurare classi o file interi quando il perimetro è un metodo.
- Non modificare alcun file, in nessuna circostanza.
- Non dichiarare un CCN senza aver letto il corpo del metodo.
- Non riportare un numero senza la convenzione di conteggio con cui l'hai ottenuto.
- Non usare la complessità come unico metro: se il rilievo vero è l'annidamento o il naming, dillo.
- Non proporre commenti nel codice per giustificare la complessità.

## Skill correlate

- `clean-code` — metodi piccoli, SLAP, anti-densità: è la skill che governa *come si scrive*, questa misura soltanto
- `package-placement` — se il rilievo è che il metodo sta nel posto sbagliato, non che è complesso
- `java-conventions`, `springboot`, `liferay` — convenzioni del linguaggio e del framework

## Risorse

- **Esempi svolti**: conteggi derivati riga per riga (metodo nuovo, metodo modificato con delta, casi insidiosi in Java e Groovy) e report completi, incluso l'anti-esempio del perimetro sbagliato — [examples/conteggio-e-report.md](examples/conteggio-e-report.md)
- **Strumenti di misura per linguaggio, comandi verificati, integrazione in CI e soglie industriali (McCabe, NIST, Microsoft, NASA, SonarQube)**: [reference/strumenti-e-soglie.md](reference/strumenti-e-soglie.md)
