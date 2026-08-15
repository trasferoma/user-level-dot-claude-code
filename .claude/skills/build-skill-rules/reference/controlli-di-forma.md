# Reference: controlli di forma su una skill

Verifiche meccaniche da eseguire su `SKILL.md` prima di dichiarare finita una skill nuova o modificata. Coprono solo la **forma**: non dicono nulla su ciò che è stato perso per strada, che è compito del controllo di copertura.

I comandi sono **shell POSIX**: eseguili con il tool **Bash** (Git Bash), non con PowerShell, dove `awk`, `grep -o` e `$(...)` si comportano diversamente. Un controllo eseguito nella shell sbagliata torna vuoto senza errore leggibile, e un risultato vuoto si legge come «controllo passato»: è il modo più facile di dichiarare conforme una skill che non lo è.

Lancia i comandi dalla directory della skill.

## Blocco unico

```bash
f=SKILL.md
echo "== righe (limite 500) ==";                    wc -l < "$f"
echo "== delimitatori frontmatter (attesi 2) ==";   grep -c '^---$' "$f"
echo "== campi del frontmatter ==";                 awk 'NR>1 && /^---$/{exit} /^[a-z-]+:/{printf "%s  %d caratteri di riga\n", $1, length($0)}' "$f"
echo "== link a file ==";                           grep -oE '\[[^]]+\]\([^)]+\)' "$f"
echo "== path in stile Windows (atteso nulla) ==";  grep -nE '[A-Za-z0-9_-]+\\[A-Za-z0-9_-]+' "$f"
echo "== file di supporto sul disco ==";            find . -type f ! -name SKILL.md
```

## Come leggere l'esito

| Controllo | Passa se |
|---|---|
| righe | ≤ 500. Oltre, **sposta** contenuto in un file di reference, non comprimere |
| delimitatori | esattamente 2, alla riga 1 e a chiusura del frontmatter |
| `name` | ≤ 64 caratteri, solo minuscole, cifre e trattini, nessuna parola riservata, **identico al nome della directory** |
| `description` | ≤ 1.024 caratteri, terza persona, dice cosa fa **e** quando usarla, caso principale in testa |
| altri campi | esistono nello schema: vedi `reference/frontmatter.md`. Un campo inventato non dà errore, viene ignorato in silenzio |
| link | ogni file citato esiste; nessun link dentro i file di reference verso altri file (profondità massima 1). Il comando pesca anche i link dentro i blocchi di esempio, che non sono file reali: leggi l'elenco, non correggerlo a scatola chiusa |
| path Windows | nessun risultato |
| file di supporto | ognuno è citato da `SKILL.md` |

`length($0)` conta anche il prefisso del campo: sottrai 6 caratteri per `name: ` e 13 per `description: `. I limiti valgono sul valore, non sulla riga.

## File di supporto mai citati

```bash
for r in $(find . -type f ! -name SKILL.md | sed 's|^\./||'); do
  if grep -q "$(basename "$r")" SKILL.md; then echo "ok          $r"; else echo "MAI CITATO  $r"; fi
done
```

Un file mai citato da `SKILL.md` è un file mai letto. Citalo dicendo cosa contiene e quando aprirlo, oppure eliminalo.

## Annidamento dei riferimenti

```bash
grep -oE '\[[^]]+\]\([^)]+\)' reference/*.md 2>/dev/null || echo "(nessun link nei reference: profondita' 1 rispettata)"
```

Un link dentro un file di reference crea una catena `SKILL.md` → file → file: il modello ne fa un'anteprima parziale e ottiene informazioni incomplete. Porta il riferimento in `SKILL.md`.
