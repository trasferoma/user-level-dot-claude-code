# Esempi estesi: Liferay 7.4 su Java 11

## Indice
- MVC commands: render, action, resource separati (§5)
- OSGi services: API, implementazione e consumo via @Reference (§6)
- Configuration framework e portlet preferences (§10)

Le regole e il «perché» stanno in `SKILL.md`. Qui ci sono solo gli esempi completi.

---

## MVC commands (§5)

### Esempio corretto
```java
@Component(
    property = {
        "javax.portlet.name=com_acme_demo_web_DemoPortlet",
        "mvc.command.name=/demo/save"
    },
    service = MVCActionCommand.class
)
public class SaveDemoMVCActionCommand extends BaseMVCActionCommand {

    @Override
    protected void doProcessAction(
            ActionRequest actionRequest,
            ActionResponse actionResponse)
        throws Exception {

        String name = ParamUtil.getString(actionRequest, "name");
        actionRequest.setAttribute("savedName", name);
    }
}
```

### Anti-esempio
```java
public class DemoPortlet extends MVCPortlet {

    @Override
    public void processAction(
            ActionRequest actionRequest,
            ActionResponse actionResponse)
        throws IOException, PortletException {

        String mvcCommandName = ParamUtil.getString(actionRequest, "mvcCommandName");

        if ("/demo/save".equals(mvcCommandName)) {
            // save logic
        }
        else if ("/demo/delete".equals(mvcCommandName)) {
            // delete logic
        }
        else if ("/demo/export".equals(mvcCommandName)) {
            // export logic
        }
    }
}
```


---

## OSGi services (§6)

### Esempio corretto
```java
public interface GreetingService {

    String getGreeting(long userId);
}
```

```java
@Component(service = GreetingService.class)
public class GreetingServiceImpl implements GreetingService {

    @Override
    public String getGreeting(long userId) {
        return "Hello user " + userId;
    }
}
```

```java
@Component(
    property = {
        "javax.portlet.name=com_acme_demo_web_DemoPortlet",
        "mvc.command.name=/demo/view"
    },
    service = MVCRenderCommand.class
)
public class ViewDemoMVCRenderCommand implements MVCRenderCommand {

    @Reference
    private GreetingService greetingService;

    @Override
    public String render(
            RenderRequest renderRequest,
            RenderResponse renderResponse)
        throws PortletException {

        renderRequest.setAttribute("message", greetingService.getGreeting(12345L));
        return "/view.jsp";
    }
}
```


---

## Configurazione e preferenze (§10)

### Esempio corretto
```java
@ObjectClassDefinition(
    id = "com.acme.demo.configuration.DemoConfiguration",
    name = "demo-configuration-name"
)
public @interface DemoConfiguration {

    @AttributeDefinition(name = "default-message")
    String defaultMessage() default "Hello";
}
```

```java
@Component(configurationPid = "com.acme.demo.configuration.DemoConfiguration")
public class DemoConfigurationProvider {

    private volatile DemoConfiguration demoConfiguration;

    @Activate
    @Modified
    protected void activate(Map<String, Object> properties) {
        this.demoConfiguration = ConfigurableUtil.createConfigurable(
            DemoConfiguration.class, properties);
    }

    public String getDefaultMessage() {
        return this.demoConfiguration.defaultMessage();
    }
}
```

