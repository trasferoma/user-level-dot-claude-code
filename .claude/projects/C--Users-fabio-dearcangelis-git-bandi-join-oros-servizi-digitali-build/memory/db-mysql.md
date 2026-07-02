---
name: db-mysql
description: Il database del progetto è MySQL; implicazioni per le query di verifica sul JSON dei form
metadata: 
  node_type: memory
  type: project
  originSessionId: 5e3fb43b-b2a1-4e91-933e-77b5b3a15fbd
---

Il DBMS del progetto è **MySQL**.

**Why:** serve per scrivere query corrette (es. ricerche nel JSON dei form) evitando varianti Oracle come `DBMS_LOB.INSTR`.

**How to apply:** la colonna `json` (tabelle `form` = definizione madre, `istanza_domanda_bando` = snapshot compilato) si interroga con `LIKE`. Per cercare un flag JSON come `"numerico":true` normalizza gli spazi: `WHERE REPLACE(json,' ','') LIKE '%"numerico":true%'`. La tabella `bando_form` NON ha colonna `json`: è solo l'associazione bando↔form↔`tipoForm`. Vedi [[requisiti-validazione-campo-numerico]].
