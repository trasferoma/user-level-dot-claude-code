---
name: git-inspection
description: Ricette per le operazioni git di controllo, verifica e diagnosi su un repository. Usa quando devi capire cosa sta per essere committato o pushato, verificare lo stato di un branch e la divergenza dal remoto, capire chi e quando ha introdotto una modifica o una regressione, ritrovare lavoro apparentemente perso, o controllare la storia prima di una consegna. Copre lettura sicura dello stato (status porcelain, diff staged e unstaged, ahead/behind, file non tracciati), ispezione della storia (log per file o stringa, pickaxe, blame, show), diagnosi (bisect, reflog, fsck, stash), controlli pre-push su segreti e file indesiderati, e le trappole tipiche fra cui il CRLF su Windows e i merge commit. Non modifica mai storia né remoto; le sole eccezioni dichiarate sono bisect e stash.
---

# Scopo
Eseguire in modo sicuro e riproducibile le operazioni git di lettura: capire lo stato del repository, cosa entra in un commit, cosa andrebbe sul remoto, e diagnosticare da dove viene una modifica o una regressione.

# Quando usare questa skill
- devi capire lo stato del working tree, dello staging o del branch rispetto al remoto
- devi verificare cosa entra in un commit o cosa andrebbe su un push
- devi capire chi, quando e perché ha introdotto una riga, un metodo o una regressione
- devi ritrovare lavoro apparentemente perso, o controllare la storia prima di una consegna

# Quando NON usare questa skill
- devi comporre un messaggio di commit: usa `git-commit-messages`
- devi determinare il token di un branch: usa `git-branch-token`
- devi produrre il documento di passaggio in produzione fra due branch: usa `release-plan-produzione`
- l'operazione **modifica** storia, remoto o working tree: qui non ci sono ricette per quello e va autorizzata a parte. Uniche eccezioni, `bisect` (sezione 5) e `stash` (sezione 6)

# Regole di precedenza
- Le istruzioni esplicite dell'utente prevalgono su queste ricette.
- Se un comando qui elencato non esiste nella versione di git installata, dichiaralo invece di improvvisare un equivalente approssimativo.
- In caso di dubbio fra due letture, prevale quella che ispeziona il **contenuto** reale del diff sulla deduzione dai nomi dei file.

# Regole operative

## 0. Regole di sicurezza sempre attive

- **Sempre `git --no-pager`** su `log`, `diff`, `show`, `blame`: senza, il pager resta in attesa di input ed è il modo più comune di far sembrare git bloccato.
- **Sempre l'output stabile dove esiste**: `--porcelain`, `--format`, `--name-status`. L'output «umano» di git può essere localizzato e rompe qualunque filtro.
- **Niente staging alla cieca**: `git add -A` e `git add .` includono file non previsti. Elenca prima, aggiungi poi, esplicitamente.
- **Niente comandi interattivi**: `git rebase -i`, `git add -i`, `git commit` senza `-m`/`-F` aprono un editor e restano appesi.
- **Niente scritture in fase di verifica**: un'ispezione non modifica indice, working tree o remoto. `git bisect` e `git stash` spostano HEAD o l'indice: solo su richiesta e con working tree pulito.
- **Prima il meno costoso**: `-n <N>`, `--stat`, `--name-status`; il diff intero solo sui punti che contano.
- **Le pipeline qui sono shell POSIX**: eseguile con il tool **Bash** (Git Bash). In PowerShell `grep`, `sed`, `awk`, `wc` e `VAR=$(...)` non esistono o si comportano diversamente.

## 1. Stato del repository

```bash
git rev-parse --is-inside-work-tree                 # sei in un repo?
git --no-pager status --porcelain=v1 -b             # stato + branch + tracking, output stabile
git rev-parse --abbrev-ref HEAD                     # branch corrente (HEAD se detached)
git --no-pager status --porcelain=v1 | wc -l        # quante voci in tutto
```

Rileva un'operazione in corso **prima** di qualunque altra cosa: se esistono `.git/MERGE_HEAD`, `.git/rebase-merge` o `.git/CHERRY_PICK_HEAD` il repository è in mezzo a un'operazione e non va toccato con nuovi commit.

Codici di `--porcelain`: `M` modificato, `A` aggiunto, `D` cancellato, `R` rinominato, `??` non tracciato, `UU` in conflitto. Prima colonna l'indice, seconda il working tree.

## 2. Cosa sta per entrare nel commit

```bash
git --no-pager diff --cached --name-status          # file staged, con il tipo di modifica
git --no-pager diff --cached --stat                 # dimensione delle modifiche staged
git --no-pager diff --cached -- <path>              # contenuto reale di ciò che è staged
git --no-pager diff --name-status                   # modifiche NON staged (resterebbero fuori)
git ls-files --others --exclude-standard            # file non tracciati (non entrerebbero)
```

Due domande diverse, due comandi diversi: che tutto il necessario sia staged, e che nulla di estraneo lo sia. Il `diff` senza `--cached` non mostra lo staged.

## 3. Divergenza dal remoto

```bash
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'   # esiste un upstream?
git rev-list --left-right --count 'HEAD...@{u}'          # <avanti> <indietro>
git --no-pager log --oneline '@{u}..HEAD'                # commit che andrebbero sul remoto
git --no-pager log --oneline 'HEAD..@{u}'                # commit del remoto che non hai
git remote -v                                            # dove punta il remoto
```

Se `@{u}` non esiste il branch non ha tracking e ogni comando che lo usa fallisce: ricadi su `origin/<branch>` e dichiara il confronto fatto a mano. `git fetch` aggiorna i riferimenti remoti senza toccare il lavoro locale, ma è un accesso alla rete: fallo se serve un confronto attendibile e dillo.

## 4. Ispezione della storia

```bash
git --no-pager log --oneline --graph --decorate -n 20
git --no-pager log --no-merges --name-only --format='=== %h %s' <base>..<target>   # file per commit
git --no-pager log --follow -p -- <file>            # storia di un file, seguendo i rename
git --no-pager log -L <inizio>,<fine>:<file>        # storia di un intervallo di righe
git --no-pager log -S'<stringa>' --oneline -- <path>   # pickaxe: dove nasce o muore una stringa
git --no-pager log -G'<regex>' --oneline -- <path>     # come sopra, con espressione regolare
git --no-pager show <sha> --stat                    # cosa contiene un commit
git --no-pager show <sha>:<path>                    # un file come era in quel commit
git --no-pager blame -w -C -L 10,40 -- <file>       # chi ha scritto quelle righe, ignorando spazi e spostamenti
```

`-S` risponde a «da quale commit esiste questa stringa», che è quasi sempre la domanda giusta sull'origine di un comportamento. `blame` dice chi ha toccato la riga per ultimo, non chi ha introdotto la logica: `-w -C` evita di attribuirla all'ultimo riformattatore.

Confronto fra due rami:

```bash
git merge-base <branchA> <branchB>                       # punto di divergenza
git --no-pager diff --name-status <branchA>...<branchB>  # tre punti: differenze dal merge-base
git --no-pager log --oneline <branchA>..<branchB>        # commit presenti solo in branchB
```

I tre punti sulla diff rispondono a «cosa è cambiato in questo ramo», i due punti sul log elencano i commit mancanti. Confonderli produce report sbagliati.

## 5. Diagnosi di una regressione

1. Individua un commit «buono» certo e uno «cattivo» certo (`git --no-pager log --oneline`).
2. Cerca prima con il pickaxe: `git --no-pager log -S'<simbolo sospetto>' --oneline <buono>..<cattivo>`. Nella maggioranza dei casi finisce qui, senza toccare il working tree.
3. Solo se il pickaxe non basta e il difetto è verificabile con un comando, usa `bisect`, dichiarando che sposta HEAD:

```bash
git bisect start <cattivo> <buono>
git bisect run <comando che esce 0 se ok, non-0 se rotto>
git bisect reset                                    # obbligatorio: riporta HEAD dove era
```

`git bisect reset` va eseguito sempre, anche se il bisect fallisce: dimenticarlo lascia il repository in detached HEAD.

## 6. Recupero di lavoro perso

```bash
git --no-pager reflog --date=iso -n 40              # dove è stato HEAD, anche dopo reset o rebase
git --no-pager reflog show <branch> --date=iso      # storia dei movimenti di un branch
git stash list && git --no-pager stash show -p 'stash@{0}'
git fsck --lost-found                               # commit e blob non raggiungibili
git --no-pager show <sha>                           # ispeziona un commit orfano trovato sopra
```

Nulla è perso finché il reflog lo ricorda: prima di proporre un recupero, trova lo sha nel reflog e mostralo all'utente. Il recupero effettivo (`reset`, `cherry-pick`, `branch <nome> <sha>`) è una scrittura: va autorizzata a parte.

## 7. Controlli prima di un push o di una consegna

```bash
git --no-pager log --oneline '@{u}..HEAD'                          # cosa esce
git --no-pager diff --stat '@{u}..HEAD'                            # quanto pesa
git --no-pager diff --check '@{u}..HEAD'                           # spazi finali, marcatori di conflitto
git --no-pager diff --name-only '@{u}..HEAD' | grep -E '\.(jar|war|class|log|zip|p12|jks|pem|key)$'
git --no-pager diff -U0 '@{u}..HEAD' | grep -inE 'password|passwd|secret|api[_-]?key|token=|BEGIN [A-Z ]*PRIVATE KEY'
git --no-pager log --oneline --invert-grep --grep='^tkn:' -i '@{u}..HEAD'   # commit in uscita senza token
```

**Lo scope è `@{u}..HEAD`, non `--cached`.** Al momento del push l'indice è pulito, quindi un filtro su `git diff --cached` è vuoto per costruzione: non trova nemmeno una password in chiaro dentro un commit in uscita, e non dà errore, dà silenzio. Se stai verificando *prima* del commit, la sezione giusta è la 2, dove `--cached` è corretto.

Le due grep sono un filtro grossolano, non una garanzia: un riscontro va **sempre** riportato all'utente, un non-riscontro non autorizza a dichiarare il push pulito. L'ultima riga elenca i commit in uscita privi della riga `tkn:` (convenzioni in `git-commit-messages` e `git-branch-token`); i merge commit banali sono ammessi senza token.

## 8. Trappole

- **CRLF su Windows**: un diff che segnala «tutto cambiato» spesso è solo fine-riga. Verifica con `git --no-pager diff -w --stat` e controlla `core.autocrlf` e `.gitattributes`. Non «normalizzare» un file intero dentro un commit funzionale.
- **Rename non seguiti**: `git log -- <file>` si ferma al rename, serve `--follow`.
- **Merge commit nei conteggi**: `--no-merges` cambia i numeri. Dichiara sempre quale delle due letture stai riportando.
- **`HEAD~1` vs `HEAD^2`**: sui merge commit il primo genitore è il branch di destinazione, il secondo quello integrato. Sbagliarli inverte il senso del diff.
- **Submodule**: appaiono come una voce singola con lo sha. Il diff del contenuto sta nel loro repository, non qui.
- **Percorsi con spazi o accenti su Windows**: quotali sempre, altrimenti git li interpreta come pathspec multipli.

# Vincoli
- Non usare comandi che modificano storia, remoto o indice in una richiesta di sola verifica.
- Non eseguire comandi interattivi o senza `--no-pager` quando l'output può essere lungo.
- Non dedurre l'attribuzione di un file a un'attività dal solo nome: quando conta, leggi il diff.
- Non dichiarare pulito un controllo su segreti o file indesiderati: riporta cosa hai cercato e cosa hai trovato.
- Non lasciare il repository in detached HEAD dopo un bisect.
- Non proporre un recupero di lavoro perso senza aver prima mostrato lo sha trovato nel reflog.
