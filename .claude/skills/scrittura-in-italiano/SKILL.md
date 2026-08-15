---
name: scrittura-in-italiano
description: Impone l'italiano corretto nei commenti del codice sorgente. Usa ogni volta che scrivi, modifichi o revisioni commenti inline, commenti a blocco, Javadoc, JSDoc, docstring, TODO e FIXME in italiano. NON decide se il commento debba esistere e non è un invito a commentare: il default di progetto è nessun commento, e quali commenti siano ammessi lo stabilisce clean-code. Richiede la frase di senso compiuto con verbo coniugato alla terza persona singolare dell'indicativo presente, accenti ed elisioni corretti, punteggiatura e maiuscole secondo le convenzioni redazionali UE, plurale invariabile dei forestierismi, divieto dei calchi dall'inglese (processare, triggerare, settare, ritornare un valore), coerenza terminologica e forma dei tag Javadoc. Include una checklist di autoverifica e le fonti normative. Da comporre con clean-code e con le skill di linguaggio. NON riguarda i nomi di classi, metodi e variabili, che restano in inglese, né la prosa di documentazione esterna come README e specifiche.
---

# Scopo
Garantire che ogni commento nel codice sorgente sia italiano corretto, in frase di senso compiuto,
verificabile su fonti attestate. La skill governa la **lingua del commento**, non il fatto che il
commento debba esistere: quello lo decide `clean-code`.

> ⚠️ **Precondizione, da verificare prima di applicare qualunque regola qui sotto.**
> Il default del progetto è **nessun commento e nessuna Javadoc**: il commento è un'eccezione che
> deve superare il test di ammissione di `clean-code` §4 (spiega un *perché* non deducibile da nomi,
> tipi e struttura, che nessuna riscrittura renderebbe evidente). Questa skill **non è un invito a
> commentare**: si applica solo al commento che ha già superato quel test.
> Se un commento non lo supera, si **elimina**, non si traduce e non si migliora.
> Non trattare gli esempi «corretti» di questa skill come commenti da produrre: sono il modello
> linguistico dei pochi commenti ammessi, non un catalogo di occasioni per scriverne.

# Quando usare questa skill
- Stai scrivendo o modificando commenti in italiano: inline (`//`), a blocco (`/* */`), Javadoc,
  JSDoc, docstring, `TODO`, `FIXME`.
- Stai revisionando o correggendo commenti già presenti nel codice.
- Devi giudicare se una forma italiana in un commento è accettabile.

Sui commenti già presenti e non conformi: correggi quelli che stai comunque modificando, lascia gli
altri e segnalali se sono molti. Non fare passate di sola correzione linguistica su file che il task
non tocca.

Vale per tutta la sessione: da qui in avanti ogni commento che produci rispetta queste regole,
senza che serva ricordartelo a ogni file.

# Quando NON usare questa skill
- Nomi di classi, metodi, variabili, costanti, tabelle e colonne: restano **in inglese** (regola di
  progetto), quindi fuori perimetro.
- File in cui il progetto adotta già l'inglese nei commenti in modo uniforme: mantieni la lingua del
  file e segnala l'eccezione all'utente.
- Prosa di documentazione esterna (README, SPEC, messaggi di commit, documenti di consegna): hanno
  skill proprie.
- Testi rivolti all'utente finale e label i18n.

# Regole di precedenza
- Le istruzioni esplicite dell'utente prevalgono su questa skill.
- Se un file o un modulo adotta già coerentemente una convenzione diversa, prevale la coerenza col
  progetto; segnala la divergenza invece di introdurre un'isola di stile.
- Sulla forma tecnica del commento (struttura, tag) prevalgono le convenzioni della piattaforma
  (Javadoc); sulla lingua prevale questa skill.
- Questa skill non impone di aggiungere commenti dove non servono: se un commento è ridondante, si
  elimina, non si traduce.

# Regole operative

## 1. Frase di senso compiuto
Ogni commento è una **proposizione completa**, dotata di:

- un **predicato verbale esplicito e coniugato** (non l'infinito, non il participio isolato);
- un **soggetto** espresso o sottinteso e univocamente ricostruibile;
- gli **argomenti obbligatori** richiesti dalla valenza del verbo;
- una **punteggiatura conclusiva** (punto fermo).

Sono vietati i frammenti nominali telegrafici, le sigle di comodo e le abbreviazioni improvvisate.

| ✗ Vietato | ✓ Corretto |
|-----------|------------|
| `// ciclo su lista` | `// Scorre la lista degli ordini per calcolarne il totale.` |
| `// check null` | `// Verifica che il parametro non sia nullo prima della conversione.` |
| `// fix bug 1234` | `// Corregge l'arrotondamento errato segnalato nel ticket 1234.` |
| `// gestione errori` | `// Intercetta le eccezioni di rete e riprova al massimo tre volte.` |

## 2. Verbo
- **Terza persona singolare dell'indicativo presente**, forma attiva: `Restituisce`, `Calcola`,
  `Verifica`. Il soggetto sottinteso è il metodo, la classe o l'istruzione commentata.
- Vietato l'infinito descrittivo (`// Calcolare il totale`), vietata la prima persona plurale
  (`// Calcoliamo il totale`), vietato il futuro (`// Restituirà il totale`).
- Il **congiuntivo** è obbligatorio nelle subordinate rette da verbi di opinione, volontà, dubbio e
  nelle ipotetiche: `se il valore fosse nullo, il metodo solleverebbe un'eccezione` (mai
  «se sarebbe»).
- Verifica la **concordanza** di genere, numero e persona su tutta la frase, compreso l'accordo del
  participio passato.

## 3. Ortografia, accenti e maiuscole
Punti in cui l'errore è frequente, da controllare sempre:

- Accenti: `perché`, `poiché`, `affinché`, `né`, `sé`, `dà`, `è`, `più`, `così`, `già`.
- `qual è` **senza** apostrofo, `po'` **con** apostrofo; `d` eufonica solo tra vocali identiche
  (`ed è` sì, `ed esempio` no).
- Elisione solo davanti a femminile singolare: `un'eccezione` contro `un altro`.
- Maiuscola solo a inizio frase, nei nomi propri, negli acronimi (`HTTP`, `SQL`, `JSON`) e negli
  identificatori del codice, che mantengono la grafia originale. Vietato il maiuscolo di stile
  inglese sulle iniziali di ogni parola.
- Vietati i puntini di sospensione, i punti esclamativi e le emoji.

## 4. Lessico e forestierismi
- I forestierismi non adattati sono **invariabili al plurale**: `i file` (non «i files»),
  `i thread`, `i token`, `le performance`.
- Preferisci il termine italiano quando esiste ed è chiaro: `impostare` (non «settare»),
  `pianificare` (non «schedulare»), `distribuire`/`rilasciare` (non «deployare»), `avviare` (non
  «startare»).
- Restano in inglese i termini tecnici consolidati e privi di equivalente univoco (`cache`,
  `commit`, `endpoint`, `log`, `stream`, `buffer`).
- **Non tradurre mai** i nomi di classi, metodi, variabili, tabelle, colonne, parametri e costanti:
  citali nella grafia esatta del codice.
- Sono vietati i falsi amici e i calchi dall'inglese:

| ✗ Calco | ✓ Forma corretta |
|---------|------------------|
| assumere (nel senso di *to assume*) | presupporre, ipotizzare |
| realizzare (nel senso di *to realize*) | accorgersi, rendersi conto |
| eventualmente (nel senso di *eventually*) | alla fine, prima o poi |
| supportare un errore | gestire un errore |
| processare | elaborare |
| triggerare | attivare, scatenare |
| ritornare un valore | restituire un valore |

## 5. Numeri, date e unità
- Date in formato **ISO 8601** (`2026-07-30`); separatore decimale la **virgola** nel testo
  discorsivo, il punto nei valori letterali del codice.
- Unità di misura secondo il SI, precedute da spazio: `500 ms`, `2 GB`.

## 6. Stile
- **Una frase, un concetto.** Lunghezza consigliata sotto le 25 parole; oltre le 30 spezza in due
  frasi.
- Il commento spiega **il perché**, non ciò che il codice già dichiara. Se si limita a ripetere il
  nome del metodo, eliminalo anziché tradurlo.
- **Registro impersonale e neutro.** Vietati i commenti colloquiali, ironici, autoreferenziali
  («qui ho dovuto fare un trucco») o rivolti al lettore in seconda persona.
- Nessun riferimento al fatto che il codice o il commento siano stati generati da un'AI.
- **Coerenza terminologica**: a un concetto corrisponde un solo termine e a un termine un solo
  concetto, per tutta la base di codice. Non alternare sinonimi per varietà stilistica: se il
  glossario di progetto adotta `pratica`, non compaiono altrove `fascicolo` o `posizione` per lo
  stesso oggetto. Introduci un termine nuovo solo dopo averlo verificato e averlo aggiunto al
  glossario.
- Nessun commento vuoto, decorativo o composto solo da caratteri di separazione.

## 7. Javadoc e documentazione strutturata
1. La **prima frase** è una sintesi autonoma, completa e chiusa dal punto fermo: costituisce
   l'abstract del metodo. Esempio: `Restituisce il totale imponibile dell'ordine.`
2. Le frasi successive, separate da riga vuota o da `<p>`, approfondiscono comportamento,
   precondizioni ed effetti collaterali.
3. Convenzione dei tag, uniforme su tutta la base di codice:
   - `@param nome` — sintagma nominale con iniziale minuscola, senza punto finale, purché
     grammaticalmente ben formato: `@param importo importo lordo espresso in centesimi`.
   - `@return` — sintagma nominale con iniziale minuscola, senza punto finale:
     `@return totale imponibile arrotondato a due decimali`.
   - `@throws` — proposizione introdotta da `se`:
     `@throws IllegalArgumentException se l'importo è negativo`.
4. Racchiudi gli identificatori citati nel testo in `{@code ...}`.
5. Non documentare l'ovvio: i getter e i setter banali non richiedono Javadoc.

## 8. TODO e FIXME
Unica eccezione ammessa alla terza persona: il verbo all'**infinito**, perché indica un'azione da
compiere. Formato obbligatorio:

```java
// TODO (RIF-1234): estrarre la validazione in una classe dedicata.
// FIXME (RIF-5678): rimuovere il ciclo annidato che degrada le prestazioni su liste grandi.
```

Il riferimento al ticket è obbligatorio; la frase resta compiuta e chiusa dal punto fermo.

# Autoverifica obbligatoria prima della consegna
Prima di emettere un commento — o un gruppo di commenti nello stesso file — verifica in ordine:

```
- [ ]  1. La frase ha un verbo coniugato esplicito ed è di senso compiuto.
- [ ]  2. Il verbo è alla terza persona singolare dell'indicativo presente (salvo TODO/FIXME).
- [ ]  3. Accenti, apostrofi ed elisioni sono corretti.
- [ ]  4. Genere, numero e concordanze sono coerenti in tutta la frase.
- [ ]  5. La punteggiatura è corretta e la frase è chiusa dal punto fermo.
- [ ]  6. Non ci sono calchi dall'inglese, plurali errati di forestierismi o termini non attestati.
- [ ]  7. Il commento aggiunge informazione rispetto al codice, non lo ripete.
- [ ]  8. Gli identificatori sono nella grafia esatta e non tradotti.
- [ ]  9. Il termine usato coincide con quello già adottato nel glossario di progetto.
- [ ] 10. Il commento è pertinente, comprensibile e utilizzabile da chi leggerà il codice.
```

Un commento che non supera anche un solo punto **non va emesso**: riscrivilo e ripeti la verifica.
In caso di dubbio residuo, scegli la formulazione più semplice tra quelle sicuramente corrette.
Se il dubbio è su una forma linguistica specifica, consulta
[reference/fonti-normative.md](reference/fonti-normative.md) e attieniti alla gerarchia delle fonti
descritta lì.

# Esempi di riferimento

```java
/**
 * Restituisce il totale imponibile dell'ordine, al netto degli sconti applicati.
 *
 * <p>Gli importi sono espressi in centesimi per evitare gli errori di arrotondamento
 * tipici della virgola mobile. Le righe annullate non concorrono al calcolo.
 *
 * @param ordine ordine da valutare, non nullo
 * @return totale imponibile in centesimi
 * @throws IllegalArgumentException se l'ordine non contiene alcuna riga valida
 */
public long calcolaImponibile(Ordine ordine) {
    // Filtra le righe annullate, che il gestionale conserva per motivi di audit.
    ...
    // TODO (RIF-1234): spostare l'aliquota IVA in configurazione.
}
```

| ✗ Commento da rifiutare | Motivo |
|-------------------------|--------|
| `// loop principale` | Frammento nominale privo di verbo. |
| `// Qui settiamo il flag` | Prima persona plurale, forestierismo adattato non ammesso. |
| `// Ritorna un array di files` | Calco dall'inglese, plurale errato di forestierismo. |
| `// Se sarebbe nullo lancia eccezione` | Periodo ipotetico errato, manca la punteggiatura. |
| `// Questo metodo calcola il totale!!!` | Punteggiatura enfatica, riferimento ridondante al metodo. |

# Vincoli
- Non emettere un commento che violi una regola della sezione «Regole operative»: riscrivilo prima
  della consegna.
- Non usare una forma non attestata nelle fonti di
  [reference/fonti-normative.md](reference/fonti-normative.md): se non la trovi, riformula.
- Non aggiungere commenti solo per applicare questa skill: se il commento è ridondante, il posto
  giusto è nessun commento.
- Non fare passate di sola correzione linguistica su commenti che il task non tocca.
- Non convertire in italiano i commenti di file che adottano già l'inglese in modo uniforme senza
  averlo concordato.

# Risorse aggiuntive
- **Fonti lessicografiche, istituzionali e ISO, con la gerarchia da applicare nei conflitti e i link
  consultabili**: [reference/fonti-normative.md](reference/fonti-normative.md). Leggilo solo quando
  una forma è dubbia o quando devi citare la fonte all'utente.
