---
name: liferay
description: Applica le convenzioni Liferay 7.4 su Java 11 quando generi o modifichi moduli Liferay. Usa per portlet (MVCPortlet), MVC command (MVCRenderCommand, MVCActionCommand, MVCResourceCommand), servizi OSGi (@Component, @Reference), Service Builder, configuration framework, portlet preferences, JSP come view, validazioni con Validator ed eccezioni PortalException. Resta pre-Jakarta: usa javax.portlet.*, NON jakarta.portlet.*. Da comporre con clean-code, java-conventions e java-version-11.
---

# Scopo
Applicare convenzioni e vincoli specifici per la generazione o modifica di codice Liferay 7.4 basato su Java 11.

# Quando usare questa skill
Usa questa skill se:
- l'utente chiede di generare codice per Liferay 7.4
- l'utente chiede portlet, comandi MVC, servizi OSGi, configurazioni o moduli per Liferay
- l'utente chiede codice Service Builder o personalizzazioni tipiche del modello Liferay
- il contesto del task è chiaramente un progetto Liferay 7.4 su Java 11

# Quando NON usare questa skill
Non usare questa skill se:
- l'utente chiede solo Java generico senza contesto Liferay
- l'utente chiede codice Spring Boot standalone senza runtime Liferay
- il task riguarda una release Liferay Jakarta-based o diversa dalla baseline 7.4 Java 11
- l'utente chiede solo spiegazioni teoriche senza codice
- il codice richiesto non è Java

# Regole di precedenza
- Le istruzioni esplicite dell'utente hanno priorità superiore
- Le regole di sicurezza e i vincoli globali hanno priorità superiore
- Questa skill si compone con `clean-code`
- Questa skill si compone con `java-conventions`
- Questa skill si compone con `java-version-11`
- In caso di conflitto con skill Java generiche, questa skill prevale sulle convenzioni specifiche del contesto Liferay
- In caso di conflitto con skill più specifiche per sottodomini Liferay, prevale la skill più specifica
- Se il contesto reale è Jakarta-based, questa skill non deve governare package, API o dipendenze migrate a `jakarta.*`

# Obiettivi
Il codice generato deve essere:
- compatibile con Liferay 7.4 su Java 11
- coerente con il modello modulare OSGi di Liferay
- leggibile e manutenibile
- integrabile in un workspace Liferay
- conforme al contesto pre-Jakarta della baseline target

# Regole operative

## 1. Modello architetturale

### Regola
- Generare codice come modulo Liferay, non come applicazione standalone
- Privilegiare componenti OSGi registrati tramite `@Component`
- Per logica applicativa o integrazioni interne al portale, preferire servizi OSGi rispetto a utility statiche globali
- Non assumere un contesto Spring Boot autonomo fuori dal runtime Liferay

### Perché
Nel contesto Liferay il runtime, il ciclo di vita e la risoluzione delle dipendenze ruotano intorno a OSGi. Generare codice come se fosse un'applicazione standalone porta facilmente a componenti difficili da integrare, testare e distribuire.

### Esempio corretto
```java
@Component(service = ReportGenerator.class)
public class ReportGenerator {

    public String generate(long companyId) {
        return "Report for company " + companyId;
    }
}
```

### Anti-esempio
```java
public class ReportGenerator {

    public static String generate(long companyId) {
        return "Report for company " + companyId;
    }
}
```

## 2. Workspace e target platform
- Assumere sviluppo all'interno di una Liferay Workspace
- Mantenere il codice coerente con la target platform della release 7.4 scelta nel workspace
- Non introdurre dipendenze arbitrarie che bypassano inutilmente la target platform
- Generare codice pensando a deploy come modulo OSGi, non come war tradizionale salvo richiesta esplicita

## 3. Namespace e baseline pre-Jakarta

### Regola
- Assumere namespace `javax.*` per API portlet e riferimenti legacy compatibili con Liferay 7.4 pre-Jakarta
- Non introdurre package `jakarta.*` per portlet o mail se il task resta sul perimetro Liferay 7.4 Java 11
- Non generare codice già migrato a Jakarta salvo richiesta esplicita dell'utente
- Se il task parla di upgrade a Jakarta, questa skill non basta da sola e non deve forzare scelte incompatibili

### Perché
Su questa baseline usare package Jakarta nel codice generato significa spesso produrre classi non coerenti con il runtime target. È uno di quegli errori molto moderni e molto inutili che fanno perdere tempo subito.

### Esempio corretto
```java
import javax.portlet.Portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import org.osgi.service.component.annotations.Component;

@Component(
    property = {
        "com.liferay.portlet.display-category=category.sample",
        "javax.portlet.name=com_acme_demo_web_DemoPortlet",
        "javax.portlet.init-param.view-template=/view.jsp"
    },
    service = Portlet.class
)
public class DemoPortlet extends MVCPortlet {
}
```

### Anti-esempio
```java
import jakarta.portlet.Portlet;
```

## 4. MVC Portlet

### Regola
- Per portlet semplici, usare `MVCPortlet` con `@Component`
- Definire le property del componente in modo chiaro e minimale
- Per la view principale, usare `javax.portlet.init-param.view-template=/view.jsp`
- Collocare le JSP sotto `resources/META-INF/resources`
- Non concentrare tutta la logica nel portlet class quando il flusso cresce

### Perché
La classe del portlet deve restare un punto di ingresso sottile. Appena diventa il contenitore di tutta la logica, il modulo degrada rapidamente in un miscuglio di rendering, business logic e accesso ai dati.

### Esempio corretto
```java
@Component(
    property = {
        "com.liferay.portlet.display-category=category.sample",
        "javax.portlet.name=com_acme_demo_web_DemoPortlet",
        "javax.portlet.init-param.view-template=/view.jsp"
    },
    service = Portlet.class
)
public class DemoPortlet extends MVCPortlet {
}
```

## 5. MVC commands

### Regola
- Quando la logica di render cresce, preferire `MVCRenderCommand`
- Per azioni utente, preferire `MVCActionCommand`
- Per download, AJAX o risposte binarie, preferire `MVCResourceCommand`
- Tenere separati render, action e resource flow
- Usare `mvc.command.name` in modo esplicito e coerente

### Perché
Separare i flussi evita portlet monolitici e rende chiara la responsabilità di ogni entry point. È il confine tra un modulo Liferay gestibile e una creatura mutante che nessuno vuole più toccare.

### Esempi
Esempio corretto e anti-esempio a confronto: vedi [reference/examples.md](reference/examples.md).

## 6. OSGi services

### Regola
- Separare API e implementazione quando il servizio è riusabile o consumato da più moduli
- Esporre servizi tramite interfacce chiare
- Consumare servizi OSGi via `@Reference`
- Evitare lookup manuali o accoppiamenti inutili al portale
- Non usare servizi statici o pattern legacy se un servizio OSGi normale è sufficiente

### Perché
Un servizio OSGi chiaro e referenziato correttamente è più facile da riusare e testare. Lookup manuali e singleton statici sono spesso solo un modo creativo per sabotare modularità e manutenibilità.

### Esempi
Esempio corretto e anti-esempio a confronto: vedi [reference/examples.md](reference/examples.md).

## 7. Service Builder

### Regola
- Quando il dominio richiede persistence e servizi applicativi Liferay-style, preferire Service Builder
- Le classi rigenerate a ogni run sono `*LocalServiceBaseImpl`, l'interfaccia `*LocalService`, `*LocalServiceWrapper` e `*LocalServiceUtil`: non si toccano
- La logica custom si scrive in `*LocalServiceImpl`, che Service Builder genera solo la prima volta e poi non sovrascrive; per intercettare o decorare un servizio senza toccarlo, estendere `*LocalServiceWrapper` in un componente OSGi
- Usare Service Builder per model, persistence e local/remote service solo quando c'è reale bisogno di quel layer
- Non usare Service Builder per casi banali che non richiedono il framework

### Perché
Service Builder è utile quando serve davvero il suo modello di persistence e servizi. Usarlo ovunque o modificare codice generato porta a un debito tecnico molto diligente e molto stupido.

### Esempio corretto
```java
@Component(service = FooLocalServiceWrapper.class)
public class CustomFooLocalServiceWrapper
    extends FooLocalServiceWrapper {

    public CustomFooLocalServiceWrapper() {
        super(null);
    }

    @Override
    public Foo addFoo(String name, ServiceContext serviceContext)
        throws PortalException {

        validate(name);

        return super.addFoo(name, serviceContext);
    }

    private void validate(String name) throws InvalidFooException {
        if (Validator.isBlank(name)) {
            throw new InvalidFooException(name);
        }
    }
}
```

`addFoo(String, ServiceContext)` è un metodo custom scritto in `FooLocalServiceImpl` con `throws PortalException`: Service Builder ne propaga la firma, clausola `throws` compresa, nell'interfaccia e nel wrapper, quindi l'override può dichiararla. Sui CRUD generati come `addFoo(Foo)`, che non dichiarano `throws`, l'eccezione di validazione non potrebbe risalire. Regole di validazione: §15.

### Anti-esempio
```java
// Modifica manuale di una classe rigenerata a ogni run di Service Builder.
public abstract class FooLocalServiceBaseImpl extends BaseLocalServiceImpl
    implements FooLocalService {

    public Foo dangerousCustomChange(Foo foo) {
        return fooPersistence.update(foo);
    }
}
```
## 8. Livelli di responsabilità: Finder e LocalServiceImpl restano legati all'entità

### Regola
- I `*Finder` e i `*LocalServiceImpl` di Service Builder sono legati all'entità che manipolano: contengono solo persistence, query e CRUD di quella singola entità.
- Non inserire nei `*Finder` logica trasversale o di orchestrazione (risoluzione di utente/contesto, decisioni cross-entità, regole applicative). Un Finder costruisce ed esegue query, niente di più.
- Non "promuovere" quella logica al `*LocalServiceImpl` credendo di aver risolto: anche il LocalServiceImpl è vincolato alla stessa singola entità. Spostare un resolver dal Finder al LocalServiceImpl non cambia il livello architetturale, sposta il problema di un gradino restando nello stesso layer sbagliato.
- La logica trasversale (un resolver che decide quale utente applicare, il coordinamento di più entità, le regole di business che attraversano più servizi) va agganciata a un livello superiore: i service applicativi / orchestratori di dominio (per esempio un `*FrontendService` o un orchestrator), che a loro volta invocano i `*LocalService` delle singole entità.
- Regola pratica: se un componente deve conoscere più di una entità, oppure deve prendere decisioni che non riguardano la persistenza di quella singola entità, non appartiene né al Finder né al LocalServiceImpl. Sale di livello.

### Perché
Per costruzione di Service Builder, Finder e LocalServiceImpl sono il layer di accesso e gestione di UNA entità. Iniettarci dentro la risoluzione di un contesto trasversale (per esempio un `OldUserResolver`) accoppia la persistenza a decisioni che non le competono, la rende difficile da riusare e testare, e la costringe a essere duplicata appena un'altra entità ha lo stesso bisogno. La logica trasversale ha senso solo dove esiste visibilità sull'intero caso d'uso, cioè negli orchestratori applicativi sopra il layer di persistenza. Spostarla dal Finder al LocalServiceImpl è la trappola tipica: sembra un avanzamento, ma resta nello stesso livello legato all'entità.

### Esempio corretto
```java
@Component(service = ScrivaniaOperatoreBandiFrontendService.class)
public class ScrivaniaOperatoreBandiFrontendService {

    @Reference
    private OldUserResolver oldUserResolver;

    @Reference
    private DomandaBandoLocalService domandaBandoLocalService;

    public List<DomandaBando> listDomandeForOperatore(long operatoreUserId, long bandoId) {
        long effectiveUserId = oldUserResolver.resolve(operatoreUserId);

        return domandaBandoLocalService.getDomandeByBandoAndUser(bandoId, effectiveUserId);
    }
}
```

### Anti-esempio
```java
// OldUserResolver agganciato nel layer legato all'entità: prima nel Finder,
// poi "promosso" al LocalServiceImpl. Entrambe le posizioni sono sbagliate.
public class DomandaBandoLocalServiceImpl extends DomandaBandoLocalServiceBaseImpl {

    @Reference
    private OldUserResolver oldUserResolver;

    public List<DomandaBando> getDomandeByBandoAndUser(long bandoId, long userId) {
        long effectiveUserId = oldUserResolver.resolve(userId);

        return domandaBandoPersistence.findByBandoAndUser(bandoId, effectiveUserId);
    }
}
```

## 9. Upgrade e schema evolution
- Se il modulo evolve il database, prevedere upgrade processes invece di cambiamenti impliciti non tracciati
- Trattare l'evoluzione dello schema come parte esplicita del modulo
- Non fare affidamento su modifiche manuali non ripetibili
- Mantenere chiara la relazione tra versione del modulo e logica di upgrade

## 10. Configurazione e preferenze

### Regola
- Per configurazioni applicative, preferire il configuration framework di Liferay
- Per preferenze specifiche del portlet, usare portlet preferences quando il requisito è davvero a livello di istanza portlet
- Non confondere configurazione applicativa, configurazione di istanza e preferenze utente
- Mantenere separati i livelli di configurazione

### Perché
Confondere configurazione globale e preferenze di istanza crea moduli difficili da governare. Una scelta sbagliata qui si paga dopo, quando qualcuno scopre che un valore doveva valere per tutto il portale e invece cambia per singola portlet, o viceversa.

### Esempi
Esempio corretto e anti-esempio a confronto: vedi [reference/examples.md](reference/examples.md).

## 11. Localizzazione

### Regola
- Se il portlet ha UI o messaggi utente, prevedere resource bundle e chiavi di lingua
- Non hardcodare stringhe utente direttamente in JSP o classi Java
- Tenere chiavi e messaggi coerenti con il naming del modulo

### Perché
Stringhe hardcoded in codice e JSP sono facili da scrivere e fastidiose da mantenere. La localizzazione va trattata come parte del contratto della UI, non come un accessorio messo dopo.

### Esempio corretto
```java
String title = LanguageUtil.get(resourceBundle, "demo-title");
renderRequest.setAttribute("title", title);
```

### Anti-esempio
```java
renderRequest.setAttribute("title", "Demo title");
```

## 12. Dipendenze e API
- Preferire API Liferay e API standard compatibili con Java 11 già coerenti con la target platform
- Non introdurre librerie moderne incompatibili con il runtime target
- Non assumere supporto a Spring 6 o stack Jakarta nel contesto pre-Jakarta
- Evitare dipendenze ridondanti quando il portale fornisce già il necessario

## 13. JSP e presentazione

### Regola
- Usare JSP solo per responsabilità di view
- Non spostare logica business rilevante dentro JSP
- Preparare i dati in render command, action command o servizi dedicati
- Mantenere la view semplice, localizzata e orientata al rendering

### Perché
Quando la JSP contiene branching applicativo, query o logica di business, il modulo diventa più fragile e meno testabile. Le JSP dovrebbero mostrare dati, non prendere decisioni architetturali in silenzio.

### Esempio corretto
```jsp
<%@ include file="/init.jsp" %>

<h1>${title}</h1>
<p>${message}</p>
```

### Anti-esempio
```jsp
<%
String userType = request.getParameter("userType");
if ("admin".equals(userType)) {
    // business logic
}
%>
```

## 14. JavaScript di portlet

### Regola
- Il JavaScript di un portlet vive in un file `.js` sotto `META-INF/resources/js/`, dichiarato nel `@Component` del portlet con `com.liferay.portlet.header-portlet-javascript=/js/<nome>.js`
- Non creare JSP per contenere JavaScript, e non mettere logica in `<script>` inline dentro le JSP
- I valori dinamici — messaggi localizzati, URL di resource, identificativi — entrano dal markup: attributi `data-*` letti dal JS, oppure un oggetto di configurazione passato a una funzione di inizializzazione
- Preferire gli attributi `data-*` all'interpolazione dentro stringhe JS
- Nella JSP resta al massimo la chiamata di inizializzazione
- Non registrare listener globali nel corpo del file, per esempio su `document`: lo script può essere eseguito più volte nella vita della pagina — le navigazioni SPA di Liferay rieseguono gli script dell'header senza ricreare `document` — e i listener si accumulano in silenzio. Esporre una funzione e invocarla da `onclick`, oppure rendere idempotente l'inizializzazione

### Perché
Un file `.js` è una risorsa statica: il browser la mette in cache, l'IDE la evidenzia e la controlla, si può minificare e leggere fuori dal contesto di rendering. Uno script inline viaggia nel markup a ogni render e perde tutto questo. Si porta anche dietro problemi che nel file non esistono: il namespace del portlet sui nomi globali e la guardia contro la doppia inclusione servono solo perché il frammento è incluso in più pagine.

Interpolare un messaggio localizzato dentro una stringa JS è inoltre una fonte di guasti silenziosi: un apostrofo nella traduzione chiude la stringa e rende inerte l'intero script. In un attributo `data-*` l'escaping è quello dell'HTML e il problema non si presenta.

L'accumulo dei listener è il guasto più insidioso di questa famiglia, perché non produce errori: un click esegue l'azione tante volte quante lo script è stato eseguito. Su un download significa altrettante richieste al server e altrettanti file consegnati al browser, che dal secondo in poi li blocca come download automatici. `onclick` non ha bisogno di guardie perché l'attributo è uno solo nel markup: le riesecuzioni ridefiniscono la funzione invece di aggiungere handler.

### Esempio corretto
```java
@Component(
	property = { //
		"com.liferay.portlet.header-portlet-javascript=/js/download-allegati.js", //
		"javax.portlet.name=" + MyPortletKeys.MY_PORTLET //
	},
	service = Portlet.class
)
public class MyPortlet extends MVCPortlet {
}
```

```jsp
<button type="button"
	onclick="downloadAllegati(this)"
	data-download-url="${downloadUrl}"
	data-download-error="<liferay-ui:message key='errore-download' />">
	<liferay-ui:message key="scarica" />
</button>
```

```javascript
// js/download-allegati.js
(function () {
	function download(url, errorMessage) { }

	window.downloadAllegati = function (button) {
		download(button.dataset.downloadUrl, button.dataset.downloadError);
	};
})();
```

La JSP invoca la funzione dal bottone: `onclick="downloadAllegati(this)"`. L'IIFE tiene private le funzioni di supporto ed espone il solo nome che serve al markup.

### Anti-esempio
```jsp
<%-- script_download.jsp: JSP creata solo per contenere JavaScript, inclusa in più pagine --%>
<script>
	var messaggio = '<liferay-ui:message key="errore-download" />';

	function <portlet:namespace/>download() { }
</script>
```

```javascript
// js/download-allegati.js: a ogni ri-esecuzione dello script si aggiunge un listener
document.addEventListener('click', function (event) {
	var button = event.target.closest('[data-download-url]');

	if (button) {
		download(button.dataset.downloadUrl);
	}
});
```

## 15. Validazioni

### Regola
- Per i controlli di validità dei valori usare `com.liferay.portal.kernel.util.Validator`, non controlli ad hoc riscritti a mano (`s == null || s.trim().isEmpty()`, regex per email o URL)
- Leggere i parametri di request con `ParamUtil` e un default esplicito, poi validarli con `Validator`: `ParamUtil` estrae e converte, non valida
- Segnalare una validazione fallita con un'eccezione dedicata che estende `com.liferay.portal.kernel.exception.PortalException`, non con `IllegalArgumentException` né con un ritorno `null`
- Nel MVC command intercettare quell'eccezione e registrarla con `SessionErrors.add(actionRequest, exception.getClass())`, usando la classe come chiave; la JSP la mostra con `<liferay-ui:error exception="..." message="chiave-i18n"/>`
- Per i vincoli di lunghezza delle entità Service Builder leggere il valore da `ModelHintsUtil.getMaxLength(model, field)` invece di duplicare la costante nel codice
- Non introdurre Bean Validation (`javax.validation`, Hibernate Validator) nei moduli: in 7.4 non è integrata nel runtime OSGi del portale

### Metodi disponibili su `Validator`
`isNull` / `isNotNull` / `isBlank`, `isNumber`, `isBoolean`, `isEmailAddress`, `isUrl`, `isUri`, `isDomain`, `isHostName`, `isIPAddress`, `isPhoneNumber`, `isHex`, `isFileName`, `isFileExtension`, `isFilePath`, `isVariableName`, `isPassword`, `isLUHN`, `isDate(int month, int day, int year)`.

Tre assenze da non inventare: `isNotBlank` non esiste, si nega `!Validator.isBlank(s)`; `isDate` non ha overload su `String`, la data testuale si parsa prima con `ParamUtil.get(request, name, dateFormat, default)`; `Validator` non ha un `equals` per singole stringhe, si usa `Objects.equals`.

### Perché
`Validator` è già nel classpath del portale e dà la stessa semantica di null-check, email e URL a tutto il codice Liferay: riscrivere quei controlli a mano significa che ogni modulo ha la propria idea di «vuoto» e la propria regex sbagliata. L'eccezione tipata più `SessionErrors` è la catena che `<liferay-ui:error>` sa già leggere; chi la rompe si ritrova a costruire i messaggi di errore nella view, che è esattamente dove non devono stare.

### Esempi
Esempio corretto e anti-esempio a confronto, con MVC command, eccezione custom e JSP: vedi [reference/examples.md](reference/examples.md).

## 16. Compatibilità con le skill di base
- Usare `clean-code` come base predefinita
- Usare `java-conventions` per convenzioni Java generali
- Usare `java-version-11` per i vincoli di versione
- Usare questa skill solo per le convenzioni specifiche del contesto Liferay 7.4 Java 11

# Preferenze di output
Quando generi codice Liferay 7.4 Java 11:
- privilegia moduli OSGi chiari e separati
- preferisci componenti piccoli e focalizzati
- evita soluzioni pensate per Spring Boot standalone
- evita API Jakarta e feature fuori baseline
- mantieni il codice coerente con workspace, target platform e pattern MVC/OSGi di Liferay

# Vincoli
- Non usare `jakarta.portlet.*` o package Jakarta-equivalenti in questa baseline
- Non usare API o feature Java superiori a Java 11
- Non generare codice che richieda una release Jakarta-based di Liferay
- Non modificare a mano le classi rigenerate da Service Builder (`*LocalServiceBaseImpl`, `*LocalService`, `*LocalServiceWrapper`, `*LocalServiceUtil`)
- Non inserire logica trasversale o di orchestrazione (resolver, decisioni cross-entità, regole di business) nei `*Finder` né nei `*LocalServiceImpl`: sono legati alla singola entità; quella logica va nei service applicativi/orchestratori di livello superiore
- Non riscrivere a mano controlli già coperti da `Validator` (null-check su stringhe, email, URL, numeri)
- Non usare `IllegalArgumentException` o un ritorno `null` per segnalare una validazione di business fallita: serve un'eccezione che estende `PortalException`
- Non introdurre Bean Validation (`javax.validation`) nei moduli OSGi di questa baseline
- Non mettere logica business sostanziale dentro JSP
- Non introdurre dipendenze non necessarie che confliggono con la target platform Liferay

# Esempi di attivazione
- "Scrivimi un MVCPortlet per Liferay 7.4"
- "Genera un MVCActionCommand per questo form"
- "Crea un servizio OSGi consumabile da un modulo Liferay"
- "Scrivimi un modulo Service Builder per Liferay 7.4"
- "Rifattorizza questo codice Liferay 7.4 mantenendo Java 11"

# Esempi di non attivazione
- "Scrivimi una REST API Spring Boot standalone"
- "Genera codice Jakarta Portlet 4.0"
- "Scrivimi una record class Java 21"
- "Dammi solo pseudocodice"

# Commenti
Non mettere mai commenti con il codice html, se li vedi nel codice che leggi per altri motivi segnalane la presenza

# Nota finale
Questa skill definisce convenzioni specifiche per generazione di codice Liferay 7.4 su Java 11 in contesto pre-Jakarta.
Non sostituisce le skill generali di clean code, convenzioni Java e vincoli di versione Java, ma le specializza per il modello Liferay.
