---
name: pdf-integrazioni-definizione-form-da-snapshot
description: Da dove arriva la definizione del form nel PDF integrazioni e come testarlo velocemente
metadata: 
  node_type: memory
  type: project
  originSessionId: aa5f4bf1-cbc1-4648-9571-f781233ff6b9
---

Per il PDF di un'integrazione, la struttura alpaca (schema/options/data/view) NON viene riletta dalla definizione "madre" del form. In `AlpacaUtil.loadFormData(form, savedJson, ...)` (presentatore-forms-bandi-common): se `savedJson` (= `IstanzaDomandaBando.getJson()`) NON è vuoto, TUTTO viene preso dallo snapshot salvato sull'istanza (`// This should overwrite the past configuration`); `form.getJson()` viene usato solo se lo snapshot è vuoto.

Chiamanti: `DownloadIstanzaIntegrativaPDFResourceCommand` e `InviaFormIntegrativoActionCommand` (presentatore-forms-bandi-frontend).

**Per testare modifiche al form di un'istanza esistente senza rifare il giro**: editare la colonna `json` della riga in tabella `istanza_domanda_bando` (PK `istanzaDomandaBandoId`, datasource `gestioneBandiDataSource`), poi SVUOTARE la cache Liferay (entità `cache-enabled="true"`, altrimenti si legge il vecchio) e rigenerare il download. Lo snapshot è un `FormData`: top-level `alpaca` {schema,options,data,view} + `placeholders`.

Collegato a [[pdf-integrazioni-prima-pagina-bianca]].
