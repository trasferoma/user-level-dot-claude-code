---
name: feedback-nuova-classe-non-sovrascrivere
description: "Quando l'utente chiede \"genera una classe di test\" (o equivalente) creare un nuovo file, NON sovrascrivere classi esistenti con nome simile o adiacente."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3b3cf753-1abb-4805-9d83-15731afdbf95
---

Quando l'utente chiede di "generare una classe" (es. "genera una classe di test", "crea una classe", "genera un nuovo test") il default è SEMPRE creare un nuovo file, mai sovrascrivere o riscrivere classi esistenti per quanto simili sembrino allo scopo richiesto.

**Why:** in questo progetto è successo che il modello sovrascrivesse `EsitoDomandaJasperReportTest` per produrre un singolo PDF `vecchio_esito.pdf` dal template vecchio, distruggendo i 4 test pre-esistenti (campiAlMax, conOggettoValorizzato, conOggettoVuoto, conOggettoEAllegati) che lavoravano sul template nuovo. L'utente ha dovuto chiedere esplicitamente di ripristinare la classe e crearne una nuova separata.

**How to apply:**
- "genera/crea/scrivi una classe X" → nuovo file con nome distinto, anche se esiste già una classe simile nello stesso package.
- Se c'è ambiguità su quale strada prendere (nuovo file vs modifica), chiedere prima di scrivere.
- Se la classe esistente ha un path/risorsa sbagliato e l'utente NON ha chiesto di correggerlo, lasciarlo stare: la correzione va proposta a parte, non infilata dentro a un task di "creazione nuova classe".
- Prima di chiamare Write su un file, verificare se quel path esiste già (Glob o Read). Se sì, fermarsi e scegliere un nome diverso.
