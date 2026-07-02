---
name: pdf-integrazioni-prima-pagina-bianca
description: Causa della prima pagina bianca nei PDF integrazioni (gestione-bandi) generati via wkhtmltopdf
metadata: 
  node_type: memory
  type: project
  originSessionId: aa5f4bf1-cbc1-4648-9571-f781233ff6b9
---

PDF integrazioni con prima pagina bianca (solo header, contenuto da pagina 2). Diagnosi confermata sperimentalmente (giugno 2026) modificando lo snapshot dell'istanza:

**Causa (CONFERMATA leggendo il CSS)**: in `generazione-automatica-pdf.css` (tema `portale-istituzionale-theme`, servito dal portale, NON in questo repo) ci sono due regole:
- `body.generazione-automatica-pdf { page-break-inside: avoid; }`
- `td, h1, h2, h3, p, b, div, i, span, label, ul, li, tr, table { page-break-inside: avoid; }`
Il `div` (e `body`/`table`) in queste regole impedisce a wkhtmltopdf di spezzare i contenitori. Quando il contenuto del form supera l'altezza di UNA pagina, il div contenitore non può spezzarsi e viene spinto INTERO a pagina 2 → pagina 1 col solo header. Sotto una pagina → OK; sopra → bianca.

**Escluso** (tutto verificato): Java, il template `integrazioniAlpacaTemplate()`, il box `esecuzione`/`allegatiConfigurabili` (anche se legati a uno step resta il problema), i campi fuori binding, l'attributo `order`, il numero di step.

**Fix vero (nel CSS del tema)**: togliere `div`, `table`, `ul`, `td` dal selettore e togliere `page-break-inside: avoid` dal `body`; lasciarlo solo sugli elementi foglia (`h1,h2,h3,p,b,i,span,label,li,tr`). Così i singoli campi non si spezzano ma i contenitori lunghi sì. NON risolvibile in modo affidabile lato JSON (si può solo tenere il contenuto sotto una pagina). URL CSS: https://web44.linksmt.it/o/portale-istituzionale-theme/css/project/generazione-automatica-pdf.css

Catena di generazione: `generaPDFIntegrazioni` (AlpacaPDFService) NON rilegge alcun JSON; riceve `alpacaStructure` dal chiamante. Vedi [[pdf-integrazioni-definizione-form-da-snapshot]].
