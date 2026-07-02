---
name: jr-statictext-clips
description: "In questo progetto (JasperReports 6.21.5) staticText taglia il testo che eccede l'altezza; usare sempre textField con textAdjust StretchHeight"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 1c03506b-cd01-4ab5-bbb1-f3ffd1105056
---

Nei jrxml di questo progetto (JasperReports 6.21.5) l'elemento `<staticText>` **non** supporta gli attributi `textAdjust` né `isStretchWithOverflow` (lo schema XSD li rifiuta in compilazione) e **taglia** il testo che supera l'altezza fissa del `reportElement`: intestazioni multi-riga spariscono, paragrafi lunghi vengono troncati.

**Regola:** per qualunque testo che possa andare a capo o crescere, usare `<textField textAdjust="StretchHeight">` con espressione costante (`<textFieldExpression><![CDATA["..."]]>`), non `staticText`. Solo i `textField` si allungano e impaginano su più pagine. Lo stesso pattern è usato nei report marketing esistenti (testo lungo sempre via textField, mai staticText).

Per testo multi-riga in espressione costante: concatenare `"riga\n" + "riga2..."` e usare le virgolette tipografiche “ ” al posto di `"` per evitare l'escaping. Per il grassetto inline serve uno stile con `markup="html"` e i tag `<b>`.

Attenzione: anche il `box` padding riduce l'area-testo. Un `staticText` a altezza fissa (es. 14px) con uno stile che ha `bottomPadding` (es. 6) ha area utile 14-6=8px < altezza riga → taglia tutto e non mostra nulla. Per etichette brevi a altezza fissa (es. il "-" dei bullet) usare uno stile SENZA padding.

Elenchi puntati col trattino sotto il margine (hanging indent): NON usare `firstLineIndent` negativo (l'export PDF lo tronca a 0). Usare 2 colonne affiancate: `staticText "-"` a `x=0` (stile senza padding) + `textField` testo a `x=14` con `textAdjust="StretchHeight"`. Una voce per banda.
