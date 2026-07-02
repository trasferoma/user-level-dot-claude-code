---
name: groovy
description: Applica convenzioni e accorgimenti specifici quando generi o correggi script Groovy eseguiti nella Script console di Liferay (script di amministrazione, migrazione o popolamento dati che usano i *LocalServiceUtil, i model Service Builder, il counter e l'accesso JDBC). Copre import espliciti obbligatori dei tipi usati (la console tratta i nomi non importati come proprietà → MissingPropertyException), divieto di mascherare le eccezioni con messaggi fissi, diagnosi dell'eccezione reale prima di formulare teorie, stringhe multilinea con tripli apici, idempotenza, valorizzazione di scoping/audit alla creazione di entità, consapevolezza del datasource e della finder cache Liferay. Da comporre con clean-code. NON usare per codice Java di produzione né per linguaggi diversi da Groovy.
---

# Scopo
Applicare convenzioni e accorgimenti specifici per scrivere o correggere script Groovy eseguiti nella Script console di Liferay (e in generale script Groovy che interagiscono con servizi OSGi, Service Builder e JDBC del portale).

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di scrivere uno script Groovy per la Script console di Liferay
- l'utente chiede uno script di amministrazione, migrazione o popolamento dati che usa `*LocalServiceUtil`, model Service Builder, `CounterLocalServiceUtil` o accesso JDBC
- l'utente chiede di correggere o diagnosticare uno script Groovy che fallisce nella console
- la risposta finale contiene codice Groovy destinato al runtime del portale

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede codice Java di produzione (modulo, portlet, service): in quel caso valgono `liferay`, `java-conventions`, `java-version-11`
- l'utente chiede uno script in un linguaggio diverso da Groovy
- l'utente chiede solo una spiegazione teorica senza codice
- il task non ha nulla a che fare con il runtime Liferay o con script eseguibili

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `clean-code` per naming, basso annidamento e leggibilità
- Questa skill NON applica i vincoli delle skill `java-version-*`: Groovy non è Java, quindi `def`, closure, GString e `new Date()` sono ammessi
- In caso di conflitto con `liferay`, questa skill prevale per gli aspetti specifici dello scripting da console; `liferay` resta valida per le scelte architetturali del codice di modulo

# Obiettivi
Lo script Groovy generato deve essere:
- eseguibile nella console senza errori di risoluzione classi
- diagnostico quando fallisce, mai silenzioso o fuorviante
- idempotente quando popola o migra dati
- coerente con il modello dati e la cache di Liferay
- leggibile, con variabili locali parlanti e basso annidamento

# Regole operative

## 1. Import espliciti di tutti i tipi usati

### Regola
- Importare esplicitamente ogni classe richiamata per nome: `*LocalServiceUtil`, model Service Builder, `CounterLocalServiceUtil`, classi di accesso JDBC, util del portale
- Non lasciare commenti segnaposto al posto degli import reali
- Non assumere che la console risolva da sola i package dei moduli

### Perché
Nella Script console di Liferay un nome di classe non importato non viene risolto come classe ma trattato come **proprietà dinamica** dello script. Il risultato è `groovy.lang.MissingPropertyException: No such property`, non un errore di import esplicito. Senza import non ti aggganci al service OSGi reale: lo script fallisce e, se l'eccezione è mascherata, sembra un problema di dati o di cache che non esiste.

### Esempio corretto
```groovy
import com.liferay.portal.kernel.dao.orm.QueryUtil
import com.liferay.counter.kernel.service.CounterLocalServiceUtil
import it.servizidigitali.gestionebandi.service.DatoBandoLocalServiceUtil
import it.servizidigitali.gestionebandi.service.BandoLocalServiceUtil
import it.servizidigitali.gestionebandi.service.ValoreDatoBandoLocalServiceUtil
import it.servizidigitali.gestionebandi.model.ValoreDatoBando

def datoBando = DatoBandoLocalServiceUtil.findByCodice("ABILITA_FIRMA_DATA_ISTANZA")
```

### Anti-esempio
```groovy
import com.liferay.portal.kernel.dao.orm.QueryUtil
// import del package reale del modulo bando (model + service)

// BandoLocalServiceUtil non e importato:
// la console lo tratta come proprieta -> MissingPropertyException: No such property
def bandi = BandoLocalServiceUtil.getBandos(QueryUtil.ALL_POS, QueryUtil.ALL_POS)
```

## 2. Non mascherare le eccezioni con messaggi fissi

### Regola
- In fase di diagnosi catturare `Throwable` e stampare tipo, messaggio e catena delle cause
- Non scrivere `catch` che stampano un messaggio fisso e interpretativo ("dato non trovato", "errore generico")
- Dopo aver loggato un errore che impedisce di proseguire, interrompere il flusso (`return`), per non eseguire le righe successive su riferimenti `null`

### Perché
Un `catch (Exception)` con messaggio fisso trasforma qualsiasi causa (proprietà mancante, NPE, errore SQL, servizio non risolto) in una sola diagnosi sbagliata. Porta a inseguire problemi inesistenti (cache, dati mancanti) mentre la causa reale è un'altra. Il messaggio dell'eccezione è informazione diagnostica: nasconderlo è un autosabotaggio.

### Esempio corretto
```groovy
def datoBando
try {
    datoBando = DatoBandoLocalServiceUtil.findByCodice(CODICE_DATO)
}
catch (Throwable t) {
    out.println "ERRORE risoluzione DatoBando '${CODICE_DATO}': " +
            t.getClass().getName() + " -> " + t.getMessage()
    def cause = t.getCause()
    while (cause != null) {
        out.println "CAUSA: " + cause.getClass().getName() + " -> " + cause.getMessage()
        cause = cause.getCause()
    }
    return
}
```

### Anti-esempio
```groovy
def datoBando
try {
    datoBando = DatoBandoLocalServiceUtil.findByCodice(CODICE_DATO)
}
catch (Exception e) {
    // Messaggio fisso: nasconde la causa reale e prosegue comunque
    out.println "ERRORE: DatoBando non trovato. Creare prima la definizione."
}
long id = datoBando.getDatoBandoId() // NPE se sopra ha fallito
```

## 3. Diagnosticare l'eccezione reale prima di formulare teorie

### Regola
- Prima di ipotizzare cause sistemiche (cache, datasource, dati mancanti), stampare il tipo reale dell'eccezione
- Isolare il problema con la prova più semplice possibile (una sola chiamata, un solo `out.println`)
- Non costruire spiegazioni non verificate: una causa plausibile non è una causa dimostrata

### Perché
È facile costruire una narrazione convincente ma falsa. Se l'eccezione vera non è stata letta, ogni teoria è una congettura. La prima azione utile è quasi sempre togliere il `catch` che maschera e guardare `t.getClass().getName()`.

### Esempio corretto
```groovy
// Prova minimale: isola la singola chiamata e mostra l'eccezione reale
try {
    def d = DatoBandoLocalServiceUtil.findByCodice("CODICI_ATECO")
    out.println "OK -> datoBandoId=" + d.getDatoBandoId()
}
catch (Throwable t) {
    out.println "TIPO: " + t.getClass().getName() + " | MSG: " + t.getMessage()
}
```

### Anti-esempio
```groovy
// "Sara la cache": si pulisce la cache, si rilancia, non cambia nulla,
// perche la causa era un import mancante mai verificato.
```

## 4. Stringhe e sintassi multilinea

### Regola
- Una stringa con doppi (o singoli) apici deve stare su una sola riga
- Per testo o messaggi multilinea usare i tripli apici (`"""..."""`)
- Distinguere un errore di parsing (`startup failed`) da un errore a runtime: il primo è sintassi, non logica

### Perché
In Groovy una stringa `"..."` non può contenere un a-capo: spezzarla genera un errore di parsing (`expecting anything but '\n'`) e lo script non parte affatto. È un errore di compilazione, non un problema dei dati.

### Esempio corretto
```groovy
out.println "Bandi: ${bandi.size()} | creati: ${creati} | gia presenti: ${giaPresenti}"
// oppure, se serve multilinea:
out.println """Riepilogo:
creati=${creati}
giaPresenti=${giaPresenti}"""
```

### Anti-esempio
```groovy
out.println "Bandi: ${bandi.size()} | creati: ${creati} | gia presenti:
${giaPresenti}"   // a-capo dentro stringa a doppio apice -> startup failed
```

## 5. Letture via finder e cache di Liferay

### Regola
- Non inserire entità Liferay via SQL grezzo se poi le leggi tramite i finder Service Builder
- Creare le entità dal service (`add...`), così entity cache e finder cache restano coerenti
- Se un INSERT diretto a DB è inevitabile, invalidare la cache (Control Panel → Server Administration → **Clear Database Cache**) o riavviare il bundle `*-service` prima di rileggere
- Ricordare che i finder unici cachano anche il risultato negativo (assenza), che un insert fuori banda non invalida

### Perché
I finder Service Builder usano la finder cache e memorizzano anche i "non trovato". Un insert SQL diretto popola il DB ma non avvisa Liferay: la cache continua a restituire il risultato stale. È un rischio reale da tenere presente, ma va confermato leggendo l'eccezione reale (regola 3), non assunto come prima spiegazione.

### Esempio corretto
```groovy
// Definizione creata dal service: la cache resta coerente
def dato = DatoBandoLocalServiceUtil.fetchByCodice(CODICE) // fetch: null se assente, niente eccezione
if (dato == null) {
    long id = CounterLocalServiceUtil.increment(DatoBando.class.getName())
    dato = DatoBandoLocalServiceUtil.createDatoBando(id)
    dato.setCodice(CODICE)
    dato = DatoBandoLocalServiceUtil.addDatoBando(dato)
}
```

### Anti-esempio
```groovy
// INSERT a mano nel DB del modulo, poi findByCodice dallo script:
// la finder cache puo restare stale e la lettura fallisce in modo opaco.
```

## 6. Idempotenza degli script di popolamento e migrazione

### Regola
- Uno script che crea righe deve poter essere rilanciato senza duplicare
- Verificare l'esistenza prima di creare e contare creati/già presenti
- Stampare un riepilogo finale chiaro

### Perché
Gli script di amministrazione vengono rieseguiti (errori, ambienti multipli, riprese). Senza idempotenza si creano duplicati difficili da ripulire.

### Esempio corretto
```groovy
def esistenti = ValoreDatoBandoLocalServiceUtil
        .findByBandoIdAndDatoBandoId(bandoId, datoBandoId)
if (esistenti != null && !esistenti.isEmpty()) {
    giaPresenti++
    return // salta questo bando
}
// ... creazione solo se assente
```

## 7. Creazione di entità: id, scoping e audit

### Regola
- Generare l'id con `CounterLocalServiceUtil.increment(Entita.class.getName())`
- Valorizzare i campi di scoping/audit dell'entità (`companyId`, `groupId`, `userId`, `userName`, `createDate`, `modifiedDate`) quando esistono, derivandoli da un'entità correlata coerente
- Non lasciare `companyId`/`groupId` a `0` se l'entità è scoped: comprometterebbe le query scoped successive
- Chiudere sempre le risorse JDBC aperte manualmente

### Perché
Le entità Service Builder hanno campi audit e scoping. Una riga con scoping a zero o date nulle è incoerente con il resto e può rompere letture filtrate. I valori vanno presi da un riferimento sensato (es. il bando padre), non inventati.

### Esempio corretto
```groovy
long valoreId = CounterLocalServiceUtil.increment(ValoreDatoBando.class.getName())
def valore = ValoreDatoBandoLocalServiceUtil.createValoreDatoBando(valoreId)
valore.setBandoId(bandoId)
valore.setDatoBandoId(datoBandoId)
valore.setValore(VALORE)
valore.setCompanyId(bando.getCompanyId())
valore.setGroupId(bando.getGroupId())
valore.setUserId(bando.getUserId())
valore.setUserName(bando.getUserName())
valore.setCreateDate(new Date())
valore.setModifiedDate(new Date())
ValoreDatoBandoLocalServiceUtil.addValoreDatoBando(valore)
```

## 8. Consapevolezza del datasource

### Regola
- Sapere che la connessione di default del portale non è necessariamente quella del modulo: alcuni moduli usano un datasource dedicato
- Preferire sempre i `*LocalServiceUtil` del modulo, che già puntano al datasource corretto
- Usare JDBC diretto solo per diagnosi mirata, e in tal caso ottenere la connessione dal datasource giusto, non da quello di default

### Perché
Una query JDBC sulla connessione di default può colpire lo schema sbagliato e fallire ("table doesn't exist") pur essendo i dati presenti nel DB del modulo. Passare dal service evita del tutto il problema.

### Esempio corretto
```groovy
// Via service: usa il datasource del modulo, nessun rischio di schema sbagliato
def dato = DatoBandoLocalServiceUtil.findByCodice(CODICE)
```

### Anti-esempio
```groovy
import com.liferay.portal.kernel.dao.jdbc.DataAccess
// Connessione di default (schema del portale): puo non contenere le tabelle del modulo
def con = DataAccess.getConnection()
def rs = con.prepareStatement("SELECT * FROM dato_bando").executeQuery()
```

# Preferenze di output
Quando generi script Groovy per la console Liferay:
- metti in cima tutti gli import espliciti dei tipi usati
- rendi lo script idempotente e con riepilogo finale
- in diagnosi, stampa tipo/messaggio/causa dell'eccezione, mai messaggi fissi
- usa variabili locali parlanti e basso annidamento (early return nelle closure con `return`)
- chiudi le risorse JDBC aperte manualmente

# Vincoli
- Non lasciare riferimenti a classi non importate
- Non mascherare le eccezioni con messaggi interpretativi fissi
- Non proseguire il flusso dopo un errore che lascia riferimenti `null`
- Non inserire entità Liferay via SQL grezzo se poi le leggi via finder, salvo invalidazione cache esplicita
- Non assumere lo schema del datasource di default per entità di moduli con datasource dedicato
- Non spezzare stringhe a singolo/doppio apice su più righe

# Esempi di attivazione
- "Scrivimi uno script Groovy per popolare un valore su tutti i bandi"
- "Questo script nella Script console di Liferay dà errore, sistemalo"
- "Perché `findByCodice` fallisce nello script Groovy?"
- "Fammi uno script di migrazione dati per la console Liferay"

# Esempi di non attivazione
- "Scrivimi un MVCActionCommand per Liferay" (codice di modulo → skill `liferay`)
- "Genera un DTO Java 11"
- "Spiegami cos'è Groovy"
- "Scrivimi uno script Python"

# Nota finale
Questa skill copre lo scripting Groovy nel runtime Liferay: risoluzione delle classi, diagnosi onesta degli errori e interazione corretta con Service Builder, cache e datasource. Non sostituisce le skill di codice di produzione (`liferay`, `java-conventions`, `java-version-11`), ma le affianca per il contesto specifico degli script eseguibili da console.
