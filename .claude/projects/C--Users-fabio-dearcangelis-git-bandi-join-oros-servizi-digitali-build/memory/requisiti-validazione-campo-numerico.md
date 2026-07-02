---
name: requisiti-validazione-campo-numerico
description: "La validazione numerica dei requisiti domanda dipende dal flag \"numerico\":true nelle options del sottocampo, che vive nella definizione del form (DB), non nel repo"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5e3fb43b-b2a1-4e91-933e-77b5b3a15fbd
---

Un "Requisito domanda" con operatore numerico (`LE`/`GE`/`G`/`L`) viene valutato come numero SOLO se il sottocampo target ha `"numerico": true` nelle sue `options` nel JSON del form. `ValidaDomandaBandoServiceImpl.isCampoTestuale` legge `$['alpaca']['options']['fields'][<campo>]['fields'][<sottocampo>].numerico`: se il flag manca, il campo è trattato come **testuale** → si entra in `validateString`, che SCARTA in silenzio gli operatori numerici (gestisce solo `EQ`/`NE`/`NN`/`CONTAINS`) → nessun errore di validazione, né in compilazione né allo step Verifica.

Caso reale: campo `importoRichiesto` (sottocampo `importo`, `type: currency`) senza `numerico:true` → la regola "importo <= 100000" non scattava. Fix corretta: aggiungere `"numerico": true` sul sottocampo `importo` nelle `options` del form.

**Why:** il flag `numerico` NON è impostato da nessuna parte nel repo (né in `ImportoRichiesto.js` né altrove); vive solo nelle definizioni form salvate a DB (tabella `form`, colonna `json`). Un form definito senza quel flag fa fallire silenziosamente la validazione numerica. L'utente preferisce correggere la definizione del form, non `isCampoTestuale`.

**How to apply:** se una validazione numerica non scatta, verifica nel JSON del form (definizione madre in `form`, snapshot in `istanza_domanda_bando`) che il sottocampo abbia `"numerico": true`. Ricorda lo snapshot: le istanze già salvate non si aggiornano finché il form non viene ri-renderizzato/ri-salvato. Vedi [[db-mysql]] e [[tipoform-calcolato-al-salvataggio-bando]].
