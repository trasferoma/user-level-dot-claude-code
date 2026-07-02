#!/usr/bin/env bash
# Hook SessionStart (globale, fuori dal repo).
# Solo nel progetto servizi-digitali-build inietta il contesto del file introProgetto
# e chiede a Claude di confermare con "introProgetto acquisito".

DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
INTRO="/c/Users/fabio.dearcangelis/Desktop/desktop/lavoro/attivita/Emi/paservdig/introProgettoPerClaude.md"

case "$DIR" in
  *bandi-join-oros-servizi-digitali-build*)
    if [ -f "$INTRO" ]; then
      echo "Contesto di progetto 'introProgetto' caricato automaticamente."
      echo "A inizio della prossima risposta conferma all'utente con il messaggio esatto: introProgetto acquisito"
      echo
      cat "$INTRO"
    fi
    ;;
esac

exit 0