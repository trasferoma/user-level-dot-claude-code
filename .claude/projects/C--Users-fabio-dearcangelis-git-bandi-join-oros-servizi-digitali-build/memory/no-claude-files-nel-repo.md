---
name: no-claude-files-nel-repo
description: "Non aggiungere file di Claude (CLAUDE.md, .claude/, settings/hook) dentro il repo del progetto"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a71bd98f-9d52-4d82-b842-9c07c20cdb5d
---

Non aggiungere **nessun file di Claude dentro il repo del progetto**: né `CLAUDE.md`, né cartella `.claude/`, né `settings.json`/hook a livello di progetto.

**Why:** il repo non deve essere "inquinato" da file legati a Claude; finirebbero nei commit/PR del progetto condiviso.

**How to apply:** per contesto di progetto usa file esterni al repo (es. il file di [[intro-progetto]] sul Desktop) e la memoria in `~/.claude`. Se serve un comportamento automatico (hook), usa solo il `settings.json` **globale** in `~/.claude`, mai quello di progetto.
