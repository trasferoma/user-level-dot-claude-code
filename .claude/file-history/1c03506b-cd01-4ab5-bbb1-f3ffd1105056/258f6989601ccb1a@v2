---
name: build-command
description: Come compilare/eseguire i test di questo progetto Maven (mvn e JAVA_HOME non sono nel PATH)
metadata: 
  node_type: memory
  type: reference
  originSessionId: 1c03506b-cd01-4ab5-bbb1-f3ffd1105056
---

Su questa macchina `mvn` e `JAVA_HOME` non sono nel PATH. Per eseguire build/test del progetto jrxml-designer da PowerShell:

```
$env:JAVA_HOME = "C:\lavoro\jdk\openlogic-openjdk-17.0.6+10-windows-x64"
$mvn = "C:\Users\fabio.dearcangelis\AppData\Local\Programs\IntelliJ IDEA\plugins\maven\lib\maven3\bin\mvn.cmd"
& $mvn -q -Dtest=NomeTest test
```

- JDK: `C:\lavoro\jdk\openlogic-openjdk-17.0.6+10-windows-x64` (Java 17; il pom ha source/target 17).
- Maven: quello bundle di IntelliJ in `plugins\maven\lib\maven3\bin\mvn.cmd`.
- I PDF generati dai test finiscono in `target/pdf/` (vedi [[jr-statictext-clips]] per i template jrxml).
