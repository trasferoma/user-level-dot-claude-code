# Fix script Groovy: aggiunta variabile COMPILA_DISCIPLINARE_ESECUZIONE

## Context

Lo script `scriptGr.txt` (Liferay Script Console) deve impostare la variabile Camunda
`COMPILA_DISCIPLINARE_ESECUZIONE = "true"` a scope locale sull'execution del task di
fase Esecuzione (`Activity_0ou33qi`) dell'istanza con `idDomandaBando = 323201`, per far
comparire "Compila disciplinare" nel dettaglio pratica.

Lo script termina con *"Nessun task 'Activity_0ou33qi' attivo sull'istanza 323201"*: la
GET su `/task` torna un array vuoto, quindi non arriva mai alla scrittura della variabile.

## Diagnosi confermata via curl (16/06/2026)

`GET /task?processInstanceBusinessKey=323201` torna il task atteso:
- task id `cea75802-68c7-11f1-8945-080027f1171c`, name "Esecuzione"
- taskDefinitionKey `Activity_0ou33qi` (coordinata corretta)
- executionId `cea6e2bc-68c7-11f1-8945-080027f1171c`
- processInstanceId reale (UUID) `22309b27-68c6-11f1-8945-080027f1171c`
- businessKey `323201`

La GET con `processInstanceId=323201` torna `[]` perché 323201 è il businessKey, non l'UUID.

## Root cause

Riga 27 dello script:

```groovy
def getUrl = "${CAMUNDA_REST}/task?processInstanceId=${PROC_INST_ID}&taskDefinitionKey=${ACTIVITY_KEY}"
```

`PROC_INST_ID = 323201` è l'`idDomandaBando`, che nel sistema è il **businessKey**, NON il
`processInstanceId` interno di Camunda (un UUID).

Conferme dal codebase:
- `AvvioIstanzaProcessoBandiScheduler.java:175` → `businessKey = domanda.getDomandaBandoId()`;
  poi `startProcessInstance(..., String.valueOf(businessKey), ...)`.
- L'UUID reale viene salvato a parte: `updateProcessInstanceIdDomandaBando(...)` →
  colonna `domanda_bando.processInstanceId`.
- Il recupero per business key nel codice usa `processInstanceBusinessKey`
  (`CamundaClientImpl.getTasksByBusinessKey`, ~riga 230).

Il parametro `processInstanceId` dell'endpoint `/task` matcha solo l'UUID interno. Filtrando
con il businessKey `323201` l'array torna vuoto. `Activity_0ou33qi` è un human task valido
(usato come `taskDefinitionKey` per la fase Esecuzione), quindi quella coordinata è corretta.

## Modifica allo script (per riuso futuro)

File: `C:\Users\fabio.dearcangelis\Desktop\desktop\lavoro\attivita\Emi\paservdig\Procedura negoziale\scriptGr.txt`

Riga 27 — unica modifica necessaria al funzionamento:
```
da: /task?processInstanceId=${PROC_INST_ID}&taskDefinitionKey=${ACTIVITY_KEY}
a:  /task?processInstanceBusinessKey=${PROC_INST_ID}&taskDefinitionKey=${ACTIVITY_KEY}
```

Migliorie di chiarezza (opzionali, non incidono sul funzionamento):
- Rinominare `PROC_INST_ID` → `BUSINESS_KEY` (è un businessKey), aggiornando i riferimenti.
- Aggiornare i messaggi `out.println` che citano "istanza ${PROC_INST_ID}".

La parte di scrittura (PUT `localVariables`) resta invariata: usa l'`executionId` ricavato
dal task, quindi è già corretta.

## Sblocco immediato istanza 323201 (senza script)

Avendo già l'`executionId`, scrivere la variabile direttamente:
```
PUT /engine-rest/execution/cea6e2bc-68c7-11f1-8945-080027f1171c/localVariables/COMPILA_DISCIPLINARE_ESECUZIONE
body: {"value":"true","type":"String"}
atteso: HTTP 204
```

## Verifica end-to-end

1. Dopo la PUT: refresh del dettaglio pratica → compare "Compila disciplinare" in fase Esecuzione.
2. (Opz.) `GET /execution/cea6e2bc-.../localVariables/COMPILA_DISCIPLINARE_ESECUZIONE` → `"true"`.
3. Script corretto: con `DRY_RUN = true` deve stampare 1 task; con `DRY_RUN = false` → `HTTP 204`.
