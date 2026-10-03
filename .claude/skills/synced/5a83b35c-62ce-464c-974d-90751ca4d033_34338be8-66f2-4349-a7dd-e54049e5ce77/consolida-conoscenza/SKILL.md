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
| `cura` (default) | Al termine di un'attività di sviluppo già revisionata | Regole in `.claude/rules/` |
| `mappa` | Su richiesta esplicita di mappare un'area di codice | Schede in `docs/features/` + riga nell'indice |

Le due modalità producono conoscenza di natura diversa e non vanno mescolate nello stesso file: le regole sono prescrittive e stabili, le schede sono descrittive e inseguono il codice.

---

## Modalità `cura`

### Fonti di evidenza

Giudica i fatti, non il racconto. Nell'ordine:

1. `git diff` rispetto al punto di partenza dell'attività
2. Output della revisione e correzioni richieste
3. Problemi dichiarati dall'utente

Non trattare come evidenza le motivazioni fornite da chi ha implementato: chi ha appena scritto il codice sopravvaluta le proprie decisioni contingenti. Se una scelta non è ricostruibile dal diff o dalla revisione, non è materiale da regola.

### Criteri di ammissione

Proponi una conoscenza solo se soddisfa **tutti** i criteri:

1. Può evitare un errore futuro
2. È una decisione non evidente dal codice
3. È stata verificata durante il lavoro
4. Non è già documentata altrove
5. È formulabile in modo breve e operativo
6. Ha un ambito preciso: sessione, progetto o generale

### Test negativo

Prima di proporre, chiediti: **questa regola avrebbe cambiato quello che è stato fatto oggi?**

Se la risposta è no, scarta. È il filtro che elimina la maggior parte delle candidate.

### Tetto alle proposte

**Massimo tre proposte per esecuzione**, ordinate per valore decrescente. Il rischio del meccanismo non è catturare poco: è l'affaticamento da approvazione. Oltre la terza proposta l'utente approva senza leggere e la qualità del corpus crolla.

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
