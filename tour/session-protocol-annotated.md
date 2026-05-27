# Tour: Session Protocol, anotado

> Este archivo toma [`skeleton/session-protocol.md`](../skeleton/session-protocol.md)
> sección por sección y explica por qué cada parte existe y qué falla si la
> quitás. Si solo vas a leer un archivo de este repo, leé este.
>
> Cada sección tiene tres preguntas:
> 1. ¿Por qué esto está acá?
> 2. ¿Qué falla si lo saco?
> 3. ¿Cuándo este consejo NO aplica?

---

## Sección: Paso 1 — Lectura obligatoria

```
1. Este archivo (`session-protocol.md`) — repaso de protocolo
2. `status/current-phase.md` — dónde estamos
3. `plan.md` — solo la sección de la fase actual + próxima fase
4. `handoffs/` — el handoff más reciente (último por fecha)
5. `engineering-norms.md` — solo si vas a tocar código
```

### Por qué esto está acá

El agente IA llega frío a cada sesión. No recuerda nada. La única forma de
que la sesión nueva no contradiga decisiones de la sesión pasada es que el
agente *re-lea* el estado actual antes de hacer nada.

El orden importa. Si lee primero `engineering-norms.md` y después
`current-phase.md`, va a tener opiniones técnicas antes de saber qué problema
está resolviendo. Si lee `plan.md` antes que `current-phase.md`, va a
empezar a planear sin saber dónde quedó el trabajo.

El orden refleja la pirámide de necesidades: protocolo (cómo trabajamos) →
estado (dónde estamos) → plan (qué sigue) → handoff (qué encontró el último)
→ normas (cómo escribir el código que sigue).

### Qué falla si lo saco

Sin este paso, cada sesión arranca con el chat history como única fuente de
contexto. Eso funciona la primera vez, mal la cuarta vez, y a la décima vez
el agente ya está inventando decisiones que nadie tomó. Es el modo de falla
más común en proyectos largos con agentes IA.

Verificable: en proyectos sin protocolo, contá cuántas veces en un mes
escribiste algo como "ya habíamos decidido X" en el chat. Ese conteo es el
costo de no tener este paso.

### Cuándo no aplica

- Sesiones de menos de 30 minutos donde la tarea ya tiene scope cerrado
- Trabajo de exploración pura donde no hay "estado" todavía
- Hotfix urgente donde el contexto es la alerta que disparó la sesión

En esos casos, mencionar explícitamente en el chat "salto el protocolo
porque X" — para que quede registro de la excepción.

---

## Sección: Paso 2 — Identificar el trabajo

```
1. Leé plan.md sección fase actual
2. Identificá el primer item no marcado (- [ ])
3. Si es ambiguo, leé la documentación referenciada
4. Si sigue ambiguo, preguntá al operador humano. No empieces a codear con
   intuición.
```

### Por qué esto está acá

El agente IA tiene tendencia a "ser útil rápido". Si no encuentra una tarea
clara, va a inventar una que suene plausible. Eso casi siempre resulta en
trabajo que no entra en la fase actual, que se solapa con algo que ya está
hecho, o que avanza por un lado que el operador no priorizó.

El paso 4 es el más importante del protocolo entero. "Preguntá al operador
humano antes de codear con intuición" es la diferencia entre un agente útil
y un agente que te genera deuda técnica más rápido de lo que la podés
revisar.

### Qué falla si lo saco

Sin esto, el agente trabaja en lo que parece más urgente o más interesante,
no en lo que la fase actual requiere. Resultado típico al cabo de 4 semanas:
hay tres ramas paralelas en distintas fases del plan, ninguna completa, y
una sola persona (la que estuvo en cada sesión) entiende cómo conectarlas.

### Cuándo no aplica

Cuando el plan está vacío o la fase recién empieza. En ese caso el primer
trabajo del agente es proponer el plan, no ejecutar uno.

---

## Sección: Paso 3 — Anuncio

```
Sesión iniciada
- Fase actual: {nombre}
- Trabajo objetivo: {item del plan}
- Handoff previo: {fecha y resumen}
- Bloqueos vistos: {si aplica}

¿Avanzo o hay otro priority?
```

### Por qué esto está acá

Tres razones, en orden de importancia:

**Primera razón — verificación de contexto.** Si el agente leyó mal o se
salteó algo del paso 1, el anuncio lo expone. El operador humano ve "fase
F1.2" cuando en realidad estaban en F2.3, y corta antes de que el agente
empiece a editar.

**Segunda razón — alineación de prioridad.** A veces el operador cambió de
opinión desde el último handoff. El anuncio le da la chance de redirigir
sin tener que interrumpir 20 minutos después.

**Tercera razón — registro.** El chat del anuncio queda como timestamp de
inicio de sesión, útil para reconstruir histórico cuando el `progress-log.md`
no fue actualizado a tiempo.

### Qué falla si lo saco

El operador tiene que confiar ciegamente en que el agente entendió bien.
La mayoría de las veces sí entendió. La vez que no entendió cuesta una
sesión entera de trabajo equivocado.

### Cuándo no aplica

Sesiones donde el operador está presente todo el tiempo y dictó el trabajo
directamente. En ese caso el anuncio es redundante.

---

## Sección: Durante la sesión

```
- Si descubrís algo importante, append a status/progress-log.md
- Si encontrás un bloqueo, entry en status/blockers.md
- Si tomás una decisión técnica no trivial, ADR nuevo en adrs/
```

### Por qué esto está acá

La memoria del agente termina cuando cierra la sesión. Si descubrió algo
relevante (un comportamiento legacy, una pista de bug, una alternativa
descartada), eso tiene que escribirse antes del cierre o se pierde.

Tres archivos distintos porque tienen vida distinta:
- `progress-log.md` — append-only, narrativa de qué pasó
- `blockers.md` — entries que se mueven a "Resueltos" cuando se resuelven
- `adrs/` — inmutable, una decisión por archivo

### Qué falla si lo saco

El descubrimiento se pierde. Cuando el próximo agente se encuentra con el
mismo comportamiento legacy en sesión 8, lo "descubre" de nuevo y pierde
una hora. Y otra vez en sesión 12. Repetido N veces.

### Cuándo no aplica

Si la sesión fue mecánica (refactor de naming, formatting, etc.) sin
descubrimientos ni decisiones, no hace falta escribir nada nuevo. Lo cual
es señal de que la sesión fue trivial — válida pero rara.

---

## Sección: Cierre de sesión — Caso B (PR esperando review)

```
1. NO marques como done en plan.md (el item sigue - [ ])
2. Escribí un handoff en handoffs/YYYY-MM-DD-{slug}.md con:
   - Estado actual del PR
   - Contexto crítico que no está en otros archivos
   - Próximo paso literal para la siguiente sesión
   - Bloqueos pendientes
```

### Por qué esto está acá

Caso B es el caso más común en la práctica. La sesión empieza, avanza, no
alcanza a mergear porque CI tarda, o porque hay que esperar revisión humana,
o porque se acabó el tiempo. Si no hay handoff, la próxima sesión arranca
ciega.

"Contexto crítico que no está en otros archivos" es la parte de oro del
handoff. Son las decisiones tomadas durante la sesión que todavía no son
ADRs (porque no son tan formales), pero que la próxima sesión necesita
para no contradecirlas. Ejemplo concreto: "implementé X de forma Y porque
Z. Alternativa W considerada y descartada por...".

### Qué falla si lo saco

La próxima sesión abre el PR, ve los cambios, no entiende por qué cierta
elección se hizo, y o bien la cuestiona innecesariamente o la mantiene sin
entender por qué — ambos malos.

### Cuándo no aplica

Si el PR es de 1 commit con un cambio obvio, el PR description ya cumple
función de handoff. Pero raramente es así.

---

## Sección: Anti-patrón — "Solo voy a hacer un pequeño fix"

### Por qué esto está acá

El anti-patrón más común en proyectos con agentes IA es la excepción
auto-permitida. "Solo voy a hacer un pequeño cambio" → no escribo test →
no escribo handoff → no actualizo plan.

Tres semanas después, hay 14 "pequeños cambios" sin trazabilidad, y nadie
recuerda cuál fue cuál.

### Qué falla si lo saco

Erosión gradual del harness. Los handoffs se vuelven opcionales, después
infrecuentes, después inexistentes. El sistema vuelve a "memoria en la
cabeza del operador".

### Cuándo no aplica

Nunca. Si un fix es realmente trivial (typo en un comentario, por ejemplo),
no necesitás invocar el protocolo entero — pero tampoco lo llames "fix",
llamalo lo que es. La excepción tiene que ser nombrada.

---

## Por qué este archivo es el tour, no la documentación principal

La documentación principal te dice qué hacer. El tour te explica por qué.

Si solo lees `skeleton/session-protocol.md`, vas a poder seguir las reglas.
Si lees este archivo, vas a saber cuándo romperlas.

Esa diferencia es la que distingue un protocolo aplicado mecánicamente de
un protocolo internalizado.

---

## Para continuar

Después de este tour, los próximos archivos que vale la pena leer en el
mismo nivel de profundidad son:

- [`skeleton/engineering-norms.md`](../skeleton/engineering-norms.md) — las
  10 normas verificables, con el mismo patrón "por qué / qué falla / cuándo
  no aplica"
- [`example-triage-bot/`](../example-triage-bot/) — el harness aplicado a un
  proyecto sintético de 8 semanas
- [`docs/failure-modes.md`](../docs/failure-modes.md) — lo que el harness
  todavía no resuelve bien
