# SPEC — <titolo della modifica>

**Obiettivo:** <cosa deve cambiare e perché, in una frase; nessun dettaglio implementativo>

**Contesto**
- Punti del codice interessati: `<endpoint / classe / modulo / funzione>`
- Pattern o meccanismi esistenti da riusare: `<es. sistema di query, service, factory già presenti>`
- File / moduli coinvolti: `<se noti — restringe la ricerca dell'agent ed evita reimplementazioni>`

**Comportamento atteso**
- <cosa deve fare il sistema dopo la modifica>
- <gestione dei casi limite / input non validi>
- <invariante: cosa deve restare identico a prima>

**Vincoli**
- Retrocompatibile: non alterare contratti o comportamenti esistenti oltre a quanto richiesto.
- Riusare i pattern/meccanismi già presenti; nessuna logica fuori dal suo livello (es. niente logica di business nel controller).
- Nessuna modifica non necessaria a modello dati, schema, altri endpoint, autorizzazioni.
- Nessuna nuova tabella, dipendenza o astrazione se non indispensabile e concordata.
- <eventuali vincoli specifici del task>

**Fuori scope**
- <cosa esplicitamente NON rientra in questa modifica>

**Definition of done** — criteri verificabili (uno per comportamento atteso + invarianti); ognuno coperto da almeno un test
1. <criterio verificabile>
2. <criterio verificabile>
3. comportamento preesistente invariato dove richiesto;
4. nessuna modifica non richiesta a modello o contratti.

**Esempio** (istanza concreta — solo illustrativo)
```java
// Modifica: GET /api/users  →  nuovo parametro opzionale "status" (enum UserStatus)
//   ?status=ACTIVE → solo utenti ACTIVE
//   (assente)      → comportamento invariato
//   ?status=XXX    → errore di validazione (HTTP 400)
//
// NB: verificare come lo stato è persistito (name / ordinal / codice)
//     prima di scegliere il termine di confronto.

UserStatus status = ...; // opzionale, letto dalla query string; null se assente
if (status != null) {
    dynamicQuery.add(PropertyFactoryUtil.forName("status").eq(status.name()));
}
```
