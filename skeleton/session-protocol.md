# Session Protocol

> Lo primero que el agente lee al abrir una sesión nueva. Sin esto, no hay
> alineación. Con esto, hay continuidad sin importar el modelo, la fecha, o
> quién esté operando.

---

## Inicio de sesión

### Paso 1 — Lectura obligatoria (en este orden exacto)

1. Este archivo (`session-protocol.md`) — repaso de protocolo
2. `status/current-phase.md` — dónde estamos
3. `plan.md` — solo la sección de la fase actual + próxima fase
4. `handoffs/` — el handoff más reciente (último por fecha)
5. `engineering-norms.md` — solo si vas a tocar código

Sin este paso, todo lo que sigue está desinformado. No es opcional.

### Paso 2 — Identificar el trabajo

1. Leé `plan.md` sección fase actual
2. Identificá el primer item no marcado (`- [ ]`)
3. Si es ambiguo, leé la documentación referenciada
4. Si sigue ambiguo, preguntá al operador humano. No empieces a codear con
   intuición.

### Paso 3 — Anuncio

Antes de tocar archivos, escribí en el chat un anuncio así:

```
Sesión iniciada
- Fase actual: {nombre}
- Trabajo objetivo: {item del plan}
- Handoff previo: {fecha y resumen}
- Bloqueos vistos: {si aplica}

¿Avanzo o hay otro priority?
```

Esperá confirmación humana antes de empezar a editar archivos.

---

## Durante la sesión

- Si descubrís algo importante, append a `status/progress-log.md` con
  timestamp
- Si encontrás un bloqueo, entry en `status/blockers.md` con pregunta concreta
- Si tomás una decisión técnica no trivial, ADR nuevo en `adrs/`

Estas tres reglas son la diferencia entre que el próximo agente sepa qué pasó
y que tenga que reconstruir el contexto desde cero.

---

## Cierre de sesión

### Caso A — PR mergeado en esta sesión

1. Marcá el item en `plan.md` (`- [ ]` → `- [x]`)
2. Append a `progress-log.md` con: fecha, item completado, link al PR,
   verificación post-merge
3. Actualizá `current-phase.md` si avanzaste de sub-fase

### Caso B — PR abierto, esperando review

1. NO marques como done en `plan.md` (el item sigue `- [ ]`)
2. Escribí un handoff en `handoffs/YYYY-MM-DD-{slug}.md` con:
   - Estado actual del PR
   - Contexto crítico que no está en otros archivos (decisiones tomadas,
     alternativas descartadas con razón)
   - Próximo paso literal para la siguiente sesión
   - Bloqueos pendientes

### Caso C — Sesión bloqueada (necesita input humano)

1. Entry en `status/blockers.md` con: bloqueo, pregunta concreta, opciones
   consideradas, recomendación
2. Handoff con foco en el bloqueo

### Caso D — Sesión exploratoria sin commits

Si la sesión fue research, decisión, planning sin código nuevo:

- Append a `progress-log.md` con lo aprendido
- ADR si hubo decisiones técnicas
- No requiere handoff formal pero sí recomendable

---

## Anti-patrones explícitos

### "Solo voy a hacer un pequeño fix"

El pequeño fix también pasa por todas las verificaciones. No hay excepción.
Si parece overkill para un fix de 3 líneas, ese fix probablemente no era
de 3 líneas.

### Cerrar sesión sin handoff cuando hay trabajo pendiente

El próximo agente abre fresh, no sabe qué estaba pasando, pierde 30+ minutos
de re-discovery. Multiplicalo por las próximas N sesiones del proyecto.

### Memorizar decisiones esperando que el siguiente Claude recuerde

Claude no recuerda. Los archivos sí. Si una decisión vive solo en el chat
history, ya está perdida.

### Empezar a tocar código sin leer este archivo

Resultado típico: trabajo desalineado con decisiones previas, posibles
violaciones de norma, duplicación de esfuerzo.

---

## Cómo se actualiza este archivo

Cambios al protocolo requieren:
1. ADR justificando el cambio
2. Update este archivo
3. Append a `progress-log.md` con la razón
4. Anuncio al operador humano

Si una sección se vuelve ignorada en la práctica (operador o agente la saltan
seguido), ese es síntoma — o la sección sobra o el flujo no la soporta.
Investigar antes de quitarla.
