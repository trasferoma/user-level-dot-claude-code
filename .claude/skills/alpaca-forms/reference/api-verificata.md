# Alpaca 1.5.27 — superficie API verificata

Riferimento della skill `alpaca-forms`. Ogni voce marcata **[SORGENTE]** è stata letta direttamente dai file JS del repository `gitana/alpaca` (branch `master`, versione `package.json` 1.5.27). Ogni voce marcata **[DOC]** viene dalla documentazione markdown del repo (`site/docs/**`). Ogni voce marcata **[NON VERIFICATO]** non è stata confermata: trattala come ipotesi, non come fatto.

## Indice
1. [Entry point e sotto-comandi jQuery](#1-entry-point-e-sotto-comandi-jquery)
2. [Funzioni globali `Alpaca.*`](#2-funzioni-globali-alpaca)
3. [Metodi di `Field` (classe base)](#3-metodi-di-field-classe-base)
4. [Membri di `ContainerField`](#4-membri-di-containerfield)
5. [Chiavi di schema riconosciute](#5-chiavi-di-schema-riconosciute)
6. [Chiavi di options riconosciute](#6-chiavi-di-options-riconosciute)
7. [Field type disponibili](#7-field-type-disponibili)
8. [View e template](#8-view-e-template)
9. [Eventi](#9-eventi)
10. [Caricamento remoto e Connector](#10-caricamento-remoto-e-connector)
11. [Form e submit](#11-form-e-submit)
12. [Dipendenze condizionali](#12-dipendenze-condizionali)
13. [i18n](#13-i18n)
14. [Cosa NON esiste](#14-cosa-non-esiste)
15. [Cosa resta non verificato](#15-cosa-resta-non-verificato)
16. [Fonti](#16-fonti)

---

## 1. Entry point e sotto-comandi jQuery

**[DOC]** Due forme equivalenti:

```javascript
Alpaca(el, config);
$(el).alpaca({ "data": ..., "schema": ..., "options": ..., "view": ..., "postRender": fn });
```

Chiavi di `config` documentate: `data`, `schema`, `options`, `view`, `render`, `postRender`, `error`, `connector`.

**[SORGENTE]** I sotto-comandi speciali sono esattamente tre, dispatchati in `src/js/Alpaca.js`:

```javascript
var specialFunctionNames = ["get", "exists", "destroy"];
```

- `$(el).alpaca("get")` → restituisce il control esistente
- `$(el).alpaca("exists")` → `true`/`false`
- `$(el).alpaca("destroy")` → invoca `existing.destroy()`

## 2. Funzioni globali `Alpaca.*`

**[SORGENTE]** Presenti in `src/js/Alpaca.js`:

| Simbolo | Note |
|---|---|
| `Alpaca.registerView` | registrazione/override di una view |
| `Alpaca.registerTemplate` | registrazione di un template |
| `Alpaca.registerFieldClass` | registrazione di un field type custom |
| `Alpaca.registerConnectorClass` | registrazione di un connector custom |
| `Alpaca.registerMessages` | registrazione di messaggi i18n |
| `Alpaca.registerDefaultFormatFieldMapping` | mappa uno `schema.format` a un field type |
| `Alpaca.registerDefaultSchemaFieldMapping` | mappa uno `schema.type` a un field type |
| `Alpaca.setDefaultLocale` | imposta il locale di default |
| `Alpaca.defaultLocale` | proprietà del locale corrente |
| `Alpaca.defaultDateFormat` | formato data di default |
| `Alpaca.later` | esecuzione differita |
| `Alpaca.Fields` | namespace delle classi field |
| `Alpaca.Connector` | classe base dei connector |

**[SORGENTE]** NON dichiarati in `src/js/Alpaca.js`: `Alpaca.defaultView`, `Alpaca.defaultUI`, `Alpaca.registerDefaultOptionsFieldMapping`. Passa `"view"` esplicitamente nella config.

## 3. Metodi di `Field` (classe base)

**[SORGENTE]** `src/js/Field.js` — firme esatte:

```javascript
setup: function()
setupField: function(callback)
getFieldType: function()
getValue: function()
setValue: function(value)
getParent: function()
getControlByPath: function(path)
validate: function(validateChildren)
isValid: function(checkChildren)
handleValidate: function()
refreshValidationState: function(validateChildren, cb)
refresh: function(callback)
focus: function(onFocusCallback)
disable: function()
enable: function()
destroy: function()
on: function(name, fn)
triggerWithPropagation: function(name, event, direction)
onFocus: function(e)
onBlur: function(e)
onChange: function(e)
```

**[SORGENTE]** `src/js/fields/basic/TextField.js` fa override di: `setup`, `getValue`, `setValue`, `handleValidate`, `onKeyPress(e)`, `onKeyUp(e)`, `destroy`.

Note operative:
- `refresh(callback)` è **asincrono**: usa la callback.
- `isValid(checkChildren)`: l'argomento booleano fa ricorrere sui figli.
- Negli override chiama `this.base(...)` per invocare l'implementazione a monte.
- `setupField(callback)` **deve** invocare `callback()`.

## 4. Membri di `ContainerField`

**[SORGENTE]** `src/js/ContainerField.js`:

- `children`
- `childrenById`
- `childrenByPropertyId` — inizializzata in `setup()` con `this.childrenByPropertyId = {};`, popolata in `registerChild()` (`this.childrenByPropertyId[child.propertyId] = child;`), ripulita in `unregisterChild()`
- `registerChild()`, `unregisterChild()`, `firstChild()`, `lastChild()`

**[SORGENTE]** Assenti da `ContainerField`: `getChildren`, `addItem`, `removeItem`, `moveItem`.

> `childrenByPropertyId` vive sui container (object/array). Da un control field si raggiunge con `this.getParent().childrenByPropertyId["nomeCampo"]`.

## 5. Chiavi di schema riconosciute

**[SORGENTE]** `Field.getSchemaOfSchema()` — valide su qualsiasi campo:

`title`, `description`, `readonly`, `required`, `default`, `type`, `format`, `disallow`, `dependencies`

**[SORGENTE]** `TextField.getSchemaOfSchema()` aggiunge: `minLength`, `maxLength`, `pattern`

**[DOC]** Altre chiavi usate nella documentazione dei field specifici: `properties`, `items`, `enum`, `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum`, `multipleOf`, `minItems`, `maxItems`, `uniqueItems`, `$ref`, `definitions`, `id`.

**[DOC]** `$ref` supporta schemi ricorsivi e `definitions`:

```javascript
"schema": {
    "id": "#leaf",
    "type": "object",
    "properties": {
        "title": { "type": "string" },
        "children": { "type": "array", "items": { "$ref": "#leaf" } }
    }
}
```

## 6. Chiavi di options riconosciute

**[SORGENTE]** `Field.getSchemaOfOptions()` — valide su qualsiasi campo:

`form`, `id`, `type`, `validate`, `showMessages`, `disabled`, `readonly`, `hidden`, `label`, `helper`, `helpers`, `helpersPosition`, `fieldClass`, `hideInitValidationError`, `focus`, `optionLabels`, `view`

> `showMessages`, `validate` e `focus` sono **option**, non metodi.

**[SORGENTE]** `TextField.getSchemaOfOptions()` aggiunge:

`size`, `maskString`, `placeholder`, `typeahead`, `allowOptionalEmpty`, `inputType`, `data`, `autocomplete`, `disallowEmptySpaces`, `disallowOnlyEmptySpaces`, `trim`

**[DOC]** Altre option documentate per field specifici:

| Field | Option |
|---|---|
| select | `optionLabels`, `multiple`, `size`, `noneLabel`, `removeDefaultNone`, `sort`, `dataSource` |
| radio | `optionLabels`, `vertical`, `removeDefaultNone`, `dataSource` |
| checkbox | `rightLabel`, `optionLabels`, `multiple`, `dataSource` |
| date | `dateFormat`, `picker` (passthrough al Bootstrap DateTime picker: `format`, `minDate`, `maxDate`, `locale`), `manualEntry` |
| upload | `upload: {url, autoUpload, dataType, method}`, `multiple`, `maxFileSize`, `maxNumberOfFiles`, `fileTypes` |
| ckeditor | `ckeditor: { toolbar: [...] }` — CKEditor va caricato prima del render |
| tinymce | richiede TinyMCE caricato prima del render |
| table | `showActionsColumn`, `dragRows`, `datatables`, `toolbarSticky` |
| object | `collapsed`, `lazyLoading`, `itemLabel`, `order`, `view` |
| array | `items.fields.item`, toolbar/actionbar override |

**[DOC]** Regola di scelta automatica: `enum` con più di 3 valori → `select`; con 3 o meno → `radio`, salvo `options.type` esplicito.

## 7. Field type disponibili

**[DOC]** Identificativi presenti in `site/docs/fields/`:

```
address, any, array, checkbox, chooser, ckeditor, color, colorpicker, contenteditable,
country, currency, date, datetime, editor, email, file, grid, hidden, image, integer,
ipv4, json, lowercase, map, markdown, number, object, optiontree, password, personalname,
phone, pickacolor, radio, search, select, state, summernote, table, table2, table3, table4,
tag, text, textarea, time, tinymce, token, upload, uppercase, url, zipcode
```

## 8. View e template

**[SORGENTE]** Directory di template presenti in `src/templates`:

```
bootstrap-display, bootstrap-edit
jqueryui-display,  jqueryui-edit
jquerymobile-display, jquerymobile-edit
web-display, web-edit
```

**[DOC]** Tre tipi semantici di view: `display` (sola lettura), `create` (form vuota, validazione sospesa al primo giro), `edit` (form popolata, validazione immediata). Le view `*-create` esistono come configurazione registrata che eredita i template dalla corrispondente `*-edit`.

**[DOC]** Registrazione di una view custom:

```javascript
Alpaca.registerView({
    "id": "<viewId>",
    "parent": "<parentViewId>",
    "type": "<type>",
    "ui": "<ui>",
    "title": "<title>",
    "displayReadonly": true,
    "templates": { "<templateId>": "<templateOrURI>" },
    "callbacks": { "<callbackId>": callbackFn },
    "styles": { "<styleId>": "<cssClasses>" },
    "horizontal": true
});
```

Le view sono gerarchiche: la figlia eredita template, callback e stili dal `parent`.

**[DOC]** Override di template per singolo path, dentro la view:

```javascript
"view": {
    "fields": {
        "/name": { "templates": { "control-text": "./templates-example2-template.html" } }
    }
}
```

Gli item di array si indirizzano con l'indice: `/address[0]`. Template globale display-only: `"view": { "globalTemplate": "<div>{{{data.name}}}</div>" }`.

**[DOC]** Callback di validazione a livello di view: `valid`, `invalid`, `clearValidity`, `addMessage`, `removeMessages`. I messaggi di default vengono resi in un `DIV.alpaca-message`; i campi ricevono le classi `alpaca-valid` / `alpaca-invalid` / `alpaca-invalid-hidden`.

**[SORGENTE]** Il motore di template è Handlebars (`src/js/HandlebarsTemplateEngine.js`, con `AbstractTemplateEngine.js` e `TemplateEngineRegistry.js`: il motore è sostituibile).

## 9. Eventi

**[DOC]** Nomi di evento per livello:

- Field: `mouseover`, `mouseout`, `ready`
- ControlField: `change`, `focus`, `blur`, `keypress`, `keydown`, `keyup`, `click`
- ContainerField: `add`, `remove`, `move`
- Validazione: `validated`, `invalidated`

Tre modi di agganciarsi:

```javascript
// a) blocco events dichiarativo
"options": { "fields": { "title": { "events": { "change": function() { /* this === field */ } } } } }

// b) postRender + on()
"postRender": function(control) {
    control.childrenByPropertyId["title"].on("change", function() { /* ... */ });
}

// c) override onChange nella classe field
Alpaca.Fields.Custom = Alpaca.Fields.TextField.extend({ onChange: function(e) { /* ... */ } });
```

**[SORGENTE]** Esiste un'infrastruttura di observable (`src/js/Observable.js`, `Observables.js`, `ObservableUtils.js`, `ScopedObservables.js`) usata per le reattività oltre lo schema. Dettaglio d'uso **[NON VERIFICATO]**.

## 10. Caricamento remoto e Connector

**[DOC]**

```javascript
$("#field1").alpaca({
    "dataSource":    "/api/domanda/data.json",
    "schemaSource":  "/api/domanda/schema.json",
    "optionsSource": "/api/domanda/options.json",
    "viewSource":    "/api/domanda/view.json"
});
```

Il contenuto remoto viene **fuso** con quello inline (non è un override pulito).

Connector custom, ad esempio per header di autenticazione:

```javascript
var CustomConnector = Alpaca.Connector.extend({
    buildAjaxConfig: function(uri, isJson) {
        var ajaxConfig = this.base(uri, isJson);
        ajaxConfig.headers = { "ssoheader": "abcdef1" };
        return ajaxConfig;
    }
});
Alpaca.registerConnectorClass("custom", CustomConnector);
```

Il `dataSource` per select/radio/checkbox accetta anche una URL o una `function(callback)` che invoca `callback(arrayDiOpzioni)`.

## 11. Form e submit

**[DOC]**

```javascript
"options": {
  "form": {
    "attributes": { "method": "post", "action": "http://httpbin.org/post" },
    "buttons": {
      "submit": { "click": function() { var value = this.getValue(); /* ... */ } },
      "reset": {},
      "noop": { "type": "button", "value": "Do Nothing", "styles": "btn btn-primary" }
    }
  }
}
```

Submit AJAX con promise jQuery:

```javascript
"submit": {
  "click": function(e) {
    var promise = this.ajaxSubmit();
    promise.done(function() { /* ... */ });
    promise.fail(function() { /* ... */ });
  }
}
```

**[DOC]** La serializzazione produce un oggetto JSON conforme alla forma dello schema, incluse strutture annidate. Non esiste una libreria server-side Alpaca per Java: l'integrazione è JSON su HTTP.

## 12. Dipendenze condizionali

**[DOC]** Due meccanismi distinti.

Dipendenze JSON Schema (v4, a livello di container):

```javascript
"schema": { "dependencies": { "propertyId": ["altroCampo1", "altroCampo2"] } }
```

Dipendenze condizionali Alpaca (a livello di options, show/hide guidato dal valore):

```javascript
"options": {
    "fields": {
        "campoDipendente": { "dependencies": { "campoTrigger": "valoreTrigger" } }
    }
}
```

Il trigger accetta un valore singolo, un booleano o un array di valori.

## 13. i18n

**[DOC]** 16 bundle di locale inclusi (fra cui italiano). Locale per form:

```javascript
"view": { "locale": "es_ES" }
```

Override di messaggi specifici:

```javascript
"view": { "messages": { "es_ES": { "stringValueTooLarge": "messaggio custom" } } }
```

**[SORGENTE]** Locale globale via `Alpaca.setDefaultLocale`; registrazione di messaggi via `Alpaca.registerMessages`. I bundle vivono in `src/js/messages`.

## 14. Cosa NON esiste

Verificato sul sorgente. Non usare:

| Simbolo | Stato |
|---|---|
| `afterRenderControl` | **[SORGENTE]** assente da `Field.js` e da `TextField.js` |
| `showMessages()` come metodo | **[SORGENTE]** `showMessages` è una **option** in `Field.getSchemaOfOptions()`, non un metodo |
| `showHiddenMessages` | **[SORGENTE]** assente da `Field.js` |
| `childrenByPropertyId` su un control field | **[SORGENTE]** vive su `ContainerField`, non su `Field` |
| `Alpaca.defaultView` | **[SORGENTE]** non dichiarato in `src/js/Alpaca.js` |
| `Alpaca.defaultUI` | **[SORGENTE]** non dichiarato in `src/js/Alpaca.js` |
| `Alpaca.registerDefaultOptionsFieldMapping` | **[SORGENTE]** non dichiarato in `src/js/Alpaca.js` |
| `getChildren()`, `addItem()`, `removeItem()`, `moveItem()` | **[SORGENTE]** assenti da `ContainerField.js` |
| costanti `VIEW_WEB_EDIT_*` | non trovate: le view si indicano con l'id stringa |

## 15. Cosa resta non verificato

Da confermare prima di usarle come fatti:

- Dove siano effettivamente definiti (se lo sono) `Alpaca.defaultView` e `Alpaca.defaultUI` fuori da `src/js/Alpaca.js` — la documentazione li cita, il file principale no
- Il dettaglio d'uso delle observable (`Observables.js`)
- La semantica esatta del merge fra config inline e config remota per la stessa chiave
- Il percorso CDN preciso delle distribuzioni `web`, `jqueryui`, `jquerymobile` su jsDelivr (confermato solo `bootstrap`)
- La compatibilità con Bootstrap 4/5: il pin in `bower.json` è Bootstrap `3.3.2`

## 16. Fonti

- Repository: `https://github.com/gitana/alpaca` — versione `package.json` 1.5.27, ultimo tag `1.5.27`, repository non archiviato ma con backlog di issue ampio
- Sorgenti letti: `src/js/Alpaca.js`, `src/js/Field.js`, `src/js/ContainerField.js`, `src/js/fields/basic/TextField.js`, listato di `src/js` e `src/templates`
- Manifest: `package.json`, `bower.json`
- Documentazione: `site/docs/api/*.md` (usage, views, templates, custom-fields, validation, events, connectors, serialization, forms, i18n, references, dependencies, conditional-dependencies) e `site/docs/fields/*.md`
- Il sito `www.alpacajs.org` è risultato irraggiungibile durante la raccolta: i contenuti **[DOC]** vengono dai sorgenti markdown che generano quel sito
