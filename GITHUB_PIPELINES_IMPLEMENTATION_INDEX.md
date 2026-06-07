# GitHub Pipelines Skill - Índice de Implementación

## 📋 Resumen

Se ha creado e implementado exitosamente la skill **`github-pipelines`** en el workspace de OpenCode. Esta skill proporciona asistencia especializada para crear, validar y administrar pipelines de GitHub Actions.

## 📁 Archivos Creados

### Skill Implementation

| Ruta | Descripción |
|------|------------|
| `/root/.config/opencode/skills/github-pipelines/SKILL.md` | Skill global (accesible desde cualquier proyecto) |
| `/workspace/opencode-custom/skills/github-pipelines/SKILL.md` | Skill del proyecto (directorio skills) |

### Documentación

| Archivo | Descripción |
|---------|-------------|
| `GITHUB_PIPELINES_SKILL.md` | Guía completa de la skill con características y ejemplos |
| `GITHUB_PIPELINES_QUICKSTART.md` | Inicio rápido con tareas comunes |
| `GITHUB_PIPELINES_IMPLEMENTATION_INDEX.md` | Este archivo (índice) |

## 🎯 Contenido de la Skill

### Secciones Principales (423 líneas)

1. **What I do** - Descripción de funcionalidades
2. **When to use me** - Casos de uso
3. **GitHub Actions Basics**
   - Estructura de archivos
   - Triggers comunes
   - Runners disponibles
   - Actions frecuentes

4. **Basic Workflow Templates**
   - Node.js / JavaScript
   - Python
   - Docker Build & Push

5. **Secrets & Variables**
   - Configuración de secretos
   - Variables integradas
   - Matriz de estrategias

6. **Common Patterns**
   - Condicionales
   - Dependencias entre jobs
   - Artefactos

7. **Validation & Debugging**
   - Comandos `gh workflow`
   - Monitoreo de ejecuciones
   - Validación YAML

8. **Best Practices** (8 recomendaciones)
   - Versionado de actions
   - Legibilidad
   - Rendimiento
   - Seguridad
   - Manejo de errores
   - Documentación

9. **Common Issues & Solutions**
   - Archivo no encontrado
   - Workflow no dispara
   - Errores de permiso
   - Workflow lento

10. **Workflow Composition**
    - Workflows reutilizables

11. **Resources**
    - Links a documentación oficial

## 🚀 Cómo Usar

### Opción 1: Carga Explícita
```bash
skill load github-pipelines
```

### Opción 2: Carga Automática
Simplemente describe lo que necesitas relacionado con GitHub Actions, y OpenCode cargará la skill automáticamente.

### Ejemplos de Uso

```
# Crear workflow
"Crea un workflow de GitHub Actions para ejecutar tests con Node.js 20"

# Validar
"Revisa mi workflow y sugiere mejoras"

# Debuggear
"Mi workflow falla con error de permisos, ayúdame"

# Optimizar
"¿Cómo puedo hacer mi workflow más rápido?"

# Matrices
"Quiero testear en Node 18, 20 y 22"
```

## ✅ Validaciones Pasadas

- ✓ Nombre válido: `github-pipelines` (regex compliant)
- ✓ Archivo correcto: `SKILL.md` en mayúsculas
- ✓ Ubicaciones válidas: Global y Proyecto
- ✓ Frontmatter YAML: Válido
- ✓ Campos requeridos: `name` y `description`
- ✓ Metadatos: audience y workflow
- ✓ Contenido: 423 líneas, 12KB
- ✓ Formato Markdown: Válido con ejemplos de código
- ✓ Compatibilidad: OpenCode

## 📊 Comparativa: Skills Disponibles

| Skill | Propósito | Workflows | Crear Pipelines | Templates |
|-------|----------|-----------|-----------------|-----------|
| `gh-cli` | General GitHub | ✓ (básico) | ✗ | ✗ |
| **`github-pipelines`** | **GitHub Actions** | **✓ (avanzado)** | **✓** | **✓** |
| `github-ops` | Push/Git ops | ✗ | ✗ | ✗ |

## 🔧 Comandos de Referencia

```bash
# Ver workflows
gh workflow list
gh workflow view <nombre>

# Ejecutar manualmente
gh workflow run <nombre>
gh workflow run <nombre> --ref main

# Monitorear
gh run list
gh run watch <id>
gh run view <id> --verbose

# Debugging
gh run download <id>
gh run rerun <id>
```

## 📚 Recursos Incluidos

1. **4 Templates Completos**
   - Node.js/JavaScript (npm)
   - Python (pytest)
   - Docker (buildx)
   - Workflow reutilizable

2. **Patrones de Ejemplo**
   - Condicionales: ejecución selectiva
   - Dependencias: jobs secuenciales
   - Matrices: testing en múltiples versiones
   - Artefactos: upload/download

3. **Guía de Seguridad**
   - Manejo de secretos
   - Permisos correctos
   - Variables de entorno

4. **Solución de Problemas**
   - 4 problemas comunes con soluciones
   - Tips de debugging
   - Mejores prácticas

## 🎓 Casos de Uso Soportados

- ✅ Crear workflow de tests (Node, Python, etc.)
- ✅ Crear workflow de build/deploy
- ✅ Crear workflow de Docker
- ✅ Validar sintaxis YAML
- ✅ Debuggear fallos
- ✅ Optimizar rendimiento
- ✅ Configurar secretos
- ✅ Entender triggers y eventos
- ✅ Usar comandos gh
- ✅ Implementar mejores prácticas

## 📖 Documentación Adicional

En el proyecto se han incluido dos archivos de referencia rápida:

1. **GITHUB_PIPELINES_SKILL.md**
   - Descripción completa de la skill
   - Qué proporciona
   - Cómo usarla
   - Comparativa con otras skills

2. **GITHUB_PIPELINES_QUICKSTART.md**
   - Inicio rápido
   - Tareas comunes
   - Comandos útiles
   - Tabla de referencia

## ⚙️ Integración con OpenCode

La skill se integra automáticamente con:

1. **Skill Tool**: Disponible a través del comando `skill`
2. **Auto-detection**: Carga automática cuando se detecta contexto de GitHub Actions
3. **Context**: Usa información del repositorio actual
4. **gh CLI**: Integración completa con GitHub CLI

## 🎯 Próximos Pasos

1. Usar la skill: `skill load github-pipelines`
2. Describe tu necesidad con GitHub Actions
3. Recibe asistencia especializada con templates y mejores prácticas
4. Implementa tu pipeline con confianza

## 📝 Notas

- La skill está disponible globalmente (todos los proyectos)
- También está disponible localmente en este proyecto
- Compatible con todas las versiones de OpenCode
- Requiere `gh` CLI configurado (que ya está en este workspace)
- Complementa `gh-cli` skill para operaciones generales de GitHub

---

**Estado**: ✅ Completado e Implementado

**Fecha**: Junio 2026

**Versión**: 1.0

**Autor**: OpenCode Agent

---

*Para más información, consulta los archivos de documentación incluidos.*
