---
name: book-to-skill-windows-caveats
description: "Caveats per usare la skill `book-to-skill` (installata in ~/.claude/skills/book-to-skill/) su questa macchina Windows + Claude Code."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 3fbac654-2593-4e5e-8451-78844cf60ed7
---

La skill `book-to-skill` è installata in `C:\Users\fabio.dearcangelis\.claude\skills\book-to-skill\` (SKILL.md + scripts/extract.py). Quando l'utente la invoca tieni presente:

- **Shell**: la SKILL.md descrive snippet in bash (`test -f`, `grep`, `sed`, here-doc `<<'PY'`). Questa macchina è Windows 11 con PowerShell 5.1 — non eseguire i bash literal, traduci ogni snippet nell'equivalente PowerShell (`Test-Path`, `Select-String`, `Get-Content -TotalCount/-Tail`, here-string `@'...'@`). In alternativa, se l'utente ha Git Bash o WSL, chiedere conferma prima di delegare lì.

- **Path di output di default**: la skill scrive le skill generate sotto `~/.config/agents/skills/` (default Amp). Per Claude Code l'utente vuole `~/.claude/skills/<skill_name>/` — passa esplicitamente `SKILLS_HOME` o forza la destinazione a Step 5 del workflow, altrimenti le skill generate finiscono fuori dal registry Claude Code attivo.

- **Python**: lo script `scripts/extract.py` richiede `python3` (o `python`) sul `PATH`. Package opzionali sono auto-installabili via `--install-missing yes|no|ask`: `docling` (PDF technical), `pdftotext`/`PyPDF2`/`pdfminer.six` (PDF text), `ebooklib`+`beautifulsoup4` (EPUB), `python-docx` (DOCX), `striprtf` (RTF). Per MOBI/AZW serve Calibre `ebook-convert` come app esterna, non pip.

- **Work directory**: di default usa la temp dir di sistema sotto `book_skill_work/`. Override con env var `BOOK_SKILL_WORKDIR` se serve una cartella deterministica (utile per debug).
