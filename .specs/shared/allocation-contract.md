# Allocation Contract

## Purpose

Allocation defines ownership before delegation or execution.

Allocation operates at three levels:
1. **Global allocation** — change, wave, or phase ownership
2. **Local allocation** — task or todo ownership  
3. **Specialist allocation** — delegated expert contribution

## Allocation Types & Scope

| Type | Scope | Authority | Applies To |
| --- | --- | --- | --- |
| Global | change, wave, phase | Coordinator | Strategic work |
| Local | task, todo | Task owner | Executable work |
| Specialist | bounded contribution | Specialist agent | Domain-specific help |

## Required Fields (All Allocations)

Every allocation must include:

- owner
- scope boundary
- allowed files or data  
- forbidden scope
- context bundle
- evidence required
- verification responsibility
- rollback responsibility

## Precedence & Hierarchy

```text
Global Allocation
  └── Local Allocation
      └── Specialist Allocation (if needed)
      └── Todo Execution
```

Lower levels may **narrow** scope. They **must not** broaden ownership, allowed files, data access, or authority without explicit user confirmation or a new accepted allocation.

---

# Global Allocation

## Purpose

Global allocation defines change, wave, or phase ownership before local tasks are generated.

## Scope

Global allocation constrains:
- The entire change or wave
- All local tasks within that change/wave
- All specialists involved
- Primary validation strategy

## Required Fields (Global)

- **change or wave id** — Unique identifier
- **owner coordinator** — Who is in charge (altitude-execution, data-engineer, etc.)
- **phase** — Current phase (Intent, Structure, Plan, Execution, Validate, Ship)
- **scope boundary** — What is IN vs OUT
- **artifact authority** — Which documents govern (PRD, ADR, TEST-SPEC)
- **allowed paths** — Which directories/files can be modified
- **forbidden paths** — Hard barriers (e.g., `.git/`, `node_modules/`)
- **validation posture** — How strict validation must be
- **escalation owner** — Who to ask when blocked

## Optional Fields (Global)

- related PRD
- related ADR
- related TEST-SPEC
- source authority
- risk class
- rollback owner

## Broadening Rule

A local task **broadens** global allocation when it adds:

- new directories outside allowed paths
- new data sources
- new runtime or security-sensitive behavior
- new stakeholder-facing behavior
- new validation burden not represented in the wave

**Action:** When broadening is needed, return to Design/Plan or ask the user to approve the allocation change before execution.

---

# Local Allocation

## Purpose

Local allocation defines ownership for one task or todo.

Local allocation must fit within the parent global allocation scope.

## Scope

Local allocation constrains:
- One specific task or todo
- Execution boundary for that task
- Specialist support (if any)
- Verification method
- Evidence format

## Required Fields (Local)

- **task id or todo id** — Which task/todo this applies to
- **owner** — Who executes or owns this task
- **deliverable** — What the task must produce
- **allowed files** — Specific files the task can touch
- **forbidden scope** — What this task cannot do
- **verification command or manual check** — How to validate
- **evidence required** — What proof is needed

## Optional Fields (Local)

- specialist support (name + reason)
- related PRD requirement (requirement id)
- related ADR decision (decision id)
- related TEST-SPEC scenario (scenario id)
- risk class (low, medium, high, critical)
- rollback step (if risky)

## Todo Rule

Every operational todo must include a `verify:` clause. Todos without verification are planning notes, not executable work.

Example:
```yaml
- task_id: T-42
  owner: altitude-execution
  action: "Create schema migration for orders table"
  verify: "Migration runs without errors; rollback succeeds; row counts match"
  evidence: "Migration execution log + before/after counts"
```

## Execution Rule

Local allocation is executable **only** when:

- the global allocation exists or the task is explicitly standalone
- allowed files and forbidden scope are **both** present
- verification is concrete (not "looks good")
- evidence can be recorded (not just chat memory)
- any specialist support has a reason and stop condition
- any specialist support has a grounding bundle and evidence contract

## Stop Conditions (Local)

Stop execution and escalate when:

- task requires files outside allowed scope
- verification command cannot run and no manual substitute is named
- evidence would rely only on chat memory
- specialist support would become the real owner instead of bounded help
- specialist support is requested before local allocation is complete

---

# Allocation Precedence & Invalid States

## Precedence Rules

When rules appear to conflict, apply this order:

1. Explicit user instruction (current turn)
2. Local task allocation
3. Wave allocation
4. Phase allocation
5. Change-level global allocation
6. Repository default allocation
7. Coordinator default behavior

A local allocation may narrow global allocation without additional approval.

A local allocation must not broaden global allocation without explicit approval.

### Safe Narrowing Example

```text
Global allowed:   docs/, .specs/shared/, agents/
Local allowed:    docs/HARNESS_V3_COORDINATOR_CONTRACT.md
✅ SAFE — local scope is subset of global
```

### Unsafe Broadening Example

```text
Global allowed:   docs/
Local tries:      plugins/specs-state.ts
❌ UNSAFE — local scope exceeds global allowed
→ STOP: Ask user for approval
```

## Invalid Allocation States

Do not execute if:

- specialist invoked without local allocation
- local task broadens global allocation
- todo lacks a `verify:` clause
- execution has allowed files but no forbidden scope
- evidence required is missing or unverifiable
- rollback owner is missing for risky changes
- allowed files and forbidden scope do not match (e.g., `allowed: **/` with `forbidden: (none)`)

## Task-Spec Mapping

When a Task-Spec leaf task is created, it must inherit:

- global allocation id or change id
- local task owner
- allowed files
- forbidden scope
- context bundle
- evidence required
- verification command or manual check
- rollback responsibility

Task-Spec may add implementation detail, but it must **not** override allocation authority.

---

# Delegation Rule

**Definition:** Delegation is a subset of allocation. Specialists do not become hidden owners.

No specialist may be invoked without:

- reason (why this specialist?)
- scope (allowed + forbidden)
- evidence expectation (what proof?)
- stop condition (when to stop and replan?)

Specialists are **bounded help**, not **replacement owners**.

