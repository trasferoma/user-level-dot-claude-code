---
name: formattuale-spegne-form-integrazione
description: "formAttuale vuoto nel JSON del form di integrazione esecuzione → il form riappare nella modale \"Richiedi Integrazioni\" dopo che il cittadino lo integra"
metadata: 
  node_type: memory
  type: project
  originSessionId: 95d6a40a-b729-496b-8c45-91a4c2b278d3
---

Nei form di integrazione esecuzione (custom field `customFormEsecuzione`, blocco `configurazione`), l'opzione `formAttuale` deve contenere il **codice del form stesso**; `formDaMostrare` è il codice dell'eventuale form successivo (opzionale).

Sintomo se `formAttuale` è `""`: l'operatore chiede l'integrazione (il form sparisce dalla modale "Richiedi Modifiche/Integrazioni al Richiedente"), il cittadino la compila, e il form **riappare** come integrabile pur non dovendo.

**Why:** alla compilazione del cittadino `CompletaEsecuzioniActionCommand.getFormInformation` aggiunge l'entry solo se `Validator.isNotNull(formAttuale)` (false per `""`); l'entry serve ad aggiungere il codice del form a `FORM_ESECUZIONE_NON_ABILITATO` (ramo `else` ~`:288-296`). Lato operatore `ScrivaniaOperatoreBandiFrontendService.getIntegrazioni` (~`:2501-2519`) esclude dalla modale i codici presenti in `FORM_ESECUZIONE_NON_ABILITATO`. Senza `formAttuale` il form non viene mai escluso → riappare.

**How to apply:** valorizzare `formAttuale` col codice del form (pattern `<codice>-integrazione`, come nei form funzionanti). Le opzioni si leggono dalla definizione del form (`form.getJson()`), NON dallo snapshot istanza: la modifica al JSON ha effetto subito sulle compilazioni successive, senza ri-salvare il bando (a differenza di [[tipoform-calcolato-al-salvataggio-bando]]). Istanze già completate male non si auto-correggono: aggiungere a mano la riga `FORM_ESECUZIONE_NON_ABILITATO`. Collegato a [[disciplinare-esecuzione-routing-per-tipoform]].
