# PLAN — Triage Bot

| Campo | Valor |
|---|---|
| Última actualización | 2025-10-12 |
| Updated by | Claude (sesión 2025-10-12) |
| Fase actual | F2 — Classification engine (en curso) |
| Próximo milestone | F2.4 — Escalation rules |

> Esta es la fuente de verdad del avance del proyecto. Se actualiza con cada
> PR mergeado y cada cambio de fase.

---

## Resumen de fases

| Fase | Foco | Estado | Gate para avanzar |
|---|---|---|---|
| **F0 — Setup** | Infra de tests, baselines, golden set inicial | done 2025-09-05 | infra verde · baseline 3 categorías · 10 golden tickets curados |
| **F1 — Ingestion pipeline** | Webhook → DB → queue | done 2025-09-25 | 100 tickets sample procesados · latencia p95 <2s |
| **F2 — Classification engine** | Categorizar tickets + scoring de confianza | en curso | precision ≥0.85 · ambiguous ≤5% · 0 hallucinations |
| **F3 — Escalation rules** | Cuándo escalar a humano | no iniciada | 0 escalations perdidas en 7d staging · latencia escalation <60s |
| **F4 — Human handoff UI** | Vendor recibe handoff con contexto | no iniciada | UI funcional · handoff con full transcript · ack <5min |
| **F5 — Hardening** | Rollback drills + alerts + observability | no iniciada | 3 rollback scenarios · alerts <5/día · CI gate inviolable |

---

## F0 — Setup

Done 2025-09-05.

- [x] Repo creado en GitHub + CLAUDE.md inicial
- [x] TypeScript strict + ESLint + Prettier
- [x] Vitest + fast-check (property tests)
- [x] Drizzle setup + primer migration
- [x] Pre-commit hooks (typecheck + lint + git-secrets)
- [x] CI workflow funcional (.github/workflows/ci.yml)
- [x] Golden set inicial: 10 tickets curados manualmente
- [x] Baseline: 3 categorías default + threshold inicial 0.3

---

## F1 — Ingestion pipeline

Done 2025-09-25.

- [x] F1.1 — Webhook endpoint /api/v1/tickets/intake
- [x] F1.2 — Validación payload + rate limiting (100 req/min por client)
- [x] F1.3 — Persistencia en tickets table
- [x] F1.4 — BullMQ queue integration (ver ADR-0001)
- [x] F1.5 — 100 tickets sample procesados sin errors
- [x] F1.6 — Smoke test latencia p95 = 1.4s (target <2s)

---

## F2 — Classification engine

En curso.

- [x] F2.1 — Schema migrations (ticket_categories table)
- [x] F2.2 — Classifier service skeleton (15 unit tests verdes)
- [x] F2.3 — Confidence scoring + ambiguous handling (PR #47 esperando review)
- [ ] F2.4 — Escalation rules (threshold por categoría desde DB)
- [ ] F2.5 — Integration tests con DB real
- [ ] F2.6 — Golden set re-curated tras F2 stable

### Gate de avance a F3

- precision ≥0.85 sobre golden set de 50 tickets
- ambiguous handling con ≤5% de tickets clasificados como tal
- 0 hallucinations sobre categorías que no existen
- F2.4, F2.5, F2.6 done

---

## F3 — Escalation rules

No iniciada.

- [ ] F3.1 — Definir reglas: ambiguous escala auto vs queda en queue
- [ ] F3.2 — Cron escalation-monitor cada 5min
- [ ] F3.3 — Slack/email notification al human handler
- [ ] F3.4 — Tests E2E del flujo escalation
- [ ] F3.5 — Métricas: escalation_latency, escalations_per_day
- [ ] F3.6 — Dashboard básico de queue health
- [ ] F3.7 — Alertas si escalation_latency p95 >60s
- [ ] F3.8 — Documentación operacional para handlers

### Gate de avance a F4

- 0 escalations perdidas en 7 días staging
- latencia escalation p95 <60s
- F3.6 y F3.7 funcionales

---

## F4 — Human handoff UI

No iniciada.

- [ ] F4.1 — Wireframe + approval del operador humano
- [ ] F4.2 — Componente lista de tickets escalados
- [ ] F4.3 — Vista detalle con full transcript
- [ ] F4.4 — Botón ack + assign-to-self
- [ ] F4.5 — Tests E2E del flujo handler view → ack
- [ ] F4.6 — Métricas: ack_latency, ttl en queue
- [ ] F4.7 — Acceso multi-handler (no exclusivo)

### Gate de avance a F5

- UI accesible y funcional para 3 handlers de prueba
- Vendor ack en <5min (p95) durante una semana
- 0 tickets perdidos en handoff

---

## F5 — Hardening

No iniciada.

- [ ] F5.1 — Rollback drill: revert de prompt classifier (<5min)
- [ ] F5.2 — Rollback drill: schema down-migration (<10min)
- [ ] F5.3 — Rollback drill: queue purge selectivo (<5min)
- [ ] F5.4 — Eval gate inviolable en CI (golden ≥90%)
- [ ] F5.5 — Alerts calibradas + anti-fatigue cooldown
- [ ] F5.6 — Documentación runbook + post-mortem template

### Gate de declarar v1.0 ready

- 3 rollback scenarios drilleados exitosamente
- CI bloquea deploys que fallan golden gate
- Runbook + post-mortem templates publicados
- 30 días sin incidentes críticos en staging

---

## Items decididos NO entran en v1.0

Capturados durante F0-F2:
- Multi-language classification (postpuesto a v1.1)
- A/B testing entre modelos
- Real-time classification streaming
- Auto-categoría learning (sin curación humana)

Si surge necesidad real durante operación, registrar como ADR + agregar a
backlog v1.1.

---

## Update protocol

**Cuando avanzás un item:** marcá `- [ ]` → `- [x]`, actualizá header, append
a `status/progress-log.md`.

**Cuando completás una sub-fase:** verificá items marcados, si gate se
cumple marcá fase done en tabla resumen, update `current-phase.md`.

**Cuando completás una fase:** ADR del avance con métricas del gate. Regenerá
`status/wbs.md`.
