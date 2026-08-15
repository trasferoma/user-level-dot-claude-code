# Esempi operativi: regole anti-densità

## Indice
- Linee guida operative
- 1. Ridurre gli annidamenti
- 2. Abbassare la densità del codice
  - 2.1 Anche una chiamata sola è densa
- 3. Evitare condizioni `if` complesse
- 4. Combinare early return e variabili esplicative

---

Questi esempi guidano la generazione e modifica del codice quando il task richiede codice.
L'obiettivo non è codice più "furbo", ma codice più leggibile, meno denso e più facile da verificare.

## Linee guida operative
- Tenere il numero degli annidamenti il più basso possibile. Quando il flusso diventa complesso, usare early return, early continue oppure estrarre metodi privati con nomi chiari.
- Tenere bassa la densità del codice. Evitare di passare direttamente chiamate a metodo complesse come parametri di altri metodi. Recuperare prima i valori in variabili esplicative e poi passarli.
- Evitare condizioni `if` complesse. Calcolare prima i blocchi logici significativi usando variabili boolean con nomi di business, poi usare quei flag nel controllo di flusso.

---

## 1. Ridurre gli annidamenti

Preferire un flusso lineare con uscite anticipate rispetto a blocchi `if` annidati.
Se per capire il metodo bisogna seguire una scala di `if` dentro altri `if`, il metodo sta già chiedendo pietà.

### Anti-esempio

```java
public void processRequest(Request request) {
    if (request != null) {
        if (request.isEnabled()) {
            if (!request.isExpired()) {
                if (request.hasValidOwner()) {
                    validate(request);
                    execute(request);
                    notifyOwner(request);
                }
            }
        }
    }
}
```

### Esempio corretto

```java
public void processRequest(Request request) {
    if (!isProcessable(request)) {
        return;
    }

    validate(request);
    execute(request);
    notifyOwner(request);
}

private boolean isProcessable(Request request) {
    return request != null
            && request.isEnabled()
            && !request.isExpired()
            && request.hasValidOwner();
}
```

### Criterio pratico
Quando un metodo supera un livello di annidamento, valutare:
- invertire la condizione e uscire prima;
- estrarre un predicato privato;
- estrarre una fase del processo in un metodo dedicato;
- estrarre una nuova classe se emerge una responsabilità autonoma.

---

## 2. Abbassare la densità del codice

Non comprimere troppe operazioni in una singola riga o chiamata.
Le chiamate annidate nei parametri rendono il codice più difficile da leggere, debuggare e modificare.

### Anti-esempio

```java
protocolService.register(
        protocolRequestBuilder.build(
                practiceService.getPractice(request.getPracticeId()),
                userService.getUser(themeDisplay.getUserId()),
                documentService.getDocument(request.getDocumentId()),
                configurationProvider.getGroupConfiguration(groupId)));
```

### Esempio corretto

```java
Practice practice = practiceService.getPractice(request.getPracticeId());
User user = userService.getUser(themeDisplay.getUserId());
Document document = documentService.getDocument(request.getDocumentId());
GroupConfiguration configuration = configurationProvider.getGroupConfiguration(groupId);

ProtocolRequest protocolRequest = protocolRequestBuilder.build(
        practice,
        user,
        document,
        configuration);

protocolService.register(protocolRequest);
```

### Criterio pratico
Una chiamata può ricevere direttamente un metodo come parametro solo se il valore è immediato e ovvio.
Se il metodo chiamato recupera dati, costruisce oggetti, interroga servizi o applica logica, assegnare prima il risultato a una variabile esplicativa.

Un'eccezione tollerabile per casi banali:
```java
logger.info("Processing request {}", request.getId());
```

---

## 2.1 Anche una chiamata sola è densa

La densità non si conta in livelli di annidamento. Qui la chiamata è una e non è annidata dentro un'altra, e il metodo è già troppo denso: il valore che finisce nella lista non ha un nome, e l'istruzione va a capo in mezzo agli argomenti.

### Anti-esempio

```java
private List<CharacteristicContribution> computeContributions(
        Sector sector, DriverCarUnit unit, double structuralPenaltySeconds, double totalRawWeight) {
    List<CharacteristicContribution> contributions = new ArrayList<>();
    for (Characteristic characteristic : sector.orderedCharacteristics()) {
        CharacteristicDemand demand = sector.demandFor(characteristic);
        contributions.add(computeContribution(characteristic, demand, unit, structuralPenaltySeconds,
                totalRawWeight));
    }
    return contributions;
}
```

### Esempio corretto

```java
private List<CharacteristicContribution> computeContributions(
        Sector sector, DriverCarUnit unit, double structuralPenaltySeconds, double totalRawWeight) {

    List<CharacteristicContribution> contributions = new ArrayList<>();

    for (Characteristic characteristic : sector.orderedCharacteristics()) {
        CharacteristicDemand demand = sector.demandFor(characteristic);
        CharacteristicContribution characteristicContribution = computeContribution(characteristic, demand, unit, structuralPenaltySeconds, totalRawWeight);
        contributions.add(characteristicContribution);
    }
    return contributions;
}
```

Cosa cambia:
- Il valore prodotto dal calcolo ha un nome, ed è il concetto stesso: `characteristicContribution`. Non serve che sia originale.
- `add` riceve una variabile e non un'espressione: si vede a colpo d'occhio cosa entra nella lista.
- Il ritorno a capo in mezzo agli argomenti della chiamata annidata sparisce: la riga si spezzava nel punto peggiore, quello che separa un parametro dagli altri.
- Il corpo del ciclo si legge come due passi allo stesso livello — calcola il contributo, aggiungilo — invece di uno.

### Criterio pratico
Non chiederti quanti livelli di annidamento ha l'istruzione. Chiediti se ogni valore che il metodo produce ha un nome. Se un valore nasce e muore dentro gli argomenti di un'altra chiamata, non ce l'ha.

---

## 3. Evitare condizioni `if` complesse

Quando una condizione contiene più blocchi logici, calcolare prima ogni blocco con una variabile boolean dal nome chiaro.
Il nome della variabile deve spiegare il significato di business della condizione, non ripetere meccanicamente i campi usati.

### Anti-esempio

```java
if (request != null
        && request.getStatus() == RequestStatus.SUBMITTED
        && request.getOwnerId() == user.getUserId()
        && !request.isArchived()
        && permissionChecker.hasPermission(groupId, resourceName, request.getId(), ActionKeys.UPDATE)) {
    approve(request);
}
```

### Esempio corretto

```java
boolean isSubmittedRequest = request != null
        && request.getStatus() == RequestStatus.SUBMITTED;

boolean isOwnedByCurrentUser = request != null
        && request.getOwnerId() == user.getUserId();

boolean isEditableRequest = request != null
        && !request.isArchived();

boolean canUpdateRequest = permissionChecker.hasPermission(
        groupId,
        resourceName,
        request.getId(),
        ActionKeys.UPDATE);

if (isSubmittedRequest && isOwnedByCurrentUser && isEditableRequest && canUpdateRequest) {
    approve(request);
}
```

### Variante migliore quando la logica cresce

```java
public void approve(Request request, User user) {
    if (!canApprove(request, user)) {
        return;
    }

    approve(request);
}

private boolean canApprove(Request request, User user) {
    boolean isSubmittedRequest = request != null
            && request.getStatus() == RequestStatus.SUBMITTED;

    boolean isOwnedByCurrentUser = request != null
            && request.getOwnerId() == user.getUserId();

    boolean isEditableRequest = request != null
            && !request.isArchived();

    boolean canUpdateRequest = hasUpdatePermission(request);

    return isSubmittedRequest
            && isOwnedByCurrentUser
            && isEditableRequest
            && canUpdateRequest;
}
```

### Nota: niente boolean inutili per condizioni banali

```java
// NO - aggiunge burocrazia senza chiarire
boolean isActive = user.isActive();
if (isActive) {
    sendNotification(user);
}

// SI - già chiaro
if (user.isActive()) {
    sendNotification(user);
}
```

---

## 4. Combinare early return e variabili esplicative

### Anti-esempio

```java
public void download(Document document, User user) {
    if (document != null && user != null && document.isAvailable() && !document.isDeleted()) {
        if (user.isActive() && user.hasAcceptedTerms()) {
            if (permissionService.canDownload(user, document)) {
                streamDocument(document);
            }
        }
    }
}
```

### Esempio corretto

```java
public void download(Document document, User user) {
    if (!canDownload(document, user)) {
        return;
    }

    streamDocument(document);
}

private boolean canDownload(Document document, User user) {
    boolean isAvailableDocument = document != null
            && document.isAvailable()
            && !document.isDeleted();

    boolean isValidUser = user != null
            && user.isActive()
            && user.hasAcceptedTerms();

    if (!isAvailableDocument || !isValidUser) {
        return false;
    }

    return permissionService.canDownload(user, document);
}
```

Vantaggi:
- Il metodo pubblico resta leggibile.
- La logica di accesso ha un nome preciso: `canDownload`.
- Le condizioni sono divise in blocchi concettuali.
- L'annidamento viene eliminato.
- La chiamata costosa o esterna a `permissionService` avviene solo dopo i controlli locali.

---

## 5. Regola sintetica

Quando generi o modifichi codice:

1. Prima riduci l'annidamento.
2. Poi riduci la densità delle chiamate.
3. Poi assegna nomi chiari ai blocchi logici.
4. Poi valuta se estrarre metodi o classi.
5. Non rendere il codice più lungo se non diventa anche più leggibile.

Il codice corretto non deve sembrare compresso per risparmiare righe.
Deve sembrare facile da leggere, facile da testare e difficile da fraintendere.
