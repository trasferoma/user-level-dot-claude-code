---
name: build-richiede-jdk-11
description: "i test/build Gradle vanno lanciati con JDK 11, non col JDK 17 di default in JAVA_HOME"
metadata: 
  node_type: memory
  type: project
  originSessionId: bea1acaa-ca5c-4d81-ab9a-02074b060b8b
---

Il `JAVA_HOME` di sistema punta a JDK 17 (`C:\lavoro\jdk\openlogic-openjdk-17.0.6+10-windows-x64`), ma il workspace Liferay usa **Gradle 6.6.1** che con JDK 16+ rompe il compilatore incrementale (`IllegalAccessError ... com.sun.tools.javac.code` su `compileJava`). Il progetto è Java 11.

**Come buildare/testare:** usare il JDK 11 presente in `C:\lavoro\jdk\openlogic-openjdk-11.0.18+10-windows-x64`, es. in PowerShell:

```
$env:JAVA_HOME = "C:\lavoro\jdk\openlogic-openjdk-11.0.18+10-windows-x64"; $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"; .\gradlew <task>
```

**Why:** senza questo, qualunque task Gradle che compila Java fallisce con errore d'ambiente, non di codice.
**How to apply:** prima di lanciare `gradlew test`/build, forzare JAVA_HOME a JDK 11 per l'invocazione.
