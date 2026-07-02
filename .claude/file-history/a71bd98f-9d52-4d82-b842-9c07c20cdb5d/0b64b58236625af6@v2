---
name: disciplinare-esecuzione-routing-per-tipoform
description: "la sottoscrizione del disciplinare esecuzione ha tipoForm dedicato ESECUZIONE_INTEGRAZIONE_DISCIPLINARE, assegnato via opzione integrazioneEsecuzione"
metadata:
  node_type: memory
  type: project
  originSessionId: 57035319-c5ad-43a0-9a62-a0e0f7ca335b
---

Nella feature "procedura negoziale / disciplinare in fase di esecuzione", il form di sottoscrizione del disciplinare ha un **tipoForm dedicato**: `ESECUZIONE_INTEGRAZIONE_DISCIPLINARE` (nuovo valore in `TipoFormEnum`, accanto a `ESECUZIONE_INTEGRAZIONE`). Serve a distinguerlo dagli altri form di integrazione esecuzione, che restano `ESECUZIONE_INTEGRAZIONE`.

**Assegnazione automatica al salvataggio** (`SalvaCreaActionCommand`, ramo del custom field `customFormEsecuzione`, ~righe 1612+): se l'opzione `integrazioneEsecuzione: true` è nel JSON del form → `ESECUZIONE_INTEGRAZIONE_DISCIPLINARE`; se `false`/assente → `ESECUZIONE_INTEGRAZIONE`. Lettura via `hasFieldOptionEnabled(fields, json, optionName)` con wrapper `checkFormIntegrazione` (`integrazione`) e `checkFormIntegrazioneEsecuzione` (`integrazioneEsecuzione`). Gate invariato: deve comunque avere `customFormEsecuzione` + `integrazione: true`. Il bando va ri-salvato — vedi [[tipoform-calcolato-al-salvataggio-bando]].

**Filtri estesi a ENTRAMBI i tipi** (mostrare/gestire sia ESECUZIONE_INTEGRAZIONE sia ..._DISCIPLINARE): `ScrivaniaCittadinoMiddlewareService.getSottoscrizioniDisciplinareEsecuzionePendenti`, `PresentatoreFormFrontendService` (liste/conteggi istanze integrative), `CompilaDocumentoEsecuzioneRenderCommand`, `CompletaEsecuzioniActionCommand` (lista + condizione + updateIstanzaDaIntegrare), scheduler `ProtocollazioneDocumentazioneAggiuntivaBandiScheduler` (lista + case switch → BANDI_ISTANZA_INTEGRAZIONE_ES), back office `DettaglioNuovoRenderCommand`. Lato operatore `ScrivaniaOperatoreBandiFrontendService` filtra il disciplinare per `ESECUZIONE_INTEGRAZIONE_DISCIPLINARE`.

**Why:** prima la sottoscrizione era indistinguibile (`ESECUZIONE_INTEGRAZIONE` come gli altri form esecuzione): i filtri prendevano tutta la famiglia. Il tipo dedicato la isola.

**How to apply:** la fase NON è il discriminatore (l'istanza non ha colonna fase): conta il tipoForm. Quando aggiungi filtri/branch su `ESECUZIONE_INTEGRAZIONE`, valuta se vanno estesi anche a `ESECUZIONE_INTEGRAZIONE_DISCIPLINARE` (sono replicati in ~6 punti tra cittadino/presentatore/operatore/scheduler/back office). Non aggiungere file di Claude nel repo — vedi [[no-claude-files-nel-repo]].
