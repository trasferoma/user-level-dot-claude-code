# SPEC — Collisione tra Mario e i nemici

**Obiettivo:** gestire la collisione tra Mario e un nemico: colpito dall'alto il nemico viene sconfitto, altrimenti è Mario a subire danno.

**Contesto**
- Punti del codice interessati: game loop di aggiornamento entità, classi `Player` (Mario) ed `Enemy`.
- Pattern o meccanismi esistenti da riusare: sistema di rilevamento collisioni AABB già usato per le piattaforme.
- File / moduli coinvolti: `CollisionSystem`, `Player`, `Enemy`.

**Comportamento atteso**
- Mario cade sopra un nemico → il nemico è sconfitto e Mario rimbalza.
- Mario tocca un nemico di lato o dal basso → Mario subisce danno (se è piccolo, muore).
- Mario con invincibilità attiva (stella) → il nemico è sconfitto da qualsiasi lato, senza danno a Mario.
- Invariante: le collisioni con piattaforme e oggetti restano identiche.

**Vincoli**
- Retrocompatibile: non alterare le collisioni con piattaforme/oggetti esistenti.
- Riusare il `CollisionSystem` esistente; nessuna logica di rendering dentro la logica di collisione.
- Nessuna modifica non necessaria a fisica generale, input o punteggio.
- Nessuna nuova entità o sistema se non indispensabile.

**Fuori scope**
- Animazioni e suoni di sconfitta; punteggio ed effetti; nuovi tipi di nemici; boss.

**Definition of done** — ogni criterio coperto da almeno un test
1. Mario cade sopra un nemico → nemico sconfitto, Mario rimbalza;
2. Mario tocca un nemico di lato → Mario subisce danno;
3. Mario con stella tocca un nemico → nemico sconfitto, nessun danno;
4. le collisioni con le piattaforme restano invariate;
5. nessuna modifica non richiesta ad altri sistemi.

**Esempio**
```java
// Collisione Mario–nemico rilevata dal CollisionSystem esistente (AABB).
// "dall'alto" = Mario in caduta con i piedi sopra la testa del nemico.

void onCollision(Player mario, Enemy enemy) {
    if (mario.isInvincible()) {                 // stella attiva
        enemy.defeat();
    } else if (mario.isFalling()
               && mario.bottom() <= enemy.top() + STOMP_MARGIN) {
        enemy.defeat();
        mario.bounce();
    } else {
        mario.takeDamage();                     // se piccolo → muore
    }
}
```
