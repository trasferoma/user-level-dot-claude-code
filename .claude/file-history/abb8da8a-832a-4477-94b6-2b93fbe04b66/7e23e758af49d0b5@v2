---
name: role-switch-servlet-vs-filter
description: Perché lo switch profilo IAM usa un BasePortalFilter e non un servlet OSGi /o
metadata: 
  node_type: memory
  type: project
  originSessionId: abb8da8a-832a-4477-94b6-2b93fbe04b66
---

Lo switch profilo cittadino/operatore (branch `feature/iam-operatore`, modulo `servizi-digitali-portal`) è gestito da `RoleSwitchFilter` (`BasePortalFilter` su `/web/*`,`/group/*`, parametro `activeRoleSwitch`), NON da un servlet OSGi. Il `RoleSwitchServlet` originale è stato rimosso il 2026-06-30.

**Why:** un servlet OSGi su `/o/...` non funzionava per due motivi indipendenti:
1. Routing — `osgi.http.whiteboard.context.path` è proprietà del `ServletContextHelper`, non del servlet: messa sul servlet è ignorata. Con pattern `/*` il servlet collide sul context di default `/o` con altri servlet `/*` (es. `AttivaEmailServlet`), che vince la registrazione e serve l'URL.
2. Sessione — un servlet su `/o` ha una `HttpSession` distinta da quella del portale, quindi non vede gli attributi di sessione scritti da `LoginPostAction` (`ACTIVE_ROLE`, `HAS_DUAL_ROLE`) e il tema non vedrebbe le sue scritture. `PortalSessionContext` non risolve: è in `portal-impl`, non esportato agli OSGi (l'import non compila).

**How to apply:** per mutare la sessione del portale da codice OSGi in questo progetto, usare un `BasePortalFilter` (gira nella pipeline del portale → stessa sessione), come `PrivatePagesRedirectFilter`. L'URL di trigger lo costruisce `ActiveRoleTemplateContextContributor` via `themeDisplay.getURLHome()` + parametro. Vedi [[intro-progetto]] e la spec `spec-switch-profilo-migrazione-spid.md` (Fase A4 / Q5).
