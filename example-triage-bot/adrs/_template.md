# ADR-NNNN — {Título corto y descriptivo}

| Campo | Valor |
|---|---|
| Número | NNNN |
| Fecha | YYYY-MM-DD |
| Status | proposed / accepted / rejected / superseded by ADR-XXXX |
| Decisores | Operador humano / Agente IA (sesión X) |
| Fase | F0 / F1 / ... / N/A |

---

## Contexto

{¿Cuál es el problema, situación, o gap que motiva esta decisión? Sé
específico — incluí links a documentación, código, métricas observadas.}

## Decisión

{La decisión tomada, en presente: "Usamos X para Y porque Z."}

## Opciones consideradas

### Opción A — {Nombre}

- **Pro:** {beneficio 1, 2}
- **Contra:** {costo 1, 2}
- **Esfuerzo:** {bajo / medio / alto}

### Opción B — {Nombre}

- **Pro:** ...
- **Contra:** ...

### Opción C — {Nombre} *(rechazada)*

- **Razón de rechazo:** {por qué no}

## Justificación

{Por qué esta opción gana sobre las otras. Específico, no genérico.}

## Consecuencias

### Positivas

- {ej. Resolvemos gap X}
- {ej. Reduce complejidad de mantenimiento}

### Negativas / trade-offs

- {ej. Agregamos dependencia X}
- {ej. Curva de aprendizaje para nuevo contributor}

### Riesgos

- {ej. Si Y cambia, esta decisión necesita revisión}

## Plan de implementación

- Sub-fase: {ej. F1.2}
- Tests requeridos: {lista}
- ADR relacionados: {ADR-XXXX si aplica}

## Validación post-decisión

{Cómo sabremos que esta decisión fue correcta. Métrica + umbral + cuándo
revisar.}

- Métrica: {ej. latencia p95 < 200ms}
- Umbral: {ej. 0 errors en 14 días}
- Revisar: {ej. checkpoint 30 días post-implementación}

## Referencias

- Documentación: {links}
- PR(s) relacionados: {links}
- Discusión: {dónde se discutió, si aplica}
