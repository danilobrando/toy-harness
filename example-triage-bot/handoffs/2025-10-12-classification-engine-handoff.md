# Handoff 2025-10-12 — Classification engine refactor (PR #47)

| Campo | Valor |
|---|---|
| Fecha | 2025-10-12 17:40 |
| Sesión cerrada por | Claude (continuando trabajo de sesión 2025-10-10) |
| Fase | F2.3 — Classification engine, confidence + ambiguous |
| Estado | PR #47 abierto, esperando review humano |

---

## Estado actual

PR [#47](https://github.com/example/triage-bot/pull/47) abierto contra
`staging`. CI verde. 23 tests verdes (8 unit + 3 property + 2 integration).

Espera: review humano del approach para tickets ambiguos (ver sección
"Contexto crítico").

Branch: `feat/classification-ambiguous-handling`
Commits en el branch: 4
LOC: 287 (incluye tests)

## Contexto crítico (no está en otros archivos)

Durante esta sesión descubrí que el agente clasificador retornaba `null`
cuando la confianza estaba bajo 0.3, en lugar de la categoría
`"ambiguous"`. Esto es comportamiento legacy del prototipo de F2.2.

Lo cambié a retornar explícitamente:

```typescript
{ category: "ambiguous", confidence: 0.X }
```

El operador puede tener opinión al respecto:

- **Si prefiere mantener `null`:** revierto en 2 commits. El consumer
  downstream (`router.ts`) ya tenía branch para `null === ambiguous`, así
  que mantenerlo es sin riesgo.
- **Si aprueba `"ambiguous"`:** F2.4 (escalation rules) puede usar este
  retorno directamente en lugar de chequear por `null` explícito. Más
  limpio downstream.

**Alternativa considerada y rechazada:** throw exception cuando confidence
< 0.3. Rechazada porque rompe el contrato del consumer downstream que
asume retorno síncrono sin throws. Tener tres branches (null / category /
throw) era peor que dos (category / category-ambiguous). Documentado
inline en el PR description con código de ejemplo.

**Detalle no obvio:** el threshold 0.3 sigue hardcoded en `classifier.ts`.
F2.4 lo va a mover a `ticket_categories.threshold` por categoría (algunas
categorías son más estrictas que otras). No lo refactoreé acá para mantener
el PR enfocado.

## Próximo paso (literal)

**Si el operador aprueba el PR #47 sin cambios:**
1. Mergear PR #47 a `staging`
2. Smoke test contra fixtures en `tests/fixtures/tickets/` (5 min)
3. Verificar 24h en staging (ver alertas, ver edit_rate del classifier)
4. PR de `staging` a `main`
5. Empezar F2.4 (escalation rules) en branch nuevo

**Si el operador pide cambios al approach `"ambiguous"`:**
1. Aplicar feedback en mismo branch `feat/classification-ambiguous-handling`
2. Push, esperar CI
3. Re-anunciar PR listo para nuevo review

**Si el operador prefiere mantener `null`:**
1. Revert de 2 commits del branch (commits `abc123` y `def456`)
2. Documentar la decisión en este handoff antes de cerrar
3. Mantener el resto del PR (tests, property, integration) — son útiles
   igual

## Bloqueos pendientes

Ninguno.

## Lo que NO se hizo en esta sesión (y por qué)

- **F2.4 escalation rules:** fuera de scope. Es la próxima sub-fase, depende
  de este PR mergeado.
- **Logging granular del classifier:** TODO técnico capturado como entry en
  `status/blockers.md`. No urgente, no bloquea F2.4.
- **Migration del schema `ticket_categories.threshold`:** se hará en F2.4
  cuando muevamos el threshold de código a DB. Hoy sigue como columna que
  existe pero no se usa.
- **Update del golden set:** los 10 tickets del golden set siguen siendo
  los originales de F0. Después de F2 completo, vale la pena re-curar con
  el operador (ver `failure-modes.md` punto 3 sobre golden set aging).

## Tiempo invertido en esta sesión

- Investigación del legacy behavior (`null` vs `"ambiguous"`): ~30min
- Implementación del cambio + tests: ~45min
- PR description + verificación local: ~15min
- **Total:** ~1.5h

---

## Notas para el operador

Si tenés 5 minutos antes de revisar el PR, revisá el handoff anterior
`2025-10-10-classification-skeleton.md` (no creado todavía pero referenciado
en `progress-log.md` entry del 2025-10-08). Te va a dar contexto del
approach del clasificador en general.

Si tenés menos tiempo, la decisión más importante de este PR es la del
retorno `"ambiguous"` vs `null`. Todo lo demás es ejecución estándar.
