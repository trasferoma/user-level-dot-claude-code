---
name: testing-only-production-logic
description: Scrivere test solo quando esiste logica di produzione da verificare; non testare fake/lambda/mock scritti nel test stesso
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b77dfaae-5183-4de5-a2da-b31f70df7606
---

Scrivere un test solo quando il System Under Test è codice di produzione reale (`src/main`). Non scrivere test il cui SUT è codice scritto nel test stesso: una fake che implementa un'interfaccia di produzione, una lambda che implementa un'interfaccia funzionale, o un mock verificato direttamente. Quei test verificano il test (o Mockito), non la produzione.

Regola pratica:
- Mockare/fakeare un'interfaccia **per testare la produzione che la consuma** → valore alto (es. mock di `TaskTransport` per testare `TaskReporter`).
- Implementare un'interfaccia nel test **per poi testare quell'implementazione** → valore nullo, non farlo.
- Le interfacce SPI con implementazione nostra si testano quando esiste l'implementazione concreta (es. `InMemoryTaskTransport`), non con una fake provvisoria.
- Le interfacce funzionali implementate dall'utente (es. `TaskListener`) non richiedono test propri: il compilatore garantisce già l'usabilità come lambda.

**Why:** richiesta esplicita dell'utente il 2026-06-28. Considera senza valore aggiunto i test che esercitano codice di test invece del codice di produzione.

**How to apply:** quando implemento per fasi e un'interfaccia non ha ancora implementazione concreta, NON creare test placeholder con fake/lambda. Aspettare la classe concreta e testare quella. Vale per il progetto task-telemetry (vedi [[task-telemetry-project]]).
