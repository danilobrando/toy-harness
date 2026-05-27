# Failure modes — lo que este patrón NO resuelve

> El harness no es magia. Lo que sigue son cuatro modos de falla conocidos.
> Léelos antes de adoptarlo, no después.

## 1. Kill switch convention

**Qué falta:** no hay regla dura sobre cómo apagar al agente cuando algo va
mal en producción. Hoy es ad-hoc por proyecto.

**Cuándo importa:** si tu agente IA toca producción real (manda mensajes,
mueve dinero, actualiza estado externo), necesitás un mecanismo de pausa
verificable que tarda menos de 60 segundos en activarse. Ejemplos:
una env var `KILL_SWITCH_ENABLED=true` que cada worker chequea antes de
actuar, o un toggle en DB tipo `autonomy_config.is_active`.

**Cómo mitigar mientras tanto:** definí tu propio kill switch como primera
tarea de F0. Documentalo en `engineering-norms.md` como norma verificable.
No avances a F1 sin esto si tu proyecto es lead-facing.

## 2. Telemetría del agente mismo

**Qué falta:** medimos el output (tests verdes, métricas del producto). No
medimos al agente: cuántas sesiones requirieron rework, dónde se atascó,
qué halucinó, cuánto tardó por PR.

**Cuándo importa:** después de 4-6 semanas de uso, vas a querer saber si
el harness está funcionando. Sin métricas del proceso, solo tenés
"sensación de que va bien" o "sensación de que va mal".

**Cómo mitigar mientras tanto:** un append-only `status/agent-metrics.jsonl`
con una línea por sesión: `{session_id, phase, prs_opened, escalations, model}`.
Una vista resumen con `jq` o `awk` te da tendencia. Es 30 minutos de trabajo
y vale la pena al mes 2.

## 3. Golden set aging

**Qué falta:** los tests "que nunca pueden romperse" (golden set, conversations
golden, fixtures críticas) envejecen como leche. Si nadie los re-cura cada
N meses, terminás midiendo un sistema que ya no existe.

**Cuándo importa:** cualquier proyecto que pasa de 3 meses. El golden set
inicial fue capturado en un momento del producto que ya no es el actual.

**Cómo mitigar mientras tanto:** cada N meses (90 días por default) marcá
en el calendario una sesión de re-curación. Si el golden set lleva más de
90 días sin tocarse, asumí que está parcialmente desactualizado y verificá
caso por caso antes de confiar en el gate.

## 4. Cuándo el harness es overkill

**Qué falla:** aplicar este patrón a proyectos chicos genera overhead sin
beneficio. Escribir un handoff de 2 páginas para terminar un script de
una tarde es ridículo.

**Cuándo importa:** proyectos de menos de 2 semanas, sesión única, scripts
one-shot, exploraciones que probablemente se van a botar.

**Cómo decidir:** una sola pregunta — ¿la próxima sesión la vas a abrir vos
mañana mismo, sin notas? Si sí, no necesitás esto. Si la próxima sesión es
en 5 días, o la abre otra persona, o el modelo va a haber cambiado, sí.

## 5. (Bonus) Drift entre proyectos

**Qué falta:** si usás el harness en N proyectos paralelos, las versiones
de los archivos canónicos (`session-protocol.md`, `engineering-norms.md`)
van a divergir naturalmente. Vas a editar uno a las 2am, otro a las 11am
del lunes, y en 6 meses tenés N versiones inconsistentes.

**Cuándo importa:** segundo proyecto en adelante.

**Cómo mitigar:** una sola fuente de verdad para los archivos estables.
Pueden vivir en un repo compartido referenciado por symlink, o en una carpeta
`~/.harness/v1/` con un `.harness-version` por proyecto que apunta al SHA.
No lo armes hasta que tengas tres proyectos vivos — es overhead prematuro
antes.
