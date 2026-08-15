# Esempi svolti: conteggio e report

Casi completi con il conteggio **derivato riga per riga**, non asserito. Leggi questo file quando devi contare un costrutto di cui non sei certo, quando il perimetro contiene metodi modificati, o quando devi produrre il report finale.

## Indice

1. [Metodo nuovo — conteggio derivato](#1-metodo-nuovo--conteggio-derivato)
2. [Metodo modificato — il delta](#2-metodo-modificato--il-delta)
3. [Casi di conteggio insidiosi](#3-casi-di-conteggio-insidiosi)
4. [Groovy — safe navigation ed elvis](#4-groovy--safe-navigation-ed-elvis)
5. [Report completo con rilievi](#5-report-completo-con-rilievi)
6. [Report senza rilievi](#6-report-senza-rilievi)
7. [Anti-esempio — perimetro sbagliato](#7-anti-esempio--perimetro-sbagliato)

---

## 1. Metodo nuovo — conteggio derivato

Metodo creato dal task. Non esiste un «prima»: il CCN è assoluto.

```java
public ProvvedimentoResult protocollaChiusura(DomandaBando domanda, Long commentoId) {
    if (domanda == null) {
        throw new IllegalArgumentException("Domanda non valorizzata");
    }
    StatoDomandaBando stato = domanda.getStato();
    if (stato == null || !stato.isChiudibile()) {
        return ProvvedimentoResult.nonApplicabile(domanda.getId());
    }
    List<Allegato> allegati = allegatoRepository.findByDomanda(domanda.getId());
    for (Allegato allegato : allegati) {
        if (allegato.isObbligatorio() && !allegato.isPresente()) {
            return ProvvedimentoResult.incompleto(allegato.getCodice());
        }
    }
    try {
        String numeroProtocollo = protocolloClient.protocolla(domanda, commentoId);
        return ProvvedimentoResult.protocollato(numeroProtocollo);
    } catch (ProtocolloException | TimeoutException e) {
        return ProvvedimentoResult.errore(e.getMessage());
    }
}
```

| Costrutto | Peso | Progressivo |
|-----------|-----:|------------:|
| base | 1 | 1 |
| `if (domanda == null)` | +1 | 2 |
| `if (stato == null \|\| ...)` | +1 | 3 |
| `\|\|` nella stessa condizione | +1 | 4 |
| `for (Allegato allegato : allegati)` | +1 | 5 |
| `if (allegato.isObbligatorio() && ...)` | +1 | 6 |
| `&&` nella stessa condizione | +1 | 7 |
| `catch (ProtocolloException \| TimeoutException e)` | +1 | 8 |

**CCN = 8** — livello *ok*, nessun rilievo. Il `catch` multi-tipo vale 1, non 2: è un solo ramo di uscita. Il `try` non conta.

---

## 2. Metodo modificato — il delta

Il metodo esisteva già. Serve il CCN **prima** e **dopo**: il rilievo è sulla differenza.

Recupera la versione precedente:

```bash
git show HEAD:modules/bandi-service/src/main/java/.../RicercaDomandeService.java
```

### Prima (CCN 5)

```java
public List<DomandaBando> cercaDomande(RicercaCriteri criteri) {
    if (criteri == null) {
        return Collections.emptyList();
    }
    List<DomandaBando> risultati = repository.findByBando(criteri.getBandoId());
    if (criteri.getStato() != null) {
        risultati = filtraPerStato(risultati, criteri.getStato());
    }
    if (criteri.getDataDa() != null && criteri.getDataA() != null) {
        risultati = filtraPerPeriodo(risultati, criteri.getDataDa(), criteri.getDataA());
    }
    return risultati;
}
```

base 1 + `if` null 1 + `if` stato 1 + `if` date 1 + `&&` 1 = **5**

### Dopo (CCN 14)

Il task ha aggiunto due criteri di ricerca, in linea:

```java
public List<DomandaBando> cercaDomande(RicercaCriteri criteri) {
    // ... le prime tre condizioni restano invariate (CCN parziale 5)

    if (criteri.getCodiceFiscale() != null) {
        risultati = risultati.stream()
            .filter(d -> d.getRichiedente() != null
                && d.getRichiedente().getCodiceFiscale().equals(criteri.getCodiceFiscale()))
            .collect(Collectors.toList());
    }
    if (criteri.getImportoMin() != null || criteri.getImportoMax() != null) {
        for (Iterator<DomandaBando> it = risultati.iterator(); it.hasNext(); ) {
            DomandaBando domanda = it.next();
            boolean fuoriRange =
                (criteri.getImportoMin() != null && domanda.getImporto() < criteri.getImportoMin())
                || (criteri.getImportoMax() != null && domanda.getImporto() > criteri.getImportoMax());
            if (fuoriRange) {
                it.remove();
            }
        }
    }
    return risultati;
}
```

| Costrutto aggiunto dal task | Peso | Progressivo |
|-----------------------------|-----:|------------:|
| *(parte preesistente)* | — | 5 |
| `if (getCodiceFiscale() != null)` | +1 | 6 |
| `&&` dentro il predicato del `filter` | +1 | 7 |
| `if (importoMin != null \|\| importoMax != null)` | +1 | 8 |
| `\|\|` nella stessa condizione | +1 | 9 |
| `for (Iterator ...)` | +1 | 10 |
| `&&` nel primo membro di `fuoriRange` | +1 | 11 |
| `\|\|` fra i due membri | +1 | 12 |
| `&&` nel secondo membro | +1 | 13 |
| `if (fuoriRange)` | +1 | 14 |

**CCN 5 → 14, delta +9.** Il predicato della lambda conta nel metodo che la contiene; `stream()`, `filter()` e `collect()` di per sé non contano.

Nota per il report: qui il numero segnala un problema che non è di sola forma. Due criteri di ricerca sono stati risolti **filtrando in memoria** un risultato già caricato dal database, invece che nella query — quindi il rilievo va formulato su quello, con il CCN come sintomo.

---

## 3. Casi di conteggio insidiosi

### Lambda e Stream

```java
List<String> codici = domande.stream()
    .filter(d -> d.isAttiva() && d.getImporto() > soglia)   // && → +1
    .map(d -> d.getCodice() != null ? d.getCodice() : "N/D") // ternario → +1
    .collect(Collectors.toList());
```

**+2** sul metodo contenitore. Le operazioni di Stream non contano; contano i punti di decisione dentro i predicati e le funzioni di mapping.

### Switch classico, con fall-through

```java
switch (tipoProvvedimento) {
    case AMMISSIONE:
    case AMMISSIONE_CON_RISERVA:   // +1 per il gruppo, non uno per etichetta
        return costruisciAmmissione(domanda);
    case ESCLUSIONE:               // +1
        return costruisciEsclusione(domanda);
    default:                       // non conta
        throw new IllegalStateException("Tipo non gestito: " + tipoProvvedimento);
}
```

**+2.** Un gruppo di etichette in fall-through porta a un solo statement, quindi è un solo ramo. Il `default` non conta mai.

### Switch a freccia

```java
return switch (tipoProvvedimento) {
    case AMMISSIONE, AMMISSIONE_CON_RISERVA -> costruisciAmmissione(domanda);  // +1
    case ESCLUSIONE -> costruisciEsclusione(domanda);                          // +1
    default -> throw new IllegalStateException("Tipo non gestito");            // non conta
};
```

**+2.** Qui il fall-through non esiste: ogni regola vale 1, indipendentemente da quante etichette elenca. Costrutto disponibile da Java 14: su un progetto Java 11 o Liferay non lo incontrerai.

### Classe anonima contro lambda

```java
public void registraListener(Bando bando) {
    listener.add(evento -> {
        if (evento.isRilevante() && bando.isAttivo()) {   // +2 sul metodo contenitore
            notifica(evento);
        }
    });
    listener.add(new EventoListener() {
        @Override
        public void onEvento(Evento evento) {
            if (evento.isRilevante() && bando.isAttivo()) {   // NON conta qui
                notifica(evento);
            }
        }
    });
}
```

Il corpo della **lambda** somma al metodo che la contiene: **+2**. Il corpo della **classe anonima** non somma: `onEvento` è un metodo a sé, con il suo CCN di 3, e va misurato separatamente se il task lo ha scritto.

`registraListener` vale quindi **3** (base 1 + i 2 della lambda), non 5. È l'asimmetria che si sbaglia più spesso.

### Ternario annidato

```java
String etichetta = stato.isChiuso() ? "Chiusa"
    : stato.isSospesa() ? "Sospesa"
    : "In lavorazione";
```

**+2**: un punto per ciascun operatore ternario.

### Catch multipli contro catch multi-tipo

```java
try { ... }
catch (ProtocolloException | TimeoutException e) { ... }   // +1
```

```java
try { ... }
catch (ProtocolloException e) { ... }   // +1
catch (TimeoutException e) { ... }      // +1
```

Il primo vale **+1**, il secondo **+2**. `try` e `finally` non contano mai.

---

## 4. Groovy — safe navigation ed elvis

Negli script per la Script console il CCN cresce in fretta senza un solo `if` visibile.

```groovy
def descrizioneBando(bando) {
    def titolo = bando?.titolo ?: "Senza titolo"
    def stato = bando?.stato?.descrizione ?: "n/d"
    if (bando?.scadenza && bando.scadenza < new Date()) {
        return "${titolo} (scaduto) - ${stato}"
    }
    return "${titolo} - ${stato}"
}
```

| Costrutto | Peso | Progressivo |
|-----------|-----:|------------:|
| base | 1 | 1 |
| `bando?.titolo` | +1 | 2 |
| `?:` | +1 | 3 |
| `bando?.stato` | +1 | 4 |
| `?.descrizione` | +1 | 5 |
| `?:` | +1 | 6 |
| `bando?.scadenza` | +1 | 7 |
| `if` | +1 | 8 |
| `&&` | +1 | 9 |

**CCN = 9** per nove righe. Ogni `?.` e ogni `?:` è un ramo. Segnalalo nel report quando l'alto punteggio dipende quasi solo da questi: la lettura non ne soffre, e il rilievo va calibrato di conseguenza.

---

## 5. Report completo con rilievi

```markdown
## Complessità ciclomatica — codice di sessione

**Perimetro**: 3 file modificati dal task, ricavati dalla conversazione
**Convenzione di conteggio**: McCabe, operatori booleani inclusi, `else` e `default` esclusi,
punti di decisione delle lambda attribuiti al metodo contenitore
**Metodi misurati**: 5

| File | Metodo | CCN | Delta | Livello |
|------|--------|----:|------:|---------|
| `RicercaDomandeService.java` | `cercaDomande` | 14 | 5 → 14 | attenzione |
| `ProtocollazioneService.java` | `protocollaChiusura` | 8 | nuovo | ok |
| `ProtocollazioneService.java` | `mapStatoInTipoProvvedimento` | 4 | nuovo | ok |
| `RollbackContext.java` | `perChiusuraDomanda` | 1 | nuovo | ok |
| `RicercaCriteri.java` | `isVuoto` | 6 | 3 → 6 | ok |

### Rilievi

**`RicercaDomandeService.cercaDomande` — 14 (da 5), delta +9**
Il task ha aggiunto due criteri di ricerca risolvendoli in memoria su un risultato già
caricato: uno `stream().filter()` sul codice fiscale e un ciclo con `Iterator.remove()`
sull'intervallo di importo. Nove dei punti di decisione del metodo servono a fare
selezione dopo la query.
Il CCN qui è il sintomo, non il problema: la selezione appartiene alla query, e spostandola
il metodo torna intorno a 6 senza alcun lavoro di riorganizzazione.

**`RicercaCriteri.isVuoto` — 6 (da 3)**
Sotto soglia, lo segnalo solo per il delta: il metodo è raddoppiato. La forma è una catena
di `||` su cinque campi, lineare e leggibile. Nessuna azione suggerita.

### Fuori perimetro
`RicercaDomandeService` contiene altri quattro metodi, uno dei quali sopra soglia alta.
Il task non li ha toccati e non li ho misurati.

### Esito
2 rilievi, nessuno sopra la soglia alta. Il solo che merita una decisione è `cercaDomande`,
e la decisione riguarda dove avviene la selezione dei dati, non la lunghezza del metodo.
```

Osserva tre cose: il metodo peggiore è spiegato con la **causa**, non con il numero; il metodo a 6 è riportato ma senza chiedere nulla; il codice fuori perimetro è **dichiarato come non misurato** invece di essere ignorato in silenzio.

---

## 6. Report senza rilievi

L'esito più frequente su un task ben fatto. Tre righe bastano.

```markdown
## Complessità ciclomatica — codice di sessione

**Perimetro**: 2 file modificati dal task
**Convenzione di conteggio**: McCabe, operatori booleani inclusi
**Metodi misurati**: 6 — CCN massimo 7 (`ProtocollazioneService.protocollaChiusura`),
mediana 3. Tutti sotto soglia.

### Esito
Nessun rilievo.
```

Non gonfiare il report con la tabella completa dei metodi «ok» quando sono più di cinque: bastano massimo, mediana e conteggio.

---

## 7. Anti-esempio — perimetro sbagliato

```markdown
## Analisi complessità — RicercaDomandeService.java

| Metodo | CCN |
|--------|----:|
| cercaDomande | 14 |
| filtraPerStato | 4 |
| filtraPerPeriodo | 6 |
| caricaAllegati | 11 |
| esportaCsv | 19 |
| validaCriteri | 8 |
...
```

Cosa c'è di sbagliato: il task aveva toccato **un solo metodo**. Gli altri esistevano già identici prima della sessione, e `esportaCsv` a 19 è un debito che qualcun altro ha contratto mesi fa. Un report così sposta l'attenzione dal lavoro appena svolto a un inventario che nessuno ha chiesto, e affoga il rilievo vero — il delta +9 su `cercaDomande` — in mezzo a sei righe di rumore.

Se il debito preesistente merita di essere conosciuto, si dichiara in una riga («il file contiene altri metodi sopra soglia che il task non ha toccato»), non si tabula.
