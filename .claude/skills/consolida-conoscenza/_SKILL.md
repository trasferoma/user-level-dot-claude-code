---
name: consolida-conoscenza
description: Estrae, classifica e propone per approvazione la conoscenza riutilizzabile emersa da un'attività di sviluppo (regole di progetto) o dall'esplorazione del codice (schede funzionalità). Skill SOLO a invocazione manuale (`/consolida-conoscenza` o richiesta esplicita di consolidare/mappare la conoscenza): non attivarla mai in autonomia, né a fine sessione, né dopo una modifica al codice, né quando l'utente chiede una normale documentazione.
---

# Consolida conoscenza

Curatore della conoscenza di progetto. Non scrive mai direttamente: estrae, classifica, propone, attende conferma.

## Due modalità

Determina la modalità dalla richiesta. In caso di ambiguità, chiedi.

| Modalità | Quando | Produce |
|---|---|---|
| `cura` (default) | Al termine di un'attività di sviluppo già revisionata | Aggiornamento schede in `docs/features/`; per eccezione, regole in `.claude/rules/` |
| `mappa` | Su richiesta esplicita di mappare un'area di codice | Schede nuove + riga nell'indice |

Le due classi di conoscenza hanno natura diversa e non vanno mescolate nello stesso file: le regole sono prescrittive e stabili, le schede sono descrittive e inseguono il codice.

---

## Modalità `cura`

### Determinare il punto di partenza

Risolvi la baseline in quest'ordine e **dichiarala sempre all'utente prima di analizzare**, con il numero di file e di righe coinvolte. Non procedere su una baseline indovinata.

1. **Riferimento esplicito nell'invocazione** (`/consolida-conoscenza da <commit|tag|branch>`) — usalo e basta.

2. **Branch di lavoro.** Individua il branch di integrazione:
   ```bash
   git symbolic-ref --short refs/remotes/origin/HEAD    # es. origin/develop
   ```
   Se fallisce, cerca fra `develop`, `main`, `master` sui remoti. Se ne esiste più d'uno e non è ovvio quale, chiedi. Poi:
   ```bash
   git merge-base HEAD <branch-di-integrazione>
   ```

3. **Sei già sul branch di integrazione, oppure il merge-base coincide con HEAD.** Non c'è un intervallo deducibile: usa solo il lavoro non committato. Se non ce n'è, chiedi l'intervallo e fermati.

Il lavoro non ancora committato va incluso **sempre**, in tutti e tre i casi:
```bash
git status --porcelain
git diff                # non in stage
git diff --staged       # in stage
```

### Raccogliere l'evidenza

```bash
git log --oneline <base>..HEAD        # cosa è stato fatto
git diff --stat <base>...HEAD         # ampiezza, prima di leggere
git diff <base>...HEAD -- <path>      # mirato, file per file
```

Parti sempre da `--stat`. Se il diff supera qualche centinaio di righe non caricarlo per intero: scegli i file più significativi, leggi quelli, e dichiara quali hai escluso. Una baseline sbagliata per eccesso produce regole tratte da lavoro che non c'entra con l'attività.

### Fonti di evidenza

Giudica i fatti, non il racconto. Nell'ordine:

1. Il diff calcolato sopra
2. Output della revisione e correzioni richieste
3. Problemi dichiarati dall'utente

Non trattare come evidenza le motivazioni fornite da chi ha implementato: chi ha appena scritto il codice sopravvaluta le proprie decisioni contingenti. Se una scelta non è ricostruibile dal diff o dalla revisione, non è materiale da regola.

### Triage: prima la funzionalità, poi la regola

Questo passaggio viene prima di tutto il resto ed è quasi sempre l'unico che produce qualcosa.

**Domanda uno: il diff cambia cosa fa l'applicazione per chi la usa?** Se sì, l'esito è l'aggiornamento di una scheda in `docs/features/` — non una regola. È il caso più frequente in assoluto. Aggiorna la scheda esistente, o proponine una nuova se l'area non ne ha.

**Domanda due: il diff ha rivelato un vincolo che resterà vero anche riscrivendo il codice da zero?** Solo in questo caso proponi una regola.

Se entrambe le risposte sono no, l'esito corretto è **nessuna proposta**. Dillo e fermati.

### I due filtri

Applicali prima di formulare qualsiasi proposta. Scartano la maggior parte delle candidate, ed è il loro scopo.

**Filtro di sopravvivenza.** Riscrivendo la stessa funzionalità da zero, con altro codice, l'affermazione sarebbe ancora vera?

- «Lato operatore l'istanza compilata del richiedente fa parte degli allegati del richiedente» → sopravvive. È conoscenza.
- «L'indice finale va clampato con `Math.min` prima di `subList`» → non sopravvive. È cronaca di come è stato fatto oggi, e per di più è già scritta nel codice appena prodotto.

**Filtro di genericità.** L'affermazione sarebbe vera in qualunque progetto che usa lo stesso framework alla stessa versione? Se sì, non è conoscenza di progetto: è una caratteristica del framework. Scarta.

Un fatto già presente nel codice consegnato non va mai riproposto come regola: il codice è già la sua documentazione.

### Criteri di ammissione

Oltre ai filtri, proponi solo se valgono **tutti**:

1. Può evitare un errore futuro
2. Non è evidente dal codice che l'attività ha appena prodotto
3. È stata verificata durante il lavoro
4. Non è già documentata altrove
5. Sta in una frase
6. Ha un ambito preciso: sessione, progetto o generale

### Forma del testo proposto

**Una sola frase dichiarativa, venticinque parole al massimo.** Se non ci sta, è dettaglio implementativo travestito da conoscenza.

Nel testo sono ammessi i nomi delle entità di dominio e dei componenti coinvolti. Sono vietati i meccanismi: predicati di query, valori di campi, nomi di metodi di utilità, selettori CSS, firme. Sono vietati i riferimenti allo stato precedente del codice e alla storia della modifica.

### Tetto alle proposte

**Massimo tre per esecuzione**, ordinate per valore decrescente.

**Zero è un esito normale e frequente.** Il tetto è un limite, non un obiettivo: la maggior parte delle attività non produce conoscenza riutilizzabile, e una sessione che si chiude con «niente da consolidare» è un successo del filtro, non un fallimento. Non cercare candidate fino a riempire il tetto.

Se hai più di tre candidate valide, presenta le tre migliori e segnala in una riga che ce ne sono altre, senza elencarle.

### Verifica di collisione (obbligatoria)

Prima di formulare qualsiasi proposta, leggi le regole esistenti in `.claude/rules/` e dichiara esplicitamente la relazione:

- **aggiunta** — argomento non coperto
- **raffinamento** — precisa una regola esistente, che va citata
- **contraddizione** — smentisce una regola esistente, che va citata

Una contraddizione non si risolve aggiungendo: si risolve sostituendo. Senza questo passaggio il corpus accumula regole che si smentiscono a vicenda e chi legge ne sceglie una a caso.

### Classificazione

| Livello | Contenuto | Destinazione |
|---|---|---|
| Sessione | Dettagli utili solo al lavoro corrente | Non persistente — scarta |
| Progetto | Architettura, convenzioni, eccezioni, decisioni locali | `.claude/rules/<tema>.md` |
| Generale | Tecniche valide anche per altri progetti | Skill o configurazione personale |

Il livello **generale** richiede una prova: la conoscenza deve essere stata osservata in almeno due contesti distinti. Finché la prova manca resta di progetto, anche se sembra generalizzabile. Promuovere troppo presto esporta una stranezza locale come verità universale.

Quando una regola dipende da una versione (libreria, framework, runtime), la versione va scritta **dentro** la regola. È il tipo di conoscenza che diventa falsa dopo un upgrade, e una regola falsa fa più danni di una regola assente.

### Formato della proposta

Per ciascuna candidata, esattamente questi campi:

```
Testo proposto: <una o due frasi, imperative, operative>
Motivazione: <cosa si rompe se la regola viene violata>
Destinazione: <path del file>
Relazione: aggiunta | raffinamento di "<regola>" | contraddice "<regola>"
Provenienza: <data> @ <commit>
```

Poi chiedi conferma, una proposta alla volta. **Scrivi il file solo dopo un sì esplicito.** Un silenzio, un «ok grazie» o un cambio di argomento non sono conferme.

### Esempi

Attività: lato operatore, il PDF dell'istanza firmata dal cittadino entra nella lista degli allegati del richiedente. Sono stati risolti lungo la strada un errore di paginazione e un problema di larghezza colonne.

**Da proporre** — scheda funzionalità, non regola:
> Lato operatore l'istanza compilata del richiedente fa parte degli allegati del richiedente.

Sopravvive alla riscrittura, descrive il comportamento, sta in una riga, non si legge da nessun singolo punto del codice.

**Da scartare:**

| Candidata | Perché |
|---|---|
| Clamp dell'indice finale prima di `subList` | Non sopravvive alla riscrittura; è già nel codice consegnato |
| Qualificare il selettore CSS per vincere sulla specificità del framework | Generica del framework, non del progetto |
| Composizione della lista tramite un metodo invece di un altro, con i predicati della query | Meccanismo implementativo; supera le venticinque parole; riferimenti allo stato precedente |

Le ultime due sarebbero comunque sopravvissute a un test del tipo «mi sarebbe servito saperlo stamattina»: è vero, ma non le rende conoscenza. Serviva saperlo una volta sola, durante quella modifica.

---

## Modalità `mappa`

Esplora l'area indicata e produci le schede delle funzionalità che non ne hanno già una. Serve a coprire il codice preesistente, che la modalità `cura` non raggiunge mai perché scatta solo su ciò che è stato toccato.

### Regola di ammissione del contenuto

**Se lo ottieni con un grep, non va scritto.**

Nomi di classi, firme di metodi, elenchi di parametri, campi di tabella, il flusso passo-passo di un metodo: tutto questo si legge dal sorgente in tre secondi ed è sempre aggiornato. Una scheda che li ripete è una traduzione del codice, più lunga e meno affidabile dell'originale.

Quello che il grep non dà è il collegamento tra le cose: comportamento complessivo, invarianti, vincoli, relazioni tra funzionalità. È l'unico contenuto che giustifica la scheda.

### Formato della scheda

Massimo **quindici righe**. Frasi dichiarative al presente, una per riga.

```markdown
# <Nome funzionalità>
Ambito: <package / modulo / area>
Verificata: <data> @ <commit>

<Cosa fa, dal punto di vista del comportamento osservabile.>
<Invarianti e vincoli da non violare.>
<Eccezioni note.>

Ingresso: <classe o endpoint principale>
Collegate: [<altra-scheda>], [<altra-scheda>]
```

Vincoli formali:

- Niente blocchi di codice dentro le schede. Uno snippet incollato è una copia che diverge al primo refactoring: cita il file, non il contenuto.
- Niente storia della decisione. Non «si è deciso di», non «in modo da», non «durante l'analisi è emerso». È così e basta.
- La motivazione è ammessa solo nelle **regole**, e solo nella forma breve di cosa si rompe. «Mai dal repository: salta l'audit», non un paragrafo.

### Indice

Ogni scheda ha una riga in `docs/features/INDEX.md`: nome, una frase di dieci parole, link alla scheda.

L'indice è l'unico file richiamato sempre da `CLAUDE.md`. Le schede si caricano su richiesta. Nella maggior parte delle sessioni basta sapere che una funzionalità esiste e dove sta, senza aprirne la scheda.

---

## Manutenzione

Su richiesta esplicita, due operazioni di igiene del corpus.

**Audit di freschezza.** Per ogni scheda, confronta il `git log` dei path citati con la data in `Verificata:`. Elenca le schede i cui path hanno subito modifiche successive. Non riscriverle: segnalale e chiedi quali rivedere. Documentazione che mente è peggio di documentazione assente, perché viene creduta.

**Potatura.** Elenca le regole mai risultate pertinenti negli ultimi N task e chiedi se tenerle. Un sistema che accumula soltanto non compone: si gonfia.

---

## Cosa non fare mai

- Scrivere o modificare un file senza conferma esplicita
- Superare le tre proposte per esecuzione
- Proporre una regola senza aver letto le regole esistenti
- Mettere conoscenza descrittiva in `.claude/rules/` o prescrittiva in `docs/features/`
- Riformulare in italiano ciò che il codice già dice
- Attivarsi in autonomia
- Creare un file per ogni singola regola: le regole si raggruppano per tema in `.claude/rules/<tema>.md`, un file nuovo solo per un tema nuovo
- Scrivere in directory diverse da quelle indicate qui, incluse le directory di memoria di sessione dell'agente: quelle non sono versionate nel repository e non seguono il codice
