# ADR-0001 — Async queue: BullMQ sobre SQS y RabbitMQ

| Campo | Valor |
|---|---|
| Número | 0001 |
| Fecha | 2025-09-12 |
| Status | accepted |
| Decisores | Operador humano + Claude (sesión F1.4) |
| Fase | F1 — Ingestion pipeline |

---

## Contexto

El Triage Bot recibe tickets vía webhook. Cada ticket dispara una pipeline
asíncrona: (1) parse + validación, (2) clasificación por LLM, (3)
escalation si aplica, (4) notificación al cliente.

El step de clasificación tarda 1-3 segundos por ticket (LLM call). Si se
hace inline en el webhook handler, el cliente que dispara el webhook se
bloquea, y volumen alto colapsa el endpoint.

Necesitamos una queue async entre webhook y classifier.

Volumen estimado: 500-2000 tickets/día en v1, posible 10x en 12 meses si
escalamos a más clientes. Tickets son non-FIFO (orden no importa). Cada
ticket es processable independientemente.

## Decisión

Usamos **BullMQ sobre Redis** para la queue async entre webhook y
classifier.

## Opciones consideradas

### Opción A — BullMQ sobre Redis

- **Pro:**
  - TypeScript-first, SDK maduro
  - Self-hosted, sin lock-in cloud
  - Latencia muy baja (<50ms enqueue + <100ms dequeue)
  - Dashboard incluido (Bull Board) para inspección
  - Soporta reintentos exponenciales, dead-letter queue, job priorities
- **Contra:**
  - Operamos Redis (otro componente en el stack)
  - Persistencia depende de Redis AOF config — no es transaccional
- **Esfuerzo:** bajo (1-2 días)

### Opción B — AWS SQS

- **Pro:**
  - Managed, cero operación
  - Escala "infinito" sin tuning
  - Persistencia garantizada
- **Contra:**
  - Lock-in AWS (el proyecto puede que se mueva a otro cloud)
  - Latencia mayor (~100-300ms por operación)
  - SDK menos elegante en TypeScript
  - Costo por mensaje empieza a sumarse a 10x volumen
- **Esfuerzo:** medio (2-3 días, incluye configurar IAM + dead letter)

### Opción C — RabbitMQ *(rechazada)*

- **Razón de rechazo:** overkill para nuestro caso (no necesitamos routing
  topologies, fanout exchanges, ni guarantees AMQP). Más complejidad
  operacional que BullMQ sin beneficio para este uso. Si en v2 necesitamos
  topology compleja, re-evaluamos.

## Justificación

BullMQ gana sobre SQS porque:

1. **Stack consistency:** ya usamos Redis para cache de respuestas LLM.
   Agregar BullMQ no introduce un nuevo componente.
2. **Velocidad:** latencia <50ms vs ~200ms en SQS. Para un sistema donde
   total end-to-end target es <3s, los 150ms importan.
3. **Reversible:** si volumen llega a 10x y operación se vuelve dolor, migrar
   BullMQ → SQS es trabajo lineal (la interfaz `Queue.add(jobName, data)`
   se mantiene).
4. **DX:** Bull Board nos da inspección visual gratis. SQS requiere
   CloudWatch + custom queries.

Trade-off aceptado: operamos Redis. Mitigación: usamos Redis managed
(Upstash o equivalente) en lugar de self-host puro.

## Consecuencias

### Positivas

- Webhook responde en <100ms (encola y vuelve)
- Classifier puede escalar horizontalmente (N workers consumiendo la queue)
- Dead letter queue para tickets que fallan repetidamente
- Visibilidad de estado de la queue sin construir tooling

### Negativas / trade-offs

- Dependencia operacional: Redis tiene que estar arriba o todo se para
- Si Redis pierde memoria (config incorrecta de AOF), perdemos jobs
  in-flight

### Riesgos

- Si volumen escala 50x antes que migremos a SQS, BullMQ va a empezar a
  saturar Redis (no por capacidad, por contención).
  **Mitigación:** monitorear Redis CPU + memory; trigger de migración si
  >70% sostenido por 7 días.

## Plan de implementación

- **Sub-fase:** F1.4
- **Tests requeridos:**
  - Integration test contra Redis test container
  - E2E: webhook → queue → worker → DB con cleanup
  - Property test: idempotencia del job (procesar 2x mismo job no duplica
    side effects)
- **Dependencias:** instalar `bullmq` y `ioredis`, configurar Redis URL
  en env vars

## Validación post-decisión

- **Métrica:** latencia webhook (target <100ms p95)
- **Métrica:** latencia end-to-end ticket (target <3s p95)
- **Umbral:** 0 jobs perdidos en 30 días
- **Revisar:** checkpoint 90 días post-launch (2026-01-12) o si volumen
  aumenta 10x

## Referencias

- Documentación BullMQ: https://docs.bullmq.io/
- Comparativa práctica (Lyst engineering): https://making.lyst.com/...
- PR de implementación: #36 (mergeado 2025-09-18)
