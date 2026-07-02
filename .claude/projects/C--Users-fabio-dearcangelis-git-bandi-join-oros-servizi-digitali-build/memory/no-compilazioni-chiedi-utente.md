---
name: no-compilazioni-chiedi-utente
description: "Progetti Liferay: non lanciare build in autonomia, le fa l'utente a mano"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: bc08303c-816d-4928-85db-777907e6f825
---

**Solo per progetti Liferay** (es. servizi-digitali-build): non lanciare compilazioni/build del progetto, e non lasciare che i subagent (es. `clean-code-implementer`) le lancino. Dopo aver scritto/modificato codice, fermati e chiedi all'utente di compilare a mano, poi attendi il suo esito prima di aggiornare lo stato dei task. Su progetti non-Liferay il vincolo non si applica.

**Why:** la build Gradle Liferay richiede setup manuale (JDK 11, vedi [[build-richiede-jdk-11]]) e va gestita dall'utente per motivi ambientali; un subagent che tentava di compilare è stato interrotto.
**How to apply:** nelle deleghe a `clean-code-implementer` includi il vincolo esplicito "non compilare, non lanciare gradle"; a fine modifica chiedi tu all'utente di buildare e aspetta conferma.
