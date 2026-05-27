# Por qué este harness existe

## El problema concreto

Estás trabajando en un proyecto de 8 semanas con un agente IA. Sesión 1 va
bárbaro: discutís arquitectura, eligen un ORM, empiezan a codear. Cerrás
la pestaña. Vuelves dos días después.

Sesión 2: "¿qué ORM estábamos usando?"

Le explicás. Avanza. En sesión 4 te pregunta por el rate limiting que ya
discutieron. En sesión 8 inventa una decisión sobre el flujo de escalation
que nunca tomaron. En sesión 14 te asegura que escribió tests que no existen.

Cada sesión arranca un poco más desalineada que la anterior. El chat history
ayuda al principio, pero se vuelve ruidoso, satura el context window, y
eventualmente el agente ignora la mitad para responder con prontitud lo
que le quedó cargado en los primeros mensajes.

## El diagnóstico

El agente IA no tiene memoria entre sesiones. Esto no es opinión, es
arquitectura del modelo. Lo que pasa por el LLM cada sesión es:
1. El system prompt (más o menos estable)
2. El prompt del usuario (lo que vos escribís ahora)
3. El chat history visible (limitado por el context window)

Lo que **no** pasa por el LLM:
- Las decisiones que tomaron en sesión 2
- El razonamiento detrás del schema actual
- Los invariantes implícitos del sistema
- Qué se intentó y se descartó

Si esa información vive en tu cabeza, el agente se desalinea. Si vive en
archivos que el agente lee al despertar, no.

## El truco

El repo es la memoria a largo plazo del agente. El agente es el proceso
efímero. Cada sesión nueva, lo primero que el agente hace es leer un set
mínimo de archivos para reconstruir el contexto crítico. Cada sesión que
cierra escribe lo nuevo que descubrió o decidió.

Esto no es disciplina de senior engineer. No es metodología.

Es una respuesta arquitectónica a un bug del modelo: el contexto se va,
el archivo se queda.

## Las dos capas

Hay dos categorías de información en el harness:

**Efímera (sesión activa):**
- Lo que está pasando ahora
- Lo que el agente está pensando
- Decisiones tentativas

**Persistente (versionada en archivos):**
- Lo que está decidido
- Lo que está hecho
- Lo que el próximo agente necesita saber

La regla de oro: cuando una decisión pasa de "tentativa" a "tomada",
escribila. Cuando una sesión cierra con trabajo pendiente, escribí un
handoff. Cuando descubrís un invariante, registralo como ADR.

El agente ayuda a generar estos artefactos, pero **el operador humano es
responsable de que existan**. Es la única responsabilidad indelegable.

## Pace layering

Otra forma de ver los archivos: ordenarlos por *cuán seguido cambian*.

| Capa | Velocidad de cambio | Ejemplos |
|---|---|---|
| Principios | Casi nunca | `engineering-norms.md`, `working-agreement.md` |
| Plan | Semanal | `plan.md`, checklists |
| Estado | Por sesión | `status/current-phase.md`, `status/progress-log.md` |
| Eventos | Por sesión, append-only | `handoffs/`, `adrs/` |

Esta estructura es robada de la idea de "pace layering" de Stewart Brand
para edificios — las cosas que cambian rápido (mobiliario) están separadas
físicamente de las que cambian lento (estructura). Funciona idéntico para
sistemas vivos de documentación.

Beneficio práctico: el operador humano solo edita las capas lentas. Las
rápidas las escribe el agente al cierre de cada sesión, siguiendo un
formato fijo. Casi cero overhead humano.

## Por qué no alcanza con CLAUDE.md (o equivalente)

Los archivos auto-cargados (CLAUDE.md, .cursorrules, AGENTS.md) son útiles
para reglas estables y orientación rápida, pero tienen tres limitaciones:

1. **Se cargan en cada turn**, así que ponerle 5K tokens lo hace caro
2. **No tienen estado** — no podés decir "hoy estamos en F2.3"
3. **No versionan decisiones** — un ADR vive mejor en su propio archivo

El harness es complementario: CLAUDE.md apunta al `session-protocol.md`;
el agente lo lee al inicio; ese archivo guía la lectura del resto.

## Por qué no alcanza con Linear / Jira

Los issue trackers son ortogonales. Sirven para coordinación humana entre
equipos. No sirven para que un agente IA reconstruya contexto en 30 segundos
al abrir una sesión nueva. Archivos en el repo sí.

Si tu equipo usa Linear, mantenelo. El harness no compite — vive en otra
capa.

## Una pregunta para probarlo

> Si un Claude nuevo abriera tu repo mañana sin contexto previo, ¿cuánto
> tardaría en estar productivo?

Si la respuesta es "depende, primero tendría que explicarle yo", el proyecto
vive en tu cabeza. El harness es la respuesta a esa pregunta.
