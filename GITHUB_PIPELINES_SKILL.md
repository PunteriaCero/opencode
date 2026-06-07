# GitHub Pipelines Skill - Guía de Uso

## Descripción

Se ha creado e implementado la skill **`github-pipelines`** en este workspace. Esta skill proporciona asistencia especializada para crear, validar y administrar pipelines de GitHub Actions.

## Ubicaciones

- **Global**: `/root/.config/opencode/skills/github-pipelines/SKILL.md`
- **Proyecto**: `/workspace/opencode-custom/skills/github-pipelines/SKILL.md`

## Cómo usarla

### En OpenCode TUI o CLI

Cuando necesites ayuda con GitHub Actions, simplemente puedes:

1. **Pedir que cargue la skill automáticamente**:
   ```
   Ayúdame a crear un workflow de GitHub Actions para tests
   ```
   OpenCode detectará que necesitas la skill y la cargará automáticamente.

2. **Cargar la skill explícitamente**:
   ```
   /skill github-pipelines
   ```

3. **Usar después de cargar**:
   - Crear nuevos workflows
   - Validar YAML de workflows
   - Debuggear errores
   - Optimizar pipelines
   - Usar comandos `gh workflow` y `gh run`

## Qué proporciona

### Funcionalidad

- ✅ Crear workflows de GitHub Actions desde cero
- ✅ Templates para Node.js, Python, Docker, etc.
- ✅ Validación de sintaxis YAML
- ✅ Debugging de fallos en workflows
- ✅ Mejores prácticas de CI/CD
- ✅ Configuración de secretos y variables
- ✅ Monitoreo de ejecuciones
- ✅ Referencia de comandos `gh workflow` y `gh run`

### Características principales

1. **Estructura de Workflows**: Guía sobre estructura YAML básica
2. **Triggers**: Explicación de eventos (`push`, `pull_request`, `schedule`, etc.)
3. **Runners**: Qué runners usar y cuándo
4. **Actions Comunes**: Checkout, setup-node, setup-python, etc.
5. **Templates Listos**: Para JavaScript, Python y Docker
6. **Patrones**: Condicionales, dependencias, artefactos, matrices
7. **Validación**: Cómo verificar workflows
8. **Debugging**: Solución de problemas comunes
9. **Mejores Prácticas**: Seguridad, rendimiento, documentación

## Ejemplos de uso

### Crear un workflow de tests para Node.js

```
Necesito un workflow de GitHub Actions para ejecutar tests 
en cada push a main y pull request. Usa Node.js 20.
```

### Validar un workflow existente

```
Revisa mi workflow en .github/workflows/ci.yml y sugiere mejoras
```

### Debuggear un workflow que falla

```
Mi workflow falla con error de permisos. ¿Qué cambios necesito hacer?
```

### Implementar matriz de versiones

```
Quiero testear mi app en Node.js 18, 20 y 22. Ayúdame a configurar 
una matriz en el workflow.
```

## Comparativa con `gh-cli` skill

| Aspecto | `gh-cli` | `github-pipelines` |
|--------|----------|-------------------|
| Enfoque | Operaciones generales de GitHub | Pipelines/Actions específicamente |
| Comandos gh | ✅ Todos | ✅ `workflow` y `run` enfocados |
| Templates | ❌ No | ✅ Sí (Node, Python, Docker) |
| Validación de workflows | ❌ No | ✅ Sí |
| Mejores prácticas CI/CD | ❌ No | ✅ Sí |
| Debugging | ❌ No | ✅ Sí |
| Creación de workflows | ❌ No | ✅ Sí (guía completa) |

## Comandos útiles (con `gh`)

La skill proporciona referencia completa, pero aquí hay un resumen:

```bash
# Ver workflows
gh workflow list
gh workflow view nombre-workflow

# Ejecutar workflow manualmente
gh workflow run nombre-workflow
gh workflow run nombre-workflow --ref main

# Ver ejecuciones
gh run list
gh run list --workflow tests
gh run view <run-id>

# Monitorear en vivo
gh run watch <run-id>

# Debuggear
gh run view <run-id> --verbose
```

## Próximos pasos

1. Carga la skill: `skill load github-pipelines`
2. Describe lo que necesitas: crear workflow, validar, debuggear, etc.
3. La skill te guiará con mejores prácticas y ejemplos

## Notas

- La skill está disponible globalmente y en el proyecto
- Usa `gh-cli` para operaciones generales de GitHub
- Usa `github-pipelines` para todo lo relacionado con GitHub Actions
- Ambas skills complementan el trabajo con GitHub
