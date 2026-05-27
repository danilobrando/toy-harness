# Current Phase — Triage Bot

| Campo | Valor |
|---|---|
| **Fase actual** | F2 — Classification engine |
| **F0 iniciada** | 2025-09-01 |
| **F0 cerrada** | 2025-09-05 |
| **F1 cerrada** | 2025-09-18 |
| **F2 iniciada** | 2025-09-20 |
| **Última actualización** | 2025-10-12 |
| **Próximo milestone** | F2.4 — Escalation rules para tickets ambiguous |
| **Handoff activo** | [`handoffs/2025-10-12-classification-engine-handoff.md`](../handoffs/2025-10-12-classification-engine-handoff.md) |

---

## Estado

F2 en curso. F2.1, F2.2, F2.3 done. F2.3 incluye refactor a retornar
`"ambiguous"` explícito en lugar de `null` (PR #47 esperando review).

WBS actualizado: [`wbs.md`](wbs.md)

### F2 — Detalle

| Sub-fase | Estado |
|---|---|
| F2.1 — Schema migrations (ticket_categories) | done |
| F2.2 — Classifier service skeleton | done |
| F2.3 — Confidence scoring + ambiguous handling | PR #47 abierto |
| F2.4 — Escalation rules | pendiente |
| F2.5 — Integration tests con DB real | pendiente |
| F2.6 — Golden set re-curated | pendiente (post-F2 stable) |

### Gate de avance a F3

- precision ≥0.85 sobre golden set de 50 tickets
- ambiguous handling con ≤5% de tickets clasificados como tal
- 0 hallucinations sobre categorías que no existen

---

## Historial de fases

| Fecha | Cambio |
|---|---|
| 2025-09-01 | F0 iniciada |
| 2025-09-05 | F0 cerrada — baselines + golden set inicial |
| 2025-09-06 | F1 iniciada — ingestion pipeline |
| 2025-09-18 | F1 cerrada — 100 tickets sample procesados sin errors |
| 2025-09-20 | F2 iniciada |
| 2025-10-12 | F2.3 PR #47 abierto |
