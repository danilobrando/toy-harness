# Progress Log — Triage Bot

> Append-only. Nunca editar entradas viejas, solo agregar nuevas al final.
> Cada entrada con timestamp.

---

## 2025-10-12 17:40 — F2.3 ambiguous handling — PR #47 abierto

**Actor:** Claude (sesión implementation)

**Trabajo realizado:**

- Branch `feat/classification-ambiguous-handling` desde `origin/staging`
- Refactor en `src/services/classifier.ts:scoreConfidence`:
  - Antes: retorna `null` cuando confidence < 0.3
  - Después: retorna `{ category: "ambiguous", confidence }`
- Update del consumer `src/services/router.ts` para manejar `"ambiguous"`
  como categoría explícita
- Tests añadidos:
  - 8 unit (`classifier.test.ts`): cubren happy path + 3 edge cases del
    threshold + ambiguous output
  - 3 property (`classifier.property.test.ts`): score ∈ [0, 1] determinístico
  - 2 integration (`classifier.integration.test.ts`): DB real con seed +
    cleanup
- **Total: 23 tests verdes** (CI pasa)
- PR [#47](https://github.com/example/triage-bot/pull/47) → base `staging`

**Decisiones documentadas:**
1. `"ambiguous"` como categoría literal en lugar de `null` — ver handoff
   para alternativa rechazada (throw exception)
2. Threshold de 0.3 hardcoded por ahora; F2.4 lo va a derivar de `ticket_categories.threshold`

**Pendiente:** review humano del approach. Ver handoff
[`2025-10-12-classification-engine-handoff.md`](../handoffs/2025-10-12-classification-engine-handoff.md).

**Tiempo invertido:** ~1.5h

---

## 2025-10-08 14:20 — F2.2 classifier service skeleton landed

**Actor:** Claude (sesión implementation)

- PR #44 mergeado a `staging`
- `src/services/classifier.ts` con interfaz `classify(ticket): CategoryResult`
- 15 unit tests + 1 property test (score ∈ [0, 1]) verdes
- Verificación staging: 50 tickets de fixture procesados, 0 errors

PR #45 staging→main mergeado mismo día. F2.2 done en prod.

---

## 2025-10-02 11:15 — F2.1 schema migration aplicada

**Actor:** Claude (sesión schema)

- Migration `0012_classify_categories.sql` aplicada en staging
- 12 contract tests verdes (introspection de Drizzle)
- Hash SHA-256 registrado en `__drizzle_migrations`
- Aplicada en prod 2025-10-03 — backfill 3 categorías default (general,
  technical, billing)

---

## 2025-09-25 16:00 — F1 cerrada en prod

**Actor:** Danny + Claude

- Smoke test contra staging: 100/100 tickets procesados, latencia p95 = 1.4s
- PR #38 staging→main mergeado
- Webhook endpoint live en prod
- BullMQ workers escalando 2 réplicas

**F1 done. F2 iniciada en próxima sesión.**

---

## 2025-09-18 09:30 — F1.4 BullMQ queue integration

**Actor:** Claude (sesión implementation, continuando de 2025-09-15)

- Branch `feat/bullmq-queue` mergeado a staging
- ADR [0001](../adrs/0001-pick-async-queue.md) documenta la decisión: BullMQ
  sobre SQS y RabbitMQ
- 18 tests verdes (unit + integration con Redis test container)
- Latencia ingesta → queue: <50ms en local, <120ms en staging

---

## 2025-09-05 18:00 — F0 cerrada oficialmente

**Actor:** Danny (review interactivo)

- TypeScript strict + ESLint + Prettier configurados
- Vitest + fast-check (property tests) operativos
- Drizzle setup completo, primer migration aplicada
- Pre-commit hooks instalados (typecheck + lint + git-secrets)
- CI workflow funcional (verde en primer push)
- **Golden set inicial:** 10 tickets curados con Danny, persistidos en
  `tests/fixtures/golden-tickets.json`
- **Baseline capturado:** 3 categorías default, threshold inicial 0.3
  (puede ajustarse post-F2.3)

**F0 done. F1 iniciada inmediatamente — alta velocidad por inercia.**

---

## 2025-09-01 — F0 iniciada

**Actor:** Danny + Claude (kickoff)

- Repo creado: `github.com/example/triage-bot`
- CLAUDE.md inicial con stack + branch strategy
- `harness/` instalado (skeleton + ADAPT.md respondido)
- Plan inicial: F0..F5 (ver PLAN.md)
- Primer item: configurar TypeScript strict + Vitest
