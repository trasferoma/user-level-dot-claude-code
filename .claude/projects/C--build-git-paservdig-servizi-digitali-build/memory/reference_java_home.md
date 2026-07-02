---
name: JAVA_HOME path on this machine
description: Path della JDK 11 da usare come JAVA_HOME quando si lanciano task Gradle in questo progetto
type: reference
originSessionId: dbe51c82-bd23-436d-9c30-2d07263c9bdd
---
`JAVA_HOME` su questa macchina punta a `C:\lavoro\jdk\openlogic-openjdk-11.0.18+10-windows-x64`.

Da usare quando un comando `gradlew` fallisce con `JAVA_HOME is not set and no 'java' command could be found in your PATH`. In PowerShell impostare `$env:JAVA_HOME = "C:\lavoro\jdk\openlogic-openjdk-11.0.18+10-windows-x64"` prima di rilanciare `.\gradlew.bat`.
