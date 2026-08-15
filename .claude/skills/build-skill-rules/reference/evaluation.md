# Reference: valutare e iterare su una skill

## Indice
- Il principio: le valutazioni prima della documentazione
- Sviluppo eval-first in cinque passi
- Formato di una valutazione
- Il confronto con la baseline
- Le due cose da misurare separatamente
- Il ciclo di iterazione con due istanze del modello
- Segnali da osservare in uso reale
- Testare sui modelli che userai davvero
- Il plugin skill-creator
- Feedback dal team

---

## Il principio: le valutazioni prima della documentazione

**Crea le valutazioni PRIMA di scrivere documentazione estesa.** Serve a garantire che la skill risolva problemi reali e osservati, invece di documentare requisiti immaginati che potrebbero non materializzarsi mai.

Le valutazioni sono la fonte di verità per misurare l'efficacia di una skill. Senza di esse hai solo l'impressione che la skill funzioni, che è un'informazione notoriamente inaffidabile su testi che hai scritto tu.

---

## Sviluppo eval-first in cinque passi

1. **Identifica i gap.** Fai svolgere il compito rappresentativo **senza** la skill. Documenta i fallimenti specifici e il contesto che hai dovuto fornire a mano.
2. **Crea le valutazioni.** Costruisci **almeno tre** scenari che mettono alla prova esattamente quei gap.
3. **Stabilisci la baseline.** Misura le prestazioni senza la skill.
4. **Scrivi il minimo indispensabile.** Solo il contenuto necessario a chiudere i gap e passare le valutazioni. Non un capitolo in più.
5. **Itera.** Esegui le valutazioni, confronta con la baseline, raffina.

---

## Formato di una valutazione

Una valutazione data-driven con rubrica semplice:

```json
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

Note operative:
- Non esiste un modo integrato per eseguire queste valutazioni: serve costruirsi un sistema, oppure usare il plugin `skill-creator` (sotto).
- `expected_behavior` va scritto come **asserzioni verificabili**, non come giudizi vaghi tipo «fa un buon lavoro».
- Le query devono essere richieste realistiche, formulate come le formulerebbe l'utente, non riscritte per assomigliare alla description.

---

## Il confronto con la baseline

Il test per qualunque proprietà di una skill è lo stesso: raccogli qualche prompt realistico, eseguili **in una sessione nuova** con la skill disponibile e di nuovo con la skill disattivata (`skillOverrides` a `"off"`), e confronta i risultati.

> La sessione nuova non è un dettaglio procedurale. Il contesto residuo della sessione in cui hai scritto la skill **maschera esattamente i buchi** nelle istruzioni scritte: il modello sa già cosa intendevi perché gliel'hai spiegato a voce, non perché sta nel file.

---

## Le due cose da misurare separatamente

Vedere una skill attivarsi dice che il modello l'ha trovata, **non** che ha fatto quello che volevi. Sono due misure distinte:

1. **Attivazione**: il modello invoca la skill sui prompt su cui dovrebbe, e **non** su quelli su cui non dovrebbe. Un problema qui è un problema di `description`.
2. **Qualità dell'output**: quando si attiva, il risultato è quello atteso. Un problema qui è un problema di corpo, workflow o file di reference.

Diagnosticarle insieme porta a correggere il file sbagliato.

---

## Il ciclo di iterazione con due istanze del modello

Il processo più efficace usa **due istanze**: una istanza «A» che ti aiuta a progettare e raffinare la skill, e una istanza «B» — sessione fresca, con la skill caricata — che la usa su compiti reali. A capisce cosa serve a un agente, tu porti la conoscenza di dominio, B rivela i buchi con l'uso reale.

### Creare una skill nuova

1. **Svolgi il compito senza skill** con l'istanza A, con prompting normale. Nota quale contesto fornisci ripetutamente.
2. **Individua il pattern riutilizzabile**: quale contesto sarebbe utile anche per compiti simili futuri?
3. **Chiedi a A di creare la skill**, elencando esplicitamente cosa deve contenere. Le istanze conoscono nativamente il formato: non serve un prompt speciale.
4. **Rivedi per concisione.** Verifica che A non abbia aggiunto spiegazioni inutili: «togli la spiegazione di cosa sia il win rate, è già noto».
5. **Migliora l'architettura dell'informazione**: «sposta lo schema delle tabelle in un file di reference separato, potremmo aggiungerne altre».
6. **Testa con B** su casi d'uso affini. Osserva se trova l'informazione giusta, applica le regole e porta a termine il compito.
7. **Itera sulla base dell'osservazione.** Torna a A con fatti specifici: «usando questa skill ha dimenticato di filtrare per data nel Q4; serve una sezione sui pattern di filtro temporale?».

### Iterare su una skill esistente

Lo stesso schema, alternando:

1. **Usa la skill in workflow reali** con B — compiti veri, non scenari di test.
2. **Osserva il comportamento di B**: dove fatica, dove riesce, dove fa scelte inattese.
3. **Torna a A con l'osservazione concreta**, condividendo il SKILL.md attuale: «ha dimenticato di filtrare gli account di test anche se la skill lo menziona; forse non è abbastanza in evidenza?».
4. **Valuta le proposte di A**: riorganizzare per dare risalto alle regole, usare linguaggio più forte (`DEVE filtrare` invece di `filtra sempre`), ristrutturare la sezione di workflow.
5. **Applica e ritesta** su richieste simili.
6. **Ripeti** man mano che incontri scenari nuovi. Ogni iterazione migliora la skill sul comportamento osservato, non su ipotesi.

---

## Segnali da osservare in uso reale

Guarda **come** la skill viene effettivamente navigata:

| Segnale | Cosa significa | Cosa fare |
|---------|----------------|-----------|
| Percorsi di esplorazione inattesi | i file vengono letti in un ordine che non avevi previsto | la struttura non è intuitiva come pensavi: rivedi l'organizzazione |
| Riferimenti non seguiti | i link a file importanti vengono ignorati | rendi i link più espliciti e più in evidenza in `SKILL.md` |
| Sovra-dipendenza da una sezione | lo stesso file viene riletto continuamente | quel contenuto probabilmente va spostato **dentro** `SKILL.md` |
| Contenuto mai toccato | un file bundled non viene mai aperto | è inutile, oppure è segnalato male nelle istruzioni principali |

Itera su queste osservazioni, non su assunzioni. `name` e `description` restano i due campi più critici: sono ciò che il modello usa per decidere se la skill è pertinente al compito corrente.

---

## Testare sui modelli che userai davvero

Una skill è un'aggiunta al modello, quindi la sua efficacia dipende dal modello sottostante.

| Modello | Domanda di test |
|---------|-----------------|
| Haiku (veloce, economico) | la skill fornisce **abbastanza** guida? |
| Sonnet (bilanciato) | la skill è chiara ed efficiente? |
| Opus (ragionamento potente) | la skill evita di **spiegare troppo**? |

Ciò che funziona perfettamente con Opus può richiedere più dettaglio con Haiku. Se la skill deve girare su più modelli, punta a istruzioni che funzionano con tutti.

---

## Il plugin skill-creator

Il plugin ufficiale `skill-creator` automatizza il ciclo di confronto dentro Claude Code.

```text
/plugin install skill-creator@claude-plugins-official
```

Se il marketplace non risulta trovato: `/plugin marketplace add anthropics/claude-plugins-official`. Se il plugin non risulta nel marketplace, la copia locale è vecchia: `/plugin marketplace update claude-plugins-official`. Dopo l'installazione, `/reload-plugins` rende disponibili le sue skill nella sessione corrente.

Poi si chiede una valutazione, per esempio «valuta la mia skill summarize-changes con skill-creator». Il plugin:

- **Test case**: memorizza prompt, file di input e comportamento atteso in `evals/evals.json` dentro la directory della skill
- **Esecuzioni isolate**: un subagent per test case, così ogni run parte da contesto pulito; registra token e durata
- **Grading**: verifica ogni asserzione e scrive esito con evidenze in `grading.json`
- **Benchmark**: aggrega pass rate, tempo e token con e senza skill in `benchmark.json`, così puoi confrontare il miglioramento di pass rate contro l'overhead in token e tempo
- **Confronto di versioni**: A/B cieco tra due versioni, per confermare che una modifica è davvero un miglioramento prima di committarla
- **Tuning della description**: genera prompt che dovrebbero e non dovrebbero attivare la skill, misura l'hit rate e propone modifiche quando la skill si attiva sulle richieste sbagliate
- **Viewer di review**: report HTML dove ispezionare ogni output e registrare feedback qualitativo che l'iterazione successiva legge

Formato del file di eval e workflow completo: `https://agentskills.io/skill-creation/evaluating-skills`.

---

## Feedback dal team

1. Condividi le skill con i colleghi e **osserva come le usano**.
2. Chiedi: la skill si attiva quando te lo aspetti? Le istruzioni sono chiare? Cosa manca?
3. Incorpora il feedback per coprire i gap che i tuoi pattern d'uso personali non hanno rivelato.
