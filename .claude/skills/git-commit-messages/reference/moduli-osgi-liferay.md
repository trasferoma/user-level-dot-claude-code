# Reference: moduli OSGi impattati da un commit (progetti Liferay)

## Indice
- Come riconoscere un progetto Liferay/OSGi
- Regola del nome breve
- Derivazione dal diff: file sotto `/src/`
- Derivazione dal diff: file fuori da `/src/`
- Esclusioni
- Controllo di copertura
- Trappole

**I comandi di questo reference sono shell POSIX**: eseguili con il tool **Bash** (Git Bash), non con PowerShell, dove `awk`, `grep`, `while read`, `[ -f ... ]` e `$(...)` non esistono o si comportano diversamente. Un'estrazione eseguita nella shell sbagliata torna vuota senza errore leggibile, e un elenco di moduli vuoto si legge come «commit senza moduli impattati»: è il difetto più grave di questa sezione.

---

## Come riconoscere un progetto Liferay/OSGi

Il progetto è un workspace Liferay se almeno due di questi indizi sono veri:

- esiste una directory `modules/` con sottodirectory che contengono `bnd.bnd`
- esiste `gradle.properties` con `liferay.workspace.*`, oppure `settings.gradle` che applica il plugin `com.liferay.gradle.plugins.workspace`
- esistono directory `bundles/` o `configs/` alla radice
- i sorgenti Java stanno sotto `modules/**/src/main/java` e dichiarano `@Component` con `javax.portlet.*`

Se questi indizi mancano, il progetto **non è** Liferay: la sezione «Moduli impattati» va omessa dal messaggio di commit. Non dedurlo dal nome del repository.

---

## Regola del nome breve

Il nome del modulo è il **segmento di cartella immediatamente precedente a `/src/`**, non il path e non il `Bundle-SymbolicName`.

| Percorso del file modificato | Modulo |
|---|---|
| `modules/gestione-bandi/gestione-bandi-frontend/src/main/java/...` | `gestione-bandi-frontend` |
| `modules/gestione-bandi/gestione-eventi/catalogo-eventi-frontend/src/main/resources/...` | `catalogo-eventi-frontend` |
| `modules/servizi-digitali-common/servizi-digitali-fdr-integration/src/main/java/...` | `servizi-digitali-fdr-integration` |

Questa è la stessa convenzione usata dal report di passaggio in produzione (`release-plan-produzione`): tenerle allineate permette di ritrovare nel report gli stessi nomi scritti nei commit.

Il `Bundle-SymbolicName` di `bnd.bnd` serve solo a **disambiguare** quando due moduli hanno la stessa cartella finale in rami diversi dell'albero. In quel caso, e solo in quel caso, cita il nome breve seguito dal ramo padre: `catalogo-eventi-frontend (gestione-eventi)`.

---

## Derivazione dal diff: file sotto `/src/`

Sui file già staged:

```bash
git --no-pager diff --cached --name-only | awk -F'/src/' 'NF > 1 { print $1 }' | awk -F'/' '{ print $NF }' | sort -u
```

L'output è l'elenco candidato dei moduli, già deduplicato e ordinato. Usalo come punto di partenza, non come verità finale: manca tutto ciò che sta fuori da `/src/`.

---

## Derivazione dal diff: file fuori da `/src/`

`bnd.bnd`, `build.gradle`, `service.xml`, `liferay-plugin-package.properties`, `package.json` e i descrittori stanno alla radice del modulo, senza `/src/` nel percorso. Vanno attribuiti risalendo alla **prima directory antenata che contiene `bnd.bnd`**.

Elenca prima i file rimasti fuori:

```bash
git --no-pager diff --cached --name-only | grep -v '/src/'
```

Poi, per ciascuno, individua la radice del modulo:

```bash
git --no-pager diff --cached --name-only | grep -v '/src/' | while read -r f; do
  d=$(dirname "$f")
  while [ "$d" != "." ] && [ ! -f "$d/bnd.bnd" ]; do d=$(dirname "$d"); done
  if [ -f "$d/bnd.bnd" ]; then echo "$(basename "$d")  <- $f"; else echo "(nessun modulo)  <- $f"; fi
done | sort -u
```

Le righe `(nessun modulo)` sono file di root, script SQL o asset: non diventano moduli, e non sono un errore.

---

## Esclusioni

Non elencare come modulo:

- gli asset frontend sotto `alpaca/` o altre directory fuori da `modules/`
- file di configurazione della radice del repository (`gradle.properties`, `settings.gradle`, `.gitignore`, `README.md`)
- `bundles/`, `configs/`, `build/`, `dist/`, `node_modules/` e qualunque artefatto generato

Un commit composto **solo** da file esclusi non ha moduli impattati: la sezione va omessa.

---

## Controllo di copertura

Prima di chiudere il messaggio:

1. prendi l'elenco completo dei file staged (`git --no-pager diff --cached --name-status`);
2. verifica che ogni file sia o attribuito a un modulo elencato, o riconducibile a un'esclusione dichiarata sopra;
3. se un file non ricade in nessuno dei due casi, non ignorarlo: risali al suo modulo o segnalalo nel report al chiamante.

Un modulo dimenticato rende il messaggio inaffidabile per la ricostruzione a posteriori del rilascio: è il difetto più grave di questa sezione.

---

## Trappole

- **Nomi di cartella ripetuti**: `*-common`, `*-api`, `*-frontend` compaiono sotto padri diversi. Il nome breve resta quello precedente a `/src/`; disambigua solo in caso di collisione reale.
- **File spostati**: un rename tocca due moduli (sorgente e destinazione). `--name-status` mostra `R`: elencali entrambi.
- **Service Builder**: una modifica a `service.xml` rigenera codice in `*-api` e `*-service`. Se il commit include il codice generato, quei moduli vanno elencati; se il codice generato non è versionato, elenca solo il modulo del `service.xml`.
- **Solo `bnd.bnd` toccato**: è comunque una modifica al modulo (versione, export, import). Va elencato.
- **Diff non staged**: i comandi qui usano `--cached`. Se stai componendo il messaggio prima dello staging, sostituisci `--cached` con `HEAD` o ometti l'opzione, ma poi ricontrolla sul contenuto effettivamente staged.
