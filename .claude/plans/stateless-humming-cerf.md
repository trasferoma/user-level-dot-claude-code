# Piano: documentare async dispatch come feature futura + rimuovere multi-modulo da SPEC.md

## Contesto
Dopo la discussione su §17 (dispatch asincrono), l'utente ha deciso di **non**
implementarlo ora: va registrato tra le funzionalità future in un nuovo file
`features.md`. Inoltre l'utente **non vuole** il layout Maven multi-modulo: il
concetto va **eliminato** da `SPEC.md` (resta un singolo modulo Maven, come è
oggi). È un intervento di sola documentazione: nessun codice, nessun test.

## Modifiche

### 1. Nuovo file `features.md` (root progetto, accanto a SPEC.md)
Documento "Funzionalità future / backlog". Prima voce: **Dispatch asincrono (§17)**.
Contenuto della voce:
- Scopo: disaccoppiare l'esecuzione dei listener dal thread del task, così un
  listener lento (I/O, UI remota) non rallenta il task. Oggi il dispatch è
  sincrono sul thread del chiamante (`InMemoryTaskTransport.publish` +
  `TaskReporter.emit` `synchronized`).
- Cosa cambierebbe: il task accoda l'evento e prosegue; un thread separato
  consegna ai listener.
- Avvertenza semantica: in async i fallimenti di consegna **non** sono più
  "rethrow-abili" verso il task; il dispatcher dovrebbe isolare e loggare le
  eccezioni dei listener.
- Decisioni aperte (da affrontare se/quando si farà): decoratore
  `AsyncTaskTransport` vs flag sul transport; backpressure (coda bounded con drop
  vs illimitata); ordinamento (singolo thread dispatcher per preservare l'ordine).
- Stato: **non pianificato per ora**, sync resta il default.

Lascio il file pronto a ospitare altre feature future (rimando a SPEC §24/§25 per
transport socket, Spring starter, ecc.) senza duplicarle in dettaglio.

### 2. `SPEC.md` — rimuovere il concetto multi-modulo
- **§14 "Moduli Maven proposti"** (righe ~515-568): rimuovere l'elenco
  `task-telemetry-parent`/`-core`/`-transport-*`/`-spring-boot-starter` e i
  sotto-paragrafi §14.1–§14.4. Sostituire con una breve sezione che dichiara
  **modulo Maven singolo** per scelta (niente split multi-modulo). Mantengo il
  numero di sezione (§14) per non rinumerare tutto il documento.
- **§29** (righe ~946-962): rimuovere il blocco "Layout Maven previsto
  (multi-modulo)" e la nota "conversione a multi-modulo resta da fare";
  sostituire con una riga che indica il modulo singolo.
- **§30.2 "Non ancora implementato"**:
  - rimuovere il bullet "Layout Maven multi-modulo (§14)";
  - cambiare il bullet del dispatch asincrono in: rimando a `features.md`
    (es. "Dispatch asincrono opzionale (§17): non pianificato, vedi `features.md`").
- **§30.1** (riga ~999 "Baseline: ... modulo singolo"): invariata (già corretta).

Note: NON tocco §1 (Spring come supporto futuro/opzionale), §24 (transport socket
futuro) e §25 (Spring starter, broker): sono *capability* future, non il layout
multi-modulo. Se l'utente vuole anche ripulire la parola "modulo" da §1, lo farò
su richiesta.

## Verifica
- `grep -n "multi-modulo|multi modulo|task-telemetry-core|transport-inmemory|spring-boot-starter|task-telemetry-parent" SPEC.md` → nessun residuo del layout multi-modulo (restano solo le frasi "modulo singolo", che sono lo stato voluto).
- `features.md` esiste e contiene la voce "Dispatch asincrono (§17)".
- Nessuna build necessaria (solo documentazione).
