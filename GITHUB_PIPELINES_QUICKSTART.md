# Quick Start - GitHub Pipelines Skill

## 🚀 Inicio Rápido

### Cargar la skill en OpenCode

```bash
# Opción 1: Cargar explícitamente
skill load github-pipelines

# Opción 2: OpenCode la cargará automáticamente cuando la necesites
```

## 📋 Tareas Comunes

### 1. Crear un workflow de tests para Node.js

```
Crea un workflow de GitHub Actions que ejecute:
- npm ci
- npm run lint
- npm test
- npm run build

Se debe ejecutar en cada push a main y pull request a main.
```

### 2. Crear un workflow de Docker

```
Necesito un workflow que construya y publique una imagen Docker
a registryl cuando hay push a main. Usa buildx para mejor rendimiento.
```

### 3. Validar un workflow existente

```
Revisa mi workflow en .github/workflows/main.yml
¿Hay problemas de seguridad, rendimiento o best practices?
```

### 4. Debuggear workflow que falla

```
Mi workflow falla con "permission denied". ¿Qué cambios 
necesito en permisos o secretos?
```

### 5. Agregar matriz de versiones

```
Quiero que mi workflow teste en Node 18, 20 y 22, 
tanto en ubuntu como en windows. Usa matriz.
```

## 🔍 Comandos Útiles

```bash
# Ver workflows disponibles
gh workflow list

# Ver detalles de un workflow
gh workflow view nombre-workflow

# Ejecutar workflow manualmente
gh workflow run nombre-workflow

# Monitorear ejecuciones
gh run list
gh run watch <id>

# Debuggear ejecución
gh run view <id> --verbose
```

## 📚 Contenido de la Skill

La skill incluye:

- **Fundamentos**: Estructura YAML, triggers, runners
- **Actions**: Setup Node, Python, Docker, upload/download artifacts
- **Templates**: 4 templates completos listos para usar
- **Patrones**: Condicionales, dependencias entre jobs, matrices
- **Seguridad**: Manejo de secrets y variables
- **Debugging**: Solución de problemas comunes
- **Best Practices**: 8 recomendaciones clave

## ⚡ Casos de Uso

| Caso | Comando |
|------|---------|
| Crear workflow | "Crea workflow de tests para Node.js" |
| Validar YAML | "Revisa mi workflow y sugiere mejoras" |
| Debuggear fallo | "Por qué falla mi workflow con permiso denegado?" |
| Optimizar | "Cómo hacer mi workflow más rápido?" |
| Template específico | "Necesito workflow de Python con pytest" |

## 📖 Referencias

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

---

**Skill Status**: ✅ Implementada y lista para usar

**Versión**: 1.0

**Última actualización**: Junio 2026
