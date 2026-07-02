---
name: tipoform-calcolato-al-salvataggio-bando
description: "bando_form.tipoForm si ricalcola solo al salvataggio del bando, non modificando il JSON del form"
metadata: 
  node_type: memory
  type: project
  originSessionId: 57035319-c5ad-43a0-9a62-a0e0f7ca335b
---

Il campo `bando_form.tipoForm` viene calcolato dalla detection in `SalvaCreaActionCommand` (modulo gestione-bandi-frontend) **solo al salvataggio del bando**, leggendo i custom field nel JSON del form (`JsonPathUtil.getFormFields` + `checkFormIntegrazione` sul flag `integrazione:true`).

Conseguenza pratica: modificare il JSON di un form già associato (es. aggiungere il campo `customFormEsecuzione` con `integrazione:true` per ottenere `ESECUZIONE_INTEGRAZIONE`) **non aggiorna** il `tipoForm` finché non si **ri-salva il bando** (o si rimuove e ri-aggiunge il form nella configurazione bando).

**Why:** durante la feature disciplinare esecuzione, un form di sottoscrizione aveva il marker corretto nel JSON (`customFormEsecuzione`/`integrazione:true`, identico a un `ESECUZIONE_INTEGRAZIONE` funzionante) ma restava `INTEGRAZIONE` in `bando_form`, facendo fallire l'instradamento nei tab e nei modali. Causa: il tipoForm era stato fissato a un salvataggio precedente, prima del marker.

**How to apply:** quando il routing per tipoForm non torna, verificare `SELECT formId, tipoForm FROM bando_form WHERE bandoId=...`; se il JSON del form ha il marker ma il tipoForm è sbagliato, ri-salvare il bando. Per sbloccare un test al volo: `UPDATE bando_form SET tipoForm='...' WHERE bandoId=... AND formId=...` + clear cache Liferay. Collegato a [[disciplinare-esecuzione-routing-per-tipoform]].
