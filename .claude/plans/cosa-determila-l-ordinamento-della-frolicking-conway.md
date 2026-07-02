# Pulizia residuo mock: rimozione di `mockPartitaIva()`

## Context
Sono stati rimossi i mock temporanei che simulavano l'accreditamento ente e l'azione di compilazione disciplinare esecuzione (5 file, 7 blocchi). La verifica ha confermato che la rimozione è pulita: nessun riferimento pendente, nessun import orfano, compilazione integra.

Resta un solo residuo: il metodo privato `mockPartitaIva()` in `AccreditamentoEnteClientImpl`, il cui unico chiamante (il blocco mock di `getPartiteIvaUtente`) è già stato rimosso. È quindi codice morto da eliminare per chiudere la pulizia.

La scelta dell'ordinamento `COMPILA_DISCIPLINARE_ESECUZIONE(3)` in `AzioniOperatoreCodes` è confermata dall'utente e resta invariata.

## Modifica

**File:** `modules/servizi-digitali-common/servizi-digitali-accreditamento-ente-integration/src/main/java/it/servizidigitali/accreditamento/ente/integration/client/impl/AccreditamentoEnteClientImpl.java`

- Rimuovere il metodo `private String mockPartitaIva()` (righe 221-229).
- Nessun import da toccare: gli import del file (`ArrayList`, DTO vari) restano usati da metodi reali. `mockPartitaIva` non usava import dedicati (solo `StringBuilder`/`Math`, del JDK).

## Verifica
- Confermare che dopo la rimozione il file non contenga più la stringa `mock` (grep case-insensitive sul file).
- Build del modulo `servizi-digitali-accreditamento-ente-integration` per confermare che compili.
