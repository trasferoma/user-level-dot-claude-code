---
name: alpaca-forms
description: Applica convenzioni e accorgimenti operativi quando generi o correggi form Alpaca.js (Alpaca Forms, il form engine JSON-Schema-driven di Gitana/Cloud CMS basato su jQuery, Handlebars e Bootstrap 3). Usa sia per creare form nuove sia per manutenere form esistenti - configurazione data/schema/options/view, confine tra schema e options, scelta e override delle view, field type custom con Alpaca.registerFieldClass, validator sincroni e asincroni, eventi e API runtime (getControlByPath, childrenByPropertyId, refresh, isValid, refreshValidationState), array e table field, i18n dei messaggi, caricamento remoto via schemaSource/optionsSource/dataSource e Connector custom verso backend Java, Spring Boot o Liferay. Copre ordine di caricamento degli script, versioni delle dipendenze e trappole note. NON riguarda Alpaca Markets (API di trading) ne il modello LLM Stanford Alpaca. Da comporre con clean-code.
---

# Scopo
Scrivere e manutenere form Alpaca.js corrette, leggibili e diagnosticabili: configurazione dichiarativa (`data`/`schema`/`options`/`view`), field type custom, validazione, eventi, i18n e integrazione con un backend che serve schema e dati come JSON.

Baseline di riferimento: **Alpaca 1.5.27** (`gitana/alpaca`). Dipendenze dichiarate in `bower.json`: jQuery `>= 2.1.0` (il README documenta compatibilità da `1.9.1`), Handlebars `4.7.6`, **Bootstrap `3.3.2`**, Moment `2.9.0`.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di creare una form Alpaca (`$(el).alpaca({...})`) o un blocco `schema`/`options`/`view`
- l'utente chiede di modificare, estendere o riparare una form Alpaca esistente
- il task riguarda field type custom, validator, eventi, view custom o template Handlebars di Alpaca
- il task riguarda l'integrazione tra una form Alpaca e un backend che serve schema/options/data come JSON
- la risposta finale contiene JavaScript, JSON di schema/options o JSP/HTML che inizializza Alpaca

# Quando NON usare questa skill
Non usare questa skill se:
- il task riguarda **Alpaca Markets** (API di trading) o il modello **Stanford Alpaca**: sono prodotti diversi
- il task riguarda un altro form engine (JSON Forms, Formly, React Hook Form, form Liferay native)
- il task è solo backend Java senza alcun contratto verso una form Alpaca: valgono `liferay`, `springboot`, `java-conventions`
- l'utente chiede solo una spiegazione teorica senza produrre o correggere codice

# Regole di precedenza
- Le istruzioni esplicite dell'utente e i vincoli di sicurezza prevalgono su questa skill
- Questa skill si compone con `clean-code` per naming, basso annidamento e bassa densità: le config Alpaca sono il posto dove la densità esplode più facilmente
- Il codice JavaScript prodotto segue lo stile già presente nel progetto (indentazione, quoting, module pattern): la coerenza con l'esistente prevale sulle preferenze di questa skill
- Per il codice Java che **serve** schema/options valgono `liferay` o `springboot` più `java-version-*`: questa skill governa solo il lato Alpaca e il contratto JSON
- In caso di dubbio su una API, prevale [reference/api-verificata.md](reference/api-verificata.md) sulla memoria: quel file elenca ciò che è stato verificato sul sorgente e ciò che **non esiste**

# Obiettivi
La form Alpaca prodotta deve essere:
- corretta rispetto alle API realmente esistenti nella 1.5.x
- leggibile: schema e options costruiti a pezzi con nomi parlanti, non un unico literal annidato
- diagnosticabile: errori visibili, nessun fallimento silenzioso
- localizzata: nessuna stringa utente hardcoded nel JavaScript
- sicura: la validazione client è ergonomia, mai un controllo di sicurezza

# Regole operative

## 1. Non inventare API: usa solo quelle verificate

### Regola
- Prima di usare un metodo, un'opzione o un hook di ciclo di vita, controlla che compaia in [reference/api-verificata.md](reference/api-verificata.md)
- Se non c'è, non assumerlo: verificalo sul sorgente (`src/js/Field.js`, `src/js/ControlField.js`, `src/js/ContainerField.js`, `src/js/fields/**`) e dichiara all'utente che stai andando oltre il verificato
- Errori ricorrenti da evitare, **confermati inesistenti** nel sorgente:
  - `afterRenderControl` non è un hook di Field né di TextField
  - `showMessages` è una **option** di campo, non un metodo da chiamare
  - `childrenByPropertyId` esiste su `ContainerField` (object/array), **non** su un control field: si raggiunge via `this.getParent().childrenByPropertyId`
  - `Alpaca.defaultView` e `Alpaca.defaultUI` non sono dichiarati in `src/js/Alpaca.js`: passa `"view"` esplicitamente invece di affidarti a un default globale

### Perché
Alpaca ha una superficie API ampia, molto materiale online datato e una documentazione che non copre tutto. Inventare un nome plausibile produce codice che non fallisce con un errore chiaro: fallisce con un campo che non renderizza o una callback mai chiamata, ed è la classe di bug più costosa da diagnosticare.

## 2. Confine netto tra schema, options, view e data

### Regola
- `schema` = **contratto dati**: `type`, `properties`, `items`, `required`, `enum`, `default`, `format`, `minLength`/`maxLength`, `pattern`, `minimum`/`maximum`, `minItems`/`maxItems`, `dependencies`, `readonly`
- `options` = **presentazione**: `type` (field type), `label`, `helper`, `placeholder`, `fields`, `items`, `hidden`, `disabled`, `validate`, `validator`, `form`
- `view` = **template e stile**: quale set di template usare, override per path, `messages`, `locale`
- `data` = **valori**, nient'altro
- Non mettere vincoli di dati in `options`, non mettere label in `schema` (a parte `title`/`description`, che restano leciti)

### Perché
Il confine è ciò che rende schema e dati riusabili lato server e la presentazione sostituibile lato client. Se i vincoli finiscono in `options`, il backend non può più validare contro lo stesso schema e la validazione si sdoppia.

### Esempio corretto
```javascript
var schema = {
    "type": "object",
    "properties": {
        "codiceFiscale": { "type": "string", "minLength": 16, "maxLength": 16 }
    },
    "required": ["codiceFiscale"]
};

var options = {
    "fields": {
        "codiceFiscale": { "type": "text", "label": labels.codiceFiscale, "size": 16 }
    }
};
```

### Anti-esempio
```javascript
// Vincolo di dati messo in options: il backend non lo vede, la validazione si sdoppia
var options = { "fields": { "codiceFiscale": { "type": "text", "maxLength": 16 } } };
```

## 3. Abbassa la densità della configurazione

### Regola
- Non costruire un unico literal annidato con `data`, `schema`, `options`, `view`, `postRender` e le callback dei bottoni tutto dentro la chiamata a `.alpaca()`
- Assegna `schema`, `options` e `view` a variabili con nomi parlanti, poi passale
- Estrai i nomi dei campi in costanti quando compaiono più di una volta (config, `postRender`, validator, eventi)
- Estrai le callback non banali (`validator`, `submit.click`, handler di eventi) in funzioni nominate

### Perché
È la regola `clean-code` applicata al punto in cui Alpaca la mette più a rischio: una config annidata di 200 righe non è leggibile, non è diffabile e non è testabile. Una variabile locale che dà un nome a un blocco vale più delle righe risparmiate.

### Esempio corretto
```javascript
var FIELD_TIPO_RICHIEDENTE = "tipoRichiedente";

function buildSchema() { /* ... */ }
function buildOptions(labels) { /* ... */ }
function onTipoRichiedenteChange() { /* ... */ }

var schema = buildSchema();
var options = buildOptions(labels);

$("#domanda-form").alpaca({
    "data": data,
    "schema": schema,
    "options": options,
    "view": "bootstrap-edit",
    "postRender": bindDomandaHandlers
});
```

### Anti-esempio
```javascript
$("#domanda-form").alpaca({ "schema": { "type": "object", "properties": { "tipoRichiedente": { "type": "string",
    "enum": ["PF", "PG"] }, "dati": { "type": "object", "properties": { /* altre 80 righe */ } } } },
    "options": { "fields": { "tipoRichiedente": { "type": "select", "label": "Tipo richiedente",
    "events": { "change": function() { /* logica inline */ } } } } } });
```

## 4. Ordine di caricamento e dipendenze

### Regola
- Ordine obbligatorio degli script: **jQuery → Handlebars → framework UI (Bootstrap / jQuery UI / jQuery Mobile) → Alpaca per ultimo**
- Scegli **una** distribuzione (`dist/alpaca/{web|bootstrap|jqueryui|jquerymobile}/`) e usa JS e CSS della stessa
- CKEditor, TinyMCE, Summernote, DataTables e simili devono essere caricati **prima** che Alpaca renderizzi il campo che li usa
- La distribuzione `bootstrap` è costruita su **Bootstrap 3**: non dare per scontato che il markup e le classi di Bootstrap 4/5 funzionino, verifica prima di assumerlo
- Non aggiornare jQuery o Handlebars oltre le versioni pinnate senza test: è una rottura nota (vedi regola 10)

### Esempio corretto
```html
<script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.5/handlebars.min.js"></script>
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/alpaca@1.5.27/dist/alpaca/bootstrap/alpaca.min.css" rel="stylesheet"/>
<script src="https://cdn.jsdelivr.net/npm/alpaca@1.5.27/dist/alpaca/bootstrap/alpaca.min.js"></script>
```

## 5. Accesso ai campi: API di Alpaca, non il DOM

### Regola
- Ottieni il control dopo il render da `postRender(control)` oppure con `$(el).alpaca("get")`
- Naviga con `control.getControlByPath("indirizzo/citta")` o con `container.childrenByPropertyId["citta"]`
- Leggi e scrivi con `getValue()` / `setValue(value)`, mai manipolando l'`input` con jQuery
- Non selezionare i campi con selettori CSS sul markup generato: il markup dipende dalla view e cambia cambiando view o versione

### Perché
Bypassare Alpaca scrivendo direttamente nel DOM disallinea il valore interno del field dal valore visualizzato: `getValue()` continua a restituire il vecchio dato e la serializzazione perde le modifiche.

### Esempio corretto
```javascript
function bindDomandaHandlers(control) {
    var tipoRichiedente = control.getControlByPath(FIELD_TIPO_RICHIEDENTE);
    tipoRichiedente.on("change", function() {
        // this === il field
        aggiornaSezioneRichiedente(control, this.getValue());
    });
}
```

### Anti-esempio
```javascript
$("#domanda-form input[name='tipoRichiedente']").val("PG"); // il field non lo sa
```

## 6. Validazione: callback su ogni ramo, messaggi localizzati

### Regola
- Un `validator` ha firma `function(callback)` e **deve invocare `callback` su ogni ramo di uscita**, anche in caso di errore o di `return` anticipato
- Esito: `callback({ "status": true })` oppure `callback({ "status": false, "message": ... })`
- Per la validazione incrociata usa `this.getParent().childrenByPropertyId["altroCampo"].getValue()`
- Prima del submit usa `control.isValid(true)` (l'argomento è `checkChildren`) e, se serve ricalcolare lo stato, `control.refreshValidationState(true)`
- Reagisci allo stato con gli eventi `validated` / `invalidated`, non con polling
- I messaggi di errore vanno da `view.messages` o dai bundle i18n, non hardcoded nel validator

### Perché
Un validator che non chiama `callback` non lascia la form "senza errore": la lascia **appesa**, perché la catena di validazione non si chiude e il submit non si sblocca mai. È il bug più comune sui validator asincroni.

### Esempio corretto
```javascript
function validaImportoRichiesto(callback) {
    var importo = this.getValue();
    var massimale = this.getParent().childrenByPropertyId["massimale"].getValue();

    if (importo > massimale) {
        callback({ "status": false, "message": messages.importoOltreMassimale });
        return;
    }
    callback({ "status": true });
}
```

### Anti-esempio
```javascript
"validator": function(callback) {
    var importo = this.getValue();
    if (importo > massimale) {
        callback({ "status": false, "message": "Importo troppo alto" }); // stringa hardcoded
    }
    // ramo valido senza callback: la validazione non si chiude mai
}
```

## 7. La validazione client non è sicurezza

### Regola
- Ogni vincolo che protegge dati o autorizzazioni va **rivalidato lato server**: `schema` e `validator` sono ergonomia utente
- Non usare `hidden`, `disabled` o `readonly` per nascondere dati che l'utente non deve vedere: sono nel payload e nel DOM
- Non filtrare in JavaScript le opzioni di una select per scoping di sicurezza: il backend deve servire solo le opzioni ammesse
- Per il token CSRF/sessione usa un campo `"type": "hidden"`, ma il controllo resta lato server

## 8. Field type custom e ciclo di vita

### Regola
- Estendi un field esistente e registralo: `Alpaca.Fields.X = Alpaca.Fields.TextField.extend({...})` + `Alpaca.registerFieldClass("x", Alpaca.Fields.X)`
- `getFieldType()` deve restituire l'identificativo registrato
- Chiama sempre `this.base(...)` quando fai override di un metodo che ha un'implementazione a monte (`setup`, `setValue`, `getValue`, `destroy`, `handleValidate`)
- `setupField(callback)` è il punto per l'inizializzazione asincrona e **deve** invocare `callback()` quando ha finito
- Fai override solo di hook che esistono davvero: `setup`, `setupField`, `getValue`, `setValue`, `handleValidate`, `destroy`, `onChange`, `onFocus`, `onBlur`, `onKeyPress`, `onKeyUp`, `getFieldType`
- Per legare il field a un `format` di schema usa `Alpaca.registerDefaultFormatFieldMapping("formato", "x")`

### Esempio corretto
```javascript
Alpaca.Fields.CodiceFiscaleField = Alpaca.Fields.TextField.extend({

    getFieldType: function() {
        return "codicefiscale";
    },

    setValue: function(value) {
        this.base(value ? value.toUpperCase() : value);
    },

    handleValidate: function() {
        var baseStatus = this.base();
        // ... controllo aggiuntivo
        return baseStatus;
    }
});

Alpaca.registerFieldClass("codicefiscale", Alpaca.Fields.CodiceFiscaleField);
```

## 9. Integrazione con il backend

### Regola
- Il backend è la fonte di verità dello schema: servi `schema`, `options` e `data` come JSON e caricali con `schemaSource`, `optionsSource`, `dataSource`
- Ricorda che il contenuto remoto viene **fuso** con quello inline: non definire la stessa chiave in entrambi i posti aspettandoti un override pulito
- Per header di autenticazione, CSRF o `p_auth` di Liferay, estendi `Alpaca.Connector` e fai override di `buildAjaxConfig`, poi registra con `Alpaca.registerConnectorClass`
- Al submit serializza con `this.getValue()` e invia JSON, oppure usa `this.ajaxSubmit()` che restituisce una promise jQuery: gestisci sempre anche il ramo `fail`
- Non generare a mano il JSON dello schema in una JSP: costruiscilo lato Java e passalo serializzato, così resta una sola definizione

### Esempio corretto
```javascript
var DomandaConnector = Alpaca.Connector.extend({
    buildAjaxConfig: function(uri, isJson) {
        var ajaxConfig = this.base(uri, isJson);
        ajaxConfig.headers = { "X-CSRF-Token": csrfToken };
        return ajaxConfig;
    }
});
Alpaca.registerConnectorClass("domanda", DomandaConnector);
```

## 10. Manutenzione: re-render, refresh e trappole note

### Regola
- Per ricostruire una form su un elemento già inizializzato: `$(el).alpaca("destroy")` e poi re-init. È il pattern affidabile
- `refresh(callback)` è **asincrono**: metti nella callback tutto ciò che dipende dal nuovo stato, non sulla riga successiva
- Verifica con `$(el).alpaca("exists")` prima di assumere che un control ci sia
- Trappole confermate da tenere presenti:
  - aggiornare jQuery/Handlebars oltre le versioni pinnate può rompere la determinazione automatica della view (`A view was not specified and could not be automatically determined`): passa `"view"` esplicitamente
  - il caricamento remoto di schema/options/data può essere **cachato**: una seconda `.alpaca()` sullo stesso elemento può non rifare la richiesta
  - le dipendenze condizionali dentro gli item di un array non rivalutano in modo affidabile sui valori preimpostati: testa esplicitamente la combinazione array + `dependencies` + dati precaricati
  - il campo `upload` ha problemi noti nel recupero del valore: verifica il payload effettivo prima di dipendere da `getValue()`
- Per form grandi e annidate usa `lazyLoading: true` sugli object field: è la mitigazione documentata per le performance di rendering

### Perché
Alpaca 1.5.x è in manutenzione lenta (backlog di issue ampio, ultimo tag 1.5.27). Non aspettarti che un bug noto venga risolto a monte: la strategia corretta è aggirarlo in modo esplicito e commentato, non riscrivere il framework.

## 11. i18n: nessuna stringa utente nel JavaScript

### Regola
- Label, helper, `optionLabels` e messaggi di errore arrivano da un dizionario passato alla funzione che costruisce le options, non da literal sparsi
- Per i messaggi di validazione usa `view.messages` per locale, oppure `Alpaca.registerMessages`
- Imposta il locale con `"locale"` nella view o globalmente con `Alpaca.setDefaultLocale`
- In un contesto Liferay le chiavi arrivano dai `Language.properties` risolte lato server e passate al JavaScript come oggetto: riusa le chiavi esistenti prima di crearne di nuove

### Esempio corretto
```javascript
"view": {
    "parent": "bootstrap-edit",
    "locale": "it_IT",
    "messages": {
        "it_IT": { "stringValueTooSmall": messages.valoreTroppoCorto }
    }
}
```

# Preferenze di output
Quando produci codice Alpaca:
- separa `schema`, `options`, `view` in variabili o funzioni distinte con nomi parlanti
- estrai in costanti i nomi dei campi usati più volte
- usa funzioni nominate per validator, handler ed eventi; niente logica inline dentro la config
- passa sempre `"view"` esplicitamente
- prendi label e messaggi da un dizionario, mai da literal
- quando modifichi una form esistente, mostra solo il blocco che cambia e rispetta lo stile del file
- se usi una API che non è nel reference verificato, dichiaralo esplicitamente all'utente

# Vincoli
- Non usare API di Alpaca non verificate: in particolare non usare `afterRenderControl`, non chiamare `showMessages()` come metodo, non usare `childrenByPropertyId` su un control field, non affidarti a `Alpaca.defaultView`/`Alpaca.defaultUI`
- Non scrivere una config Alpaca come unico literal annidato con logica inline
- Non manipolare con jQuery gli input generati da Alpaca
- Non scrivere un `validator` che non invoca `callback` su tutti i rami
- Non hardcodare label o messaggi utente nel JavaScript
- Non trattare la validazione client come controllo di sicurezza, e non usare `hidden`/`disabled` per proteggere dati
- Non mettere vincoli di dati in `options` né label in `schema`
- Non caricare Alpaca prima di jQuery, Handlebars e del framework UI
- Non mescolare distribuzioni diverse (CSS `bootstrap` con JS `web`)
- Non aggiornare jQuery/Handlebars oltre le versioni pinnate senza verificare il rendering

# Risorse aggiuntive
- **Superficie API verificata sul sorgente 1.5.27** (metodi di `Field`, membri di `ContainerField`, chiavi di schema e options, elenco dei field type, view disponibili, funzioni globali `Alpaca.*`) e **elenco esplicito di ciò che non esiste**: [reference/api-verificata.md](reference/api-verificata.md)

# Esempi di attivazione
- «Aggiungi un campo condizionale a questa form Alpaca»
- «Questo validator Alpaca non fa mai partire il submit, perché?»
- «Scrivimi un field type custom Alpaca per il codice fiscale»
- «Genera schema e options Alpaca per questo DTO»
- «La form Alpaca non renderizza dopo l'aggiornamento di jQuery»

# Esempi di non attivazione
- «Collega il mio bot ad Alpaca per fare trading» (Alpaca Markets, prodotto diverso)
- «Fine-tuning con il dataset Alpaca» (modello LLM, prodotto diverso)
- «Scrivimi un MVCActionCommand Liferay» → `liferay`
- «Spiegami cos'è JSON Schema»

# Nota finale
Alpaca è dichiarativo fino a quando la form è semplice; da lì in poi il rischio è una config gigante con logica inline e API immaginate. Le due regole che pagano di più sono: **tenere il confine tra schema, options e view**, e **non usare un'API senza averla verificata**.
