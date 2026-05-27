# Handoff YYYY-MM-DD — {Slug corto}

| Campo | Valor |
|---|---|
| Fecha | YYYY-MM-DD HH:MM |
| Sesión cerrada por | {Actor — Claude / nombre del operador} |
| Fase | {ej. F2 — Classification engine} |
| Estado | {PR abierto / sesión bloqueada / sesión exploratoria} |

---

## Estado actual

{¿En qué punto exacto quedó el trabajo? Si hay PR, link + estado de CI. Si
hay un branch sin PR, mencionar branch + commits.}

## Contexto crítico (no está en otros archivos)

{Decisiones tomadas durante la sesión, alternativas consideradas y
descartadas con razón, observaciones sobre comportamiento legacy, lo que el
operador puede tener opinión al respecto.

Esta es la sección más importante del handoff. Sin esto, la próxima sesión
toma decisiones contradictorias o pregunta cosas que ya se decidieron.}

## Próximo paso (literal)

{Qué hace exactamente la próxima sesión. Sé literal — "esperar review" o
"si Danny aprueba sin cambios → mergear y empezar F2.4". No vago.}

**Si {condición A}:**
1. {paso concreto}
2. {paso concreto}

**Si {condición B}:**
1. {paso concreto}

## Bloqueos pendientes

{Lista de blockers activos, o "ninguno".}

## Lo que NO se hizo en esta sesión (y por qué)

{Explicar lo que quedó fuera de scope intencionalmente. Evita que la
próxima sesión se confunda pensando que algo falta.}

## Tiempo invertido en esta sesión

- {actividad 1}: ~Xmin
- {actividad 2}: ~Xmin
- **Total:** ~Xh

---

## Cómo usar este template

1. Copiá este archivo a `handoffs/YYYY-MM-DD-{slug}.md` con la fecha actual
2. Reemplazá los placeholders `{...}`
3. NO eliminés secciones — si una no aplica, marcá "N/A" explícitamente
4. Mantenelo corto. Un handoff de 5 minutos de lectura es ideal. De 15
   minutos significa que algo se debería haber escrito en `progress-log.md`
   o como ADR.
