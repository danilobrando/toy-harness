# Toy Harness

> Un patrón de archivos versionados para trabajar con agentes IA en proyectos
> largos sin perder el contexto entre sesiones.

## El thesis en tres líneas

El agente IA no tiene memoria entre sesiones. Vos sí. Si la memoria crítica del
proyecto vive en tu cabeza, el agente se desalinea cada vez que abrís una sesión
nueva. Si vive en archivos versionados que el agente lee al despertar, las
sesiones se vuelven intercambiables y el proyecto sobrevive cambios de modelo,
de operador, de día.

## Cómo navegar este repo

- **[docs/index.html](docs/index.html)** — explicación visual con
  diagramas (HTML standalone). Si tenés GitHub Pages activado,
  abrí `https://danilobrando.github.io/toy-harness/`.
- **[docs/why.md](docs/why.md)** — leélo primero si preferís texto.
  5 minutos. Explica el problema que este patrón resuelve.
- **[skeleton/](skeleton/)** — los 3 archivos mínimos que cualquier proyecto
  puede crear hoy. NO es un template para copiar tal cual; es un punto de
  partida para escribir el tuyo.
- **[tour/session-protocol-annotated.md](tour/session-protocol-annotated.md)** —
  un solo archivo del harness anotado párrafo por párrafo, explicando por qué
  cada sección existe y qué falla si se quita. La pieza pedagógica densa de
  este repo.
- **[example-triage-bot/](example-triage-bot/)** — un proyecto sintético
  (clasificador de tickets de soporte) mostrando el harness aplicado a lo largo
  de 8 semanas. Inspectable, no instalable.
- **[ADAPT.md](ADAPT.md)** — 7 preguntas que tu equipo debe responder ANTES de
  copiar cualquier cosa de acá. Diseñado para frenar la tentación de
  clone-and-paste.
- **[docs/failure-modes.md](docs/failure-modes.md)** — lo que este patrón NO
  resuelve y dónde se cae.

## Cuándo este patrón sirve

- Proyectos largos (≥3 semanas)
- Múltiples sesiones discontinuas con el agente IA
- Decisiones técnicas que tu equipo no quiere repetir cada sesión
- Equipos donde "otro Claude" o "otra persona" puede retomar el trabajo

## Cuándo este patrón es overkill

- Scripts de un solo día
- Sesión única
- Trabajo donde el chat history alcanza
- Equipos donde una sola persona tiene todo el contexto y nunca se va a ir
  *(esto último casi nunca es cierto)*

## Origen

Construí este harness para un proyecto propio de 8 semanas con Claude Code.
Funciona para ese caso. Lo que ves acá es la versión anonimizada del patrón,
con un proyecto sintético (Triage Bot) reemplazando el dominio real.

El post que enmarca esto: [link al post de Substack — pendiente]

## Cómo leerlo en 20 minutos

1. [docs/why.md](docs/why.md) — 5 min
2. [skeleton/session-protocol.md](skeleton/session-protocol.md) — 5 min
3. [tour/session-protocol-annotated.md](tour/session-protocol-annotated.md) —
   primeras dos secciones — 5 min
4. [ADAPT.md](ADAPT.md) — 5 min

Después de eso, decidí si te interesa el resto.

## Licencia

MIT. Copialo, modificalo, vendelo si querés. La idea es que sirva.
