---
name: docker29-testcontainers-fix
description: "Fix for Testcontainers \"Could not find a valid Docker environment\" on this project with Docker Engine 29"
metadata: 
  node_type: memory
  type: project
  originSessionId: a73af4cd-ccd0-4b48-8855-86bd5d897f42
---

In questo progetto (Spring Boot 3.4.1, Testcontainers 1.20.4, Docker Engine 29.x) i test `@SpringBootTest` con Testcontainers fallivano con "Could not find a valid Docker environment". Causa: Docker 29 richiede API >= 1.44 e docker-java in Testcontainers 1.x usa una default inferiore.

**Fix confermato empiricamente:** nel `pom.xml`, blocco `maven-surefire-plugin` con `<systemPropertyVariables><api.version>1.44</api.version></systemPropertyVariables>`. Rimuovendolo i test falliscono, rimettendolo funzionano.

**Why:** il blocco era stato proposto come "Plan A" e si è rivelato la soluzione reale, non un workaround marginale.

**How to apply:**
- Usare la system property `api.version` (canale letto da docker-java), NON l'env var `DOCKER_API_VERSION` (ignorata da docker-java).
- NON impostare `DOCKER_HOST=npipe:////./pipe/docker_engine`: quel valore manda docker-java in URISyntaxException.
- IntelliJ qui esegue i test via Maven, quindi la config surefire vale sia per `mvn test` sia per il run dall'IDE.
- Fix "ufficiale" alternativo (non adottato): Spring Boot 4.x + Testcontainers 2.x, che supportano Docker 29 nativamente.
