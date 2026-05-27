# Engineering Norms

> Estas normas son verificables, no aspiracionales. Cada una se puede chequear
> por test, lint, o CI. Si una norma no se puede verificar automáticamente,
> no es norma — es opinión.

El criterio para incluir una norma acá: tiene que existir un comando concreto
(o un test) que devuelva pass/fail. "Buen código" no es verificable. "Cero
errores de typechecker" sí.

---

## 1. Type safety estricto

- **Regla:** typechecker pasa sin errores antes de PR
- **Verificación:** pre-commit hook + CI gate
- **Excepción:** ninguna sin ADR. Si aparece un `as any` o un `@ts-ignore`,
  ADR justificando.

## 2. Tests para todo cambio

- **Regla:** ningún PR sin test relevante. Si el cambio no es testeable,
  repensar el diseño.
- **Verificación:** CI requiere tests en archivos modificados. PR description
  tiene sección "test plan" llena.
- **Excepción:** documentación pura (markdown), renaming sin cambio de
  comportamiento.

## 3. PRs pequeños y enfocados

- **Regla:** máximo 500 LOC por PR (incluye tests). Un entregable por PR.
- **Verificación:** CI flag con warning si excede. Override requiere ADR.
- **Excepción:** schema migrations (pueden ser >500 LOC inherentemente).

## 4. Cero secretos hardcoded

- **Regla:** no hay credenciales, tokens o API keys en código
- **Verificación:** `git-secrets` pre-commit hook
- **Excepción:** ninguna.

## 5. Inmutabilidad por default

- **Regla:** `const` siempre, `let` solo cuando reasignación es esencial.
  Tratamiento inmutable para objetos y arrays.
- **Verificación:** eslint `prefer-const`, `no-param-reassign`
- **Excepción:** ninguna sin justificación inline.

## 6. Logging estructurado

- **Regla:** cada log tiene contexto estructurado, no strings concatenados.
  Producción no escribe `debug`. Nunca `console.error` — usar logger.
- **Verificación:** lint regla `no-console`
- **Excepción:** scripts CLI standalone.

## 7. Tests para invariantes del sistema

- **Regla:** todo invariante de negocio está protegido por al menos un
  property-based test
- **Verificación:** suite obligatoria en CI
- **Ejemplos de invariantes:** state machine forward-only, score ∈ [0, 1],
  migration idempotente, operación atómica.

## 8. Migrations versionadas y reproducibles

- **Regla:** schema changes via migration files versionados. Aplicado en
  staging antes de prod. SQL crudo manual se registra con hash SHA-256.
- **Verificación:** migration manifest registrado en DB
- **Excepción:** migrations de datos (no schema) pueden ser SQL crudo si la
  operación es one-time documentada.

## 9. Output user-facing validado

- **Regla:** todo texto que llega a un usuario externo pasa por un validator
  antes de enviarse. Si validación falla, NO se envía y se alerta.
- **Verificación:** tests con inputs maliciosos pasan. Validator se ejecuta
  en path crítico, validable por integration test.
- **Excepción:** ninguna en flujo autónomo. Bypass solo en flujo human-in-the-loop
  con flag explícito.

## 10. Conocimiento crítico en archivos

- **Regla:** decisiones técnicas no triviales viven en ADRs versionados,
  no en chat history ni en memoria humana
- **Verificación:** code review checklist. PR description referencia ADR si
  la decisión afecta múltiples archivos o contradice una norma anterior.

---

## Cómo se aplican

- Pre-commit hook valida 1, 4, 5, 6
- CI valida 1, 2, 3, 7, 8, 9
- Code review valida 2, 3, 10
- Property test suite (parte de CI) valida 7

## Cómo se actualiza este documento

Cambios a las normas requieren:
1. ADR justificando
2. Update este archivo
3. Append a `progress-log.md`
4. Si una norma se relaja con excepción, documentar por qué

Si una norma deja de aplicarse en la práctica (PRs la ignoran y nadie marca
en review), ese es síntoma. Investigar antes de quitarla.
