# Adaptar este harness a tu proyecto

> Antes de copiar nada, respondé estas 7 preguntas. Si no podés responderlas,
> el harness va a quedar en tu repo como decoración, no como herramienta.

## 1. ¿Cuánto dura tu proyecto?

Si es menos de 2 semanas, probablemente no necesitás esto. El chat history
del agente alcanza. Cerrá esta pestaña, hacé el trabajo, vení después si
te empieza a doler.

## 2. ¿Cuál es la decisión técnica más cara que tomaste hace 3 sesiones?

Si no podés responderla en 30 segundos sin abrir el chat history, tu memoria
ya está fuera de tu cabeza y necesita un cuaderno. Esa decisión específica
es el primer ADR de tu repo.

## 3. ¿Cuáles son los 3-5 invariantes inviolables de tu sistema?

Ejemplos del Triage Bot: "un ticket nunca pasa de cerrado a abierto",
"categoría siempre es uno de N valores fijos", "escalation a humano nunca
se silencia".

Si no los podés enumerar, no son invariantes — son hábitos. Definilos antes
de escribir property tests.

## 4. ¿Qué pasa si te enfermás una semana?

¿Otra persona puede retomar el proyecto leyendo solo el repo? Si la respuesta
es "depende de qué tan rápido le explico por Slack", el proyecto vive en vos,
no en el código.

## 5. ¿Cuál es tu "kill switch"?

Si tu agente IA empieza a hacer algo destructivo en producción, ¿qué línea
de código lo apaga en menos de 60 segundos? Si no tenés esa línea, escribila
antes del próximo PR.

## 6. ¿Tus normas son verificables o aspiracionales?

Tomá tus reglas actuales (las que tengas, escritas o no). ¿Cuáles pasan un
test automatizado? Las que no pasan no son normas — son opiniones. No vale
la pena escribirlas en `engineering-norms.md` hasta que tengan verificación.

## 7. ¿Estás dispuesto a escribir un handoff cada vez que cierres una sesión con trabajo pendiente?

Honestamente. Si la respuesta es "depende", el harness no va a funcionar.
Es ritual o no es nada.

---

## Si respondiste las 7

Empezá por crear 3 archivos vacíos en tu proyecto:

```
your-project/
├── session-protocol.md
├── engineering-norms.md
└── handoffs/
```

Llenalos con lo que sale de las 7 preguntas. Nada más.

El resto del harness (PLAN.md, status/, ADRs, golden set, WBS) emerge cuando
lo necesités, no antes. Si lo creás todo al inicio sin un proyecto real
empujando cada pieza, vas a terminar con scaffolding decorativo.

## Si NO podés responder alguna

Esa pregunta es tu primer trabajo. No empieces con el harness hasta tener
una respuesta. El propósito del harness es proteger lo que ya sabés que
importa, no descubrirlo.
