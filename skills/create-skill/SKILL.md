---
name: create-skill
description: Create OpenCode agent skills following the official SKILL.md format and placement conventions
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: skill-authoring
---

## What I do

Guide the creation of OpenCode agent skills following the official specification at https://opencode.ai/docs/skills/

## Placement

Skills go in one folder per skill name with a `SKILL.md` file inside:

- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Project: `.opencode/skills/<name>/SKILL.md`
- Claude-compatible (global): `~/.claude/skills/<name>/SKILL.md`
- Agent-compatible (global): `~/.agents/skills/<name>/SKILL.md`

## Required SKILL.md format

Every `SKILL.md` must begin with YAML frontmatter:

```markdown
---
name: <skill-name>
description: <1-1024 char description>
license: MIT
compatibility: opencode
metadata:
  key: value
---

## What I do
- Bullet points describing what the skill provides

## When to use me
Describe when the agent should load this skill.
```

## Name validation rules

- 1–64 characters
- Lowercase alphanumeric with single hyphen separators
- Cannot start or end with `-`
- No consecutive `--`
- Must match the directory name
- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

## Frontmatter fields

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | Must match directory name |
| `description` | Yes | 1–1024 characters |
| `license` | No | e.g. MIT |
| `compatibility` | No | e.g. opencode |
| `metadata` | No | string-to-string map |

## Workflow

1. Determine the skill name (validate against naming rules)
2. Create directory: `~/.config/opencode/skills/<name>/` (global) or `.opencode/skills/<name>/` (project)
3. Write `SKILL.md` with valid frontmatter + content
4. Verify the skill appears in the `skill` tool description

## Troubleshooting

- `SKILL.md` must be in ALL CAPS
- Frontmatter must include `name` and `description`
- Skill names must be unique across all locations
- Skills with `deny` permission are hidden from agents
