# Strumenti di misura e soglie industriali

Riferimento da leggere quando il conteggio a mano non basta: il perimetro supera la decina di metodi, il progetto ha già un analizzatore configurato, oppure serve impostare una soglia in CI.

**Nessuno di questi strumenti è necessario.** La via primaria della skill è il conteggio a mano, che non richiede installazioni e regge sul perimetro ridotto per cui la skill è pensata. Quanto segue serve solo nei casi in cui un tool si guadagna il posto.

## Indice

1. [IntelliJ IDEA — ispezione nativa](#intellij-idea--ispezione-nativa)
2. [Java — PMD](#java--pmd)
3. [Java — Checkstyle](#java--checkstyle)
4. [Java — SonarQube](#java--sonarqube)
5. [Multi-linguaggio — lizard](#multi-linguaggio--lizard)
6. [JavaScript e TypeScript — ESLint](#javascript-e-typescript--eslint)
7. [Python — radon](#python--radon)
8. [Go — gocyclo](#go--gocyclo)
9. [Perché i tool danno numeri diversi](#perché-i-tool-danno-numeri-diversi)
10. [Soglie industriali di riferimento](#soglie-industriali-di-riferimento)
11. [Uso in CI](#uso-in-ci)

---

## IntelliJ IDEA — ispezione nativa

**L'opzione a costo zero se il progetto si sviluppa in IDEA**: nessun plugin, nessuna dipendenza nel build, disponibile anche in Community.

- **Nome in UI**: «Overly complex method», in *Settings | Editor | Inspections | Java | Method metrics*
- **Nome interno** nel profilo `.idea/inspectionProfiles/*.xml`: `CyclomaticComplexity`
- **Soglia**: attributo `m_limit`, default **10** (in UI: «Method complexity limit»)
- **Variante Groovy**: ispezione distinta, `GroovyOverlyComplexMethod`

Abilitata l'ispezione nel profilo del progetto, i metodi sopra soglia diventano warning in editor. Se è attivo il server MCP `idea`, `get_file_problems` sul file misurato dovrebbe riportarli insieme agli altri warning: è la via più economica per ottenere una conferma automatica senza toccare `pom.xml` o `build.gradle`.

**Cosa conta**, verificato sul sorgente (`CyclomaticComplexityVisitor`, in `java/java-analysis-impl/src/com/siyeh/ig/classmetrics/`): parte da 1; `if`, `for`, `foreach`, `while`, `do-while`, ternario e ogni blocco `catch` valgono +1; `&&` e `||` valgono +1 per operatore; `default` e `finally` non contano; un gruppo di `case` in fall-through vale +1 complessivo, mentre ogni regola di uno switch a freccia vale +1; i punti di decisione delle lambda sono attribuiti al metodo contenitore, quelli delle **classi anonime sono esclusi**.

È la stessa convenzione adottata dalla skill: conteggio a mano e ispezione danno lo stesso numero. Attenzione a non confonderla con le due ispezioni vicine nella stessa schermata: «Overly complex class» misura la somma dei CCN della classe (soglia 80), «Method with too many exceptions declared» conta la clausola `throws` e non ha nulla a che vedere con la complessità.

Esecuzione headless, per un report su tutto il progetto:

```bash
idea.sh inspect <progetto> <profilo.xml> <cartella-output>     # Linux
inspect.sh <progetto> <profilo.xml> <cartella-output>          # macOS
idea64.exe inspect <progetto> <profilo.xml> <cartella-output>  # Windows
```

Non è documentato in modo univoco se il comando `inspect` richieda la Ultimate. L'alternativa moderna di JetBrains per la CI è **Qodana** (`qodana scan`), che include le stesse ispezioni.

Il plugin **MetricsReloaded** (mantenuto, ultima release 1.11.2 del marzo 2025) aggiunge un tool window con metriche aggregate per progetto, package, classe e metodo, snapshot e confronto storico, oltre alla Cognitive Complexity. Serve per l'analisi di un codebase intero, non per il caso d'uso di questa skill.

Fonti: `https://www.jetbrains.com/help/inspectopedia/OverlyComplexMethod.html`, `https://www.jetbrains.com/help/idea/command-line-code-inspector.html`

## Java — PMD

Regola `CyclomaticComplexity`, categoria `category/java/design.xml`.

```xml
<rule ref="category/java/design.xml/CyclomaticComplexity">
  <properties>
    <property name="methodReportLevel" value="10" />
    <property name="classReportLevel" value="80" />
  </properties>
</rule>
```

- `methodReportLevel` — soglia per metodo, default **10**
- `classReportLevel` — soglia per classe, default **80**

PMD espone anche una regola distinta `CognitiveComplexity` nella stessa categoria. Il nome esatto della property di soglia va verificato sulla documentazione della versione di PMD in uso: non è confermato qui.

Fonte: `https://pmd.github.io/pmd/pmd_rules_java_design.html`

## Java — Checkstyle

Modulo `CyclomaticComplexity` (`com.puppycrawl.tools.checkstyle.checks.metrics.CyclomaticComplexityCheck`).

```xml
<module name="CyclomaticComplexity">
  <property name="max" value="10"/>
</module>
```

- `max` — soglia per metodo, default **10**

È l'opzione più semplice da innestare in un progetto Maven o Gradle che ha già Checkstyle configurato: nessuna dipendenza nuova.

Fonte: `https://checkstyle.org/checks/metrics/cyclomaticcomplexity.html`

## Java — SonarQube

La regola storica sulla complessità ciclomatica risulta deprecata; quella corrente è **«Methods should not be too complex»**, con soglia configurabile dal Quality Profile. SonarQube traccia inoltre la **Cognitive Complexity** come metrica distinta.

La chiave esatta della regola e i valori di default variano tra versioni di SonarQube e di SonarJava: **verificali sul Quality Profile in uso** invece di assumerli.

## Multi-linguaggio — lizard

Analizzatore da riga di comando scritto in Python. Copre 20+ linguaggi (Java, Python, JavaScript, TypeScript, Go, C/C++, C#, Swift, Rust, PHP, Ruby, Kotlin, Scala) e **non richiede di compilare il progetto né di risolverne le dipendenze**: fa analisi lessicale. È la scelta giusta su un codebase poliglotta, dove serve un numero confrontabile tra linguaggi diversi.

Il rovescio: essendo lessicale è meno preciso di un analizzatore che conosce il linguaggio. Su un progetto Java puro, PMD o Checkstyle danno risultati migliori.

**Installazione — solo PyPI:**

```bash
pip install lizard
```

Non esiste un pacchetto npm ufficiale. Il pacchetto npm chiamato `lizard` è un progetto abbandonato e non correlato: `npm install -g lizard` e `npx lizard` **non installano né eseguono questo analizzatore**.

**Uso:**

```bash
lizard -C 10 src/                        # soglia CCN 10 (equivalente: --CCN 10)
lizard -T cyclomatic_complexity=10 src/  # forma generica su qualunque metrica
lizard -w src/                           # solo i warning, formato clang/gcc
lizard --warning-msvs src/               # solo i warning, formato Visual Studio
lizard -i 0 src/                         # errore se c'è almeno un warning
lizard --csv src/ > report.csv           # esportazione
```

La soglia CCN di default è **15**. Non c'è un flag `--fail`: il fallimento in CI passa dall'**exit code**, che è diverso da zero quando ci sono warning. `-i NUMBER` tollera fino a `NUMBER` warning prima di fallire.

Oltre al CCN, lizard riporta per ogni funzione **NLOC** (righe al netto di vuoti e commenti), **numero di token** e **numero di parametri**: utili come metriche complementari.

Fonte: `https://github.com/terryyin/lizard`

## JavaScript e TypeScript — ESLint

La regola `complexity` è nativa, ma **va abilitata**: `npx eslint file.ts` da solo non misura nulla.

```bash
npx eslint --rule '{"complexity": ["error", 10]}' src/
```

In configurazione:

```javascript
// eslint.config.js
export default [
  {
    rules: {
      complexity: ["error", { max: 10 }],
    },
  },
];
```

Per la complessità cognitiva serve il plugin `eslint-plugin-sonarjs`, regola `sonarjs/cognitive-complexity`.

## Python — radon

```bash
pip install radon

radon cc percorso/ -s          # complessità per funzione, con il punteggio
radon cc percorso/ -nc         # solo i blocchi con rank C o peggiore
radon cc percorso/ -s -a       # aggiunge la media del progetto
```

Radon assegna un rank in lettere: **A** (1-5), **B** (6-10), **C** (11-20), **D** (21-30), **E** (31-40), **F** (41+).

## Go — gocyclo

```bash
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest

gocyclo -over 10 .        # elenca le funzioni sopra 10
gocyclo -top 20 .         # le 20 funzioni più complesse
```

## Perché i tool danno numeri diversi

Non esiste un'unica implementazione di McCabe. Le differenze ricorrenti:

| Costrutto | Chi lo conta |
|-----------|--------------|
| `&&` e `\|\|` | la maggior parte sì, alcuni no |
| operatore ternario | quasi tutti sì |
| `default` dello `switch` | alcuni sì |
| `catch` | quasi tutti sì; `finally` quasi mai |
| lambda e closure | alcuni le contano nel metodo contenitore, altri come unità separate |

Conseguenze operative:

- **Usa sempre lo stesso strumento** quando confronti due misure.
- **Dichiara quale strumento o quale convenzione** hai usato in ogni report.
- **Guarda le variazioni relative**, non i valori assoluti, quando confronti misure di origine diversa.

## Soglie industriali di riferimento

**McCabe (1976)** — massimo raccomandato **10**, sulla base di studi empirici di affidabilità: sopra 10 i tassi di difetto crescono in modo significativo.

**NIST SP 500-235** — 10 come punto di partenza. Ammette fino a **15** solo per progetti con vantaggi operativi documentati: personale esperto, processi di design formali, walkthrough sistematici, piani di test completi. La formulazione ufficiale è che «limiti sopra 10 vanno riservati a progetti che hanno diversi vantaggi operativi rispetto al progetto tipico».

**Microsoft Visual Studio** — soglia di warning a **25**; verde fino a 10, giallo 11-20, arancione 21-25, rosso oltre.

**NASA SATC** — la valutazione più efficace combina **dimensione e complessità**: i moduli con complessità alta *e* dimensione grande sono i meno affidabili. Non valutare mai la complessità isolatamente.

| Complessità | Righe di codice | Rischio |
|-------------|-----------------|---------|
| ≤10 | qualunque | basso |
| 11-15 | <100 | moderato |
| 11-15 | 100-200 | alto |
| 16-25 | qualunque | alto |
| >25 | qualunque | critico |

**SonarQube** — default a 10 per funzione. Severità: Info 10-15, Minor 16-20, Major 21-25, Critical oltre 26.

## Uso in CI

Due avvertenze prima di aggiungere un gate:

- **Misura prima, blocca poi.** Introdurre una soglia su un codebase mai misurato produce centinaia di errori al primo run. Il percorso praticabile è: misura la baseline, imposta la soglia sopra il picco esistente, e blocca solo sul **peggioramento** dei file toccati.
- **La soglia sui file nuovi può essere più stretta di quella sul codice esistente.** SonarQube chiama questo approccio *clean as you code*, e si replica in qualunque CI limitando il controllo ai file modificati nella PR.

Esempio con lizard, limitato ai file modificati rispetto al branch di destinazione:

```bash
git diff --name-only --diff-filter=ACM origin/main...HEAD \
  | grep -E '\.(java|ts|py|go)$' \
  | xargs --no-run-if-empty lizard -C 15 -w
```

L'exit code diverso da zero fa fallire lo step. `-C 15` come soglia di blocco e un report informativo a `-C 10` è una combinazione ragionevole: avvisa a 10, blocca a 15.
