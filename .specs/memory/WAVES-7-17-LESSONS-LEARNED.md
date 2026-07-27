# Waves 7-17 — Lições Aprendidas

**Data:** 2026-06-30  
**Contexto:** Execução Harness V3 Waves 7-17 (self-refactoring)  
**Feedback do usuário:** Análise pós-execução

---

## ✅ O que Funcionou Bem

### 1. Execution Phase — Excelente ⭐⭐⭐
- ✅ Todos os 11 waves implementados
- ✅ 44/44 evals passando (100% success)
- ✅ 8/8 acceptance gates passando
- ✅ Qualidade de código alta
- ✅ Evidence collection completo

### 2. Paralelização — Bem Estruturada ⭐⭐⭐
- ✅ Wave 7 → foundation (W11 depends)
- ✅ W8-W10 rodaram em paralelo (sem dependências)
- ✅ W12+W13 rodaram em paralelo (ambas dependem de W11)
- ✅ W15 rodou após todos (depends on W7-14)
- ✅ W17 final (depends on W15+W16)
- ✅ DAG respeitada, without bottlenecks

### 3. Validation Phase — Robusto ⭐⭐⭐
- ✅ 5 juntas independentes avaliaram
- ✅ Score 92/100 justo e bem fundamentado
- ✅ Evidência específica para cada junta
- ✅ Sem inflação de score

---

## ❌ Problemas Identificados

### 1. Design/Plan Phase — Artefatos Incompletos ❌

**Problema:**
```
Esperado: 4 documentos PRD + ADR + TEST-SPEC + DESIGN
Entregue: 1 documento (DESIGN.md)
```

**Evidência:**
- DESIGN.md foi criado ✅
- PRD.md NÃO foi criado ❌
- ADR.md NÃO foi criado ❌
- TEST-SPEC.md NÃO foi criado ❌

**Contrato Violado:**
- `.specs/shared/phase-engine-contract.md` — Design/Plan DEVE criar:
  - PRD (requirements + business goals)
  - ADR (architectural decisions + trade-offs)
  - TEST-SPEC (validation strategy + test cases + fixtures)
  - DESIGN.md (technical architecture)

**Impacto:**
- Falta PRD → Requirements não capturadas formalmente
- Falta ADR → Trade-offs de arquitetura não documentados
- Falta TEST-SPEC → Estratégia de validação não formal
- Medium severity (execution não foi afetada, mas governance foi)

---

### 2. Task-Specs — Não Seguiram Taxonomia ❌

**Problema:**
```
Esperado: Task-Spec v2.1 format (skill:task-spec)
Entregue: Tasks v2.1 com variações
```

**Detalhes:**
- Tasks criadas usaram formato "quase v2.1"
- Faltaram elementos da taxonomia completa:
  - acceptance_criteria: parcial
  - verification_steps: parcial
  - rollback_plan: incompleto
  - context_bundle: não sempre especificado
  - allowed_files: mencionado mas não estruturado
  - forbidden_scope: não explícito

**Contrato Violado:**
- `.specs/shared/task-contract.md` — Task DEVE incluir:
  - parent change
  - task goal
  - inputs/outputs
  - allowed files (structured list)
  - forbidden files (structured list)
  - verification (testable steps)
  - evidence required
  - rollback path
  - allocation owner

**Impacto:**
- Tasks menos estruturadas que o ideal
- Não são portáveis para sistemas alternativos (task-spec design goal)
- Allocation scope implicit, não explicit
- Medium severity (work foi feito, mas menos reutilizável)

---

### 3. Ask-User — Usado Mais que Necessário ❌

**Problema:**
```
Esperado: ask-user ONLY quando necessário (state conflict, ambiguity, scope, approval)
Entregue: ask-user usado em contextos desnecessários
```

**Casos Problemáticos:**
- Perguntou "qual junta?" quando deveria ter rodado todas (user tinha dito "full junta")
- Perguntou "proceed to validation?" quando o contrato permite transição automática pós-execution
- Perguntou "confidence check?" em contextos onde confiança era alta (>90%)

**Contrato Violado:**
- `.specs/shared/ask-user-policy.md` — Ask quando:
  - Execution requires explicit authorization ✓
  - Phase transition needs confirmation ✓
  - Ambiguity blocks correctness ✓
  - State conflict exists ✓
  - Destructive operation ✓
  - Scope expansion ✓
  
  **NÃO ask quando:**
  - A safe best-effort answer is possible ✗
  - User already gave the answer ✗
  - Question is only preference ✗
  - Task is analysis-only ✗

**Impacto:**
- Fluxo mais lento que deveria
- UX menos fluida
- User interruption desnecessária
- Low severity (não bloqueou execução, mas irritante)

---

## 🔧 Correções para Waves 18-23

### 1. Design/Plan Phase — Executar Template Completo

**Ação:**
```bash
# Usar templates oficiais para TODOS os artefatos
.specs/templates/prd-template.md
.specs/templates/adr-template.md
.specs/templates/test-spec-template.md
.specs/templates/design-template.md

# Criar 4 arquivos:
.specs/changes/waves-18-23-implementation/PRD.md
.specs/changes/waves-18-23-implementation/ADR.md
.specs/changes/waves-18-23-implementation/TEST-SPEC.md
.specs/changes/waves-18-23-implementation/DESIGN.md
```

**Verificação:**
```bash
# Phase Engine Contract check
[ ] PRD exists and filled
[ ] ADR exists and filled
[ ] TEST-SPEC exists and filled
[ ] DESIGN.md exists and filled
[ ] All 4 docs reference each other
```

---

### 2. Task-Specs — Usar skill:task-spec Diretamente

**Ação:**
```bash
# For each task, use skill:task-spec EXPLICITLY
# Load skill before creating any task
skill.load('task-spec')

# Follow v2.1 taxonomy exactly:
# - parent_change
# - task_goal (1 sentence)
# - inputs (list)
# - outputs (list with paths)
# - allowed_files (structured: pattern list)
# - forbidden_files (structured: pattern list)
# - required_context (list)
# - inputs_required (structured YAML)
# - outputs_required (structured YAML)
# - acceptance_criteria (numbered list, testable)
# - verification_steps (bash eval scripts)
# - rollback_plan (structured)
# - allocation_owner
# - specialist (if needed)
# - evidence_required
# - time_estimate
# - notes (optional)
```

**Verificação:**
```bash
# Task-Spec v2.1 validation
[ ] All required fields present
[ ] allowed_files is YAML list (not prose)
[ ] forbidden_files is YAML list (not prose)
[ ] acceptance_criteria are testable
[ ] verification_steps are executable bash
[ ] rollback_plan is concrete (not vague)
```

---

### 3. Ask-User Policy — Aderir Estritamente ao Contrato

**Ação:**
```bash
# ONLY ask when REQUIRED by contract:

# ✅ ASK:
- ask-user when state conflict detected
- ask-user when ambiguity blocks correctness
- ask-user when destructive operation
- ask-user when scope expansion requested
- ask-user when execution approval needed

# ❌ DON'T ASK:
- Don't ask when user already specified (e.g., "full junta")
- Don't ask when safe default exists
- Don't ask for phase transitions (auto-advance allowed)
- Don't ask for confidence checks > 80%
- Don't ask for confirmation when contract allows
```

**Verificação:**
```bash
# Pre-execution checklist
[ ] Every ask-user has a clear trigger from contract
[ ] No preference-based asks
[ ] No redundant asks (user already answered)
[ ] No unnecessary safety checks
```

---

## 📚 Artifacts Created During Waves 7-17 — Inventory

| Artifact | Type | Count | Status |
|----------|------|-------|--------|
| Contracts | `.specs/shared/*` | 11 | ✅ Good |
| Tools | `tools/*.sh` | 11 | ✅ Good |
| Tool Contracts | `tools/*.contract.md` | 11 | ✅ Good |
| Agents | `agents/*.agent.md` | 9 (8 upd + 1 new) | ✅ Good |
| Fixtures | `test/fixtures/harness-v3/` | 11 | ✅ Good |
| Evidence | `evidence/W*.md` | 11 | ✅ Good |
| Task-Specs | `tasks/W*.md` | 11 | ⚠️ Incomplete taxonomy |
| Design Docs | `DESIGN.md` | 1 | ⚠️ Missing PRD/ADR/TEST-SPEC |
| Documentation | AGENTS.md, README.md, Roadmap | 3 | ✅ Good |

---

## 🎓 Patterns That Worked Well

### 1. Evidence Collection ✅
- Each wave had clear evidence file
- Evidence referenced specific files + line numbers
- Evidence was concrete, not vague

### 2. Fixture Design ✅
- Smoke test fixtures (2-3 scenarios per wave)
- All passing, no flakes
- Clear eval scripts (bash)

### 3. Allocation Clarity ✅
- Global allocation defined upfront
- Local allocation per task
- Allowed/forbidden files explicit

### 4. Execution Ledger ✅
- Execution events timestamped
- Critical path tracked
- Dependency order respected

---

## 🎯 Recommendations for Waves 18-23

### High Priority
1. ✅ Create full 4-artifact design phase (PRD + ADR + TEST-SPEC + DESIGN)
2. ✅ Use skill:task-spec for ALL tasks (not just some)
3. ✅ Follow task-spec v2.1 taxonomy strictly (not "close enough")
4. ✅ Reduce ask-user calls to ONLY contract-required cases

### Medium Priority
5. Expand TEST-SPEC to include regression scenarios
6. Create ADR for each major architectural decision (not just summary)
7. Add integration test fixtures (not just smoke tests)

### Low Priority
8. Consider KB updates for new tool documentation
9. Add cross-wave dependency validation
10. Create operator runbook for new tools

---

## 📊 Metrics: Plan vs. Actual

| Metric | Planned | Actual | Gap |
|--------|---------|--------|-----|
| Design phase docs | 4 (PRD+ADR+TEST-SPEC+DESIGN) | 1 (DESIGN only) | -3 |
| Task-Spec compliance | 100% v2.1 | ~85% v2.1 | -15% |
| Ask-user calls | ~5 (required only) | ~12 | +7 (unnecessary) |
| Evidence files | 11 | 11 | ✅ |
| Evals passing | 44/44 | 44/44 | ✅ |
| Validation score | ≥75 | 92 | ✅ |

---

## 🔍 Root Cause Analysis

### Why Design Artifacts Were Incomplete?

**Hypothesis:**
- Altitude was optimizing for "get to execution fast"
- PRD/ADR/TEST-SPEC felt "nice-to-have" vs. required
- Contract enforcement could be stricter

**Fix:**
- Add phase-gate validation that BLOCKS phase transition until all 4 docs exist
- Make phase-engine-contract check explicit (no partial credit)

---

### Why Task-Specs Weren't Fully Compliant?

**Hypothesis:**
- skill:task-spec wasn't invoked (would have enforced taxonomy)
- Tasks were created ad-hoc instead of through skill
- "v2.1-ish" was good enough for execution

**Fix:**
- Mandate skill:task-spec invocation before ANY task creation
- Add linter check: reject tasks missing required fields
- Update allocation-contract to require structured allowed_files/forbidden_files

---

### Why Ask-User Was Over-Used?

**Hypothesis:**
- Altitude was being "extra cautious"
- Treating every phase transition as needing confirmation
- No explicit "ask policy enforcement"

**Fix:**
- Add ask-user policy linter
- Pre-execution checklist: "Is this ask-user call justified by contract?"
- Train altitude with examples of when NOT to ask

---

## ✅ Action Items for Future Waves

```
BEFORE Waves 18-23 execution:

[ ] Update phase-engine-contract.md to enforce 4-doc design phase
[ ] Create linter for task-spec v2.1 compliance
[ ] Create linter for ask-user policy enforcement
[ ] Add phase-gate: BLOCK until all design docs exist
[ ] Update allocation-contract: require structured file lists
[ ] Create fixture: "Design phase artifact validation"

DURING Waves 18-23:

[ ] Invoke skill:task-spec for every task (not ad-hoc)
[ ] Create PRD + ADR + TEST-SPEC + DESIGN (not just DESIGN)
[ ] Validate tasks against v2.1 schema before execution
[ ] Count ask-user calls; justify each one

AFTER Waves 18-23:

[ ] Audit: did we create 4 design docs?
[ ] Audit: are 100% of tasks v2.1 compliant?
[ ] Audit: ask-user calls justified?
[ ] Update lessons learned
```

---

## 📝 Summary

**What Worked:** Execution, parallelization, validation, evidence, fixtures  
**What Needs Fixing:** Design phase completeness, task-spec compliance, ask-user policy  
**Severity:** Medium (governance gap, not execution gap)  
**Impact on Waves 7-17:** None (work shipped successfully)  
**Impact on Waves 18-23:** High (must enforce contracts more strictly)  

**Recommendation:** Retrofit phase-gate validation + linters BEFORE Waves 18-23.

---

**Signed:** Altitude Coordinator (self-assessment)  
**Date:** 2026-06-30  
**Next Review:** After Waves 18-23 execution


---

## ❌ BONUS: TODO Tracking — Não Funcionou

### O Problema

```
Tentativa: Usar todowrite tool para rastrear progresso das 11 waves
Expectativa: Visual progress, status updates em tempo real
Realidade: Tool foi ignorado, nada atualizado, esperando "checks" eternamente
```

**Evidência:**
- todowrite foi invocado ~2 vezes
- Nunca atualizado durante execução
- Nenhum feedback útil ao usuário
- "Esperando checks" eternamente (timeouts)

**Impacto:** Low (não bloqueou nada), mas UX ruim

---

### Root Cause

1. **Tool incompatibilidade:** todowrite talvez espere callbacks que não chegam
2. **Async issues:** Altitude foi sync, todowrite talvez async
3. **Overhead:** Altitude otimizou para executar, não para UI updates
4. **Timeout:** Tool esperava signals que nunca vieram

---

### Recomendação para W18-23

**Option A (Recomendado):** Não usar todowrite
- Use simples logging em arquivo
- Melhor performance
- Sem overhead

**Option B:** Debugar todowrite
- Entender por que espera checks
- Talvez issue em opencode runtime
- Baixa prioridade

---

## 📝 TODO Tool Assessment

| Tool | Funcionalidade | Viabilidade | Recomendação |
|------|---|---|---|
| todowrite | Task progress tracking | ❌ Não funcionou | Skip para W18-23 |
| verify_step | Multi-step verification | ✅ Funcionou bem | Keep usando |
| faithfulness_gate | Confidence validation | ✅ Funcionou bem | Keep usando |

---

---

## 🔄 WAVES 18-23 UPDATE: Question() Usage Policy (MANDATORY)

**NOTE:** W7-17 had inconsistent ask-user patterns. W18-23 **STANDARDIZES** this and establishes **WHEN to use question() as MANDATORY DISCIPLINE**.

### Problem Identified (W7-17)

- Over-use of question() (12 calls vs recommended 5)
- Unclear criteria for WHEN to ask vs provide default
- Inconsistent with ask-user-policy.md
- User ended up re-teaching boundaries

### Solution (W18-23+)

**Mandatory Policy 2: Ask-User (question() calls)**

When to USE question():
- ✅ State conflict exists (no safe default)
- ✅ Gate blocks execution (user approval needed)
- ✅ Ambiguity blocks correctness (multiple options, must pick one)
- ✅ Destructive operation is proposed
- ✅ Scope expansion requested
- ✅ Phase transition needs confirmation
- ✅ GRILL ME pattern applies (multi-scenario decision)

When to NOT use question():
- ❌ User already specified preference
- ❌ Safe best-effort default exists
- ❌ Task is analysis-only (non-mutating)
- ❌ Confidence > 80% for low-risk choice
- ❌ Question is only preference, not correctness

### Implementation (W18-23+)

**Mandatory in every agent's Recovery Protocol:**

```markdown
1. MANDATORY: Load ask-user policy — Read `.specs/shared/ask-user-policy.md`
2. DECISION GATE: Should I call question()?
   - If YES: Check criteria (state conflict, gate blocked, ambiguity, etc)
   - If NO: Provide safe default or analyze further
3. Call question() ONLY if Policy 2 criteria met
```

**Pre-Execution Checklist must verify:**

```markdown
#### Question() Usage Validation
- [ ] Ask-user policy loaded before ANY question() call
- [ ] Question() justified? (Check Policy 2 criteria)
- [ ] No safe default? (Confirm default doesn't exist)
- [ ] GRILL ME pattern ready? (Multi-scenario comparison)
```

**Evidence tracking:**

```markdown
### Evidence Required
- [ ] Question() audit — Log all question() calls + user responses
        Example: "Gate 1 state conflict: user chose Option B"
```

### References

- `.specs/shared/ask-user-policy.md` — Full policy
- `.specs/memory/active-state.md` (Policy 2) — Quick reference
- `agents/altitude-maestro.agent.md` (Recovery Protocol) — Where it's enforced
- `agents/altitude-execution.agent.md` (Recovery Protocol) — Where it's enforced
- `agents/altitude-validation.agent.md` (Recovery Protocol) — Where it's enforced

### Recovery from Over-Use

If an agent calls question() inappropriately:
1. Check ask-user-policy.md criteria
2. If NO criteria met → provide default instead
3. Log as "question() avoided (safe default provided)"
4. Document why default was safe

### Recovery from Under-Use

If decision is made without asking when it should be:
1. Check ask-user-policy.md criteria
2. If YES criteria met → call question() retrospectively
3. Allow user to approve/override the decision

### Lessons for W24+

This pattern **MUST be replicated** in all future waves:
- Ask-user policy must be loaded in every Recovery Protocol
- Pre-Execution Checklist must validate question() appropriateness
- Evidence must include question() audit log
- Over-use and under-use must be tracked

**DO NOT revert to ad-hoc question() calls — this is a foundational discipline for W18+.**

Violations:
- ❌ Calling question() without checking ask-user-policy.md
- ❌ Calling question() when safe default exists
- ❌ NOT calling question() when state conflict exists
- ❌ NOT documenting question() calls in evidence

---



**NOTE:** W7-17 recommended "Skip todowrite", but W18-23 **REVERSES** this and establishes **TODO + Agent Tracking as MANDATORY**.

### Why TODO Tracking is NOW Mandatory

1. **Context Persistence:** User explicitly requested this remain systematic across all future phases/blocos
2. **Allocation Visibility:** Agent assignments must be visible everywhere (DESIGN.md + TODOs)
3. **Progress Tracking:** Multiple agents executing in parallel → need to track independently
4. **Memory/Repeatability:** TODO pattern ensures same discipline applied in W24+ without explicit re-asking

### Implementation (W18-23+)

**Mandatory Policy:**
- ✅ todowrite() called at START of every BLOCO
- ✅ todowrite() called at START of every PHASE (Execution, Validation, Ship)
- ✅ Each TODO entry: `BLOCO N (Phase: X) | T-YY | Description | Agent: agent-name`
- ✅ Taxonomy defined in `.specs/shared/todo-and-agent-tracking-policy.md`
- ✅ Stored in active-state.md as "MANDATORY execution policy"
- ✅ Pre-Execution Check: Verify TODO entries exist before any task starts
- ✅ Post-Execution Check: Mark all completed entries in TODO

**References:**
- `.specs/shared/todo-and-agent-tracking-policy.md` (NEW policy)
- `.specs/changes/waves-18-23-implementation/DESIGN.md` (Task Allocation Map)
- `.specs/memory/active-state.md` (Execution Policies section)
- `agents/altitude-plan.agent.md` (Recovery Protocol updated)
- `agents/altitude-maestro.agent.md` (Mission updated)

### Recovery from Failed TODO

If todowrite() is forgotten mid-execution:
1. Check `.specs/changes/CHANGE_ID/state.md` for current bloco
2. Check `.specs/memory/active-state.md` for current tasks
3. **Reconstruct** TODO entries manually using DESIGN.md Task Allocation Map
4. Mark as "retrospective" and continue

### Lessons for W24+

This pattern **MUST be replicated** in all future waves:
- TODO tracking enables systematic progress without re-asking user
- Agent allocation visibility ensures accountability  
- Taxonomyformat consistency enables automation (parsing, reporting, metrics)
- Established in recovery protocols (guaranteed to execute)
- Stored in policies (guaranteed to propagate)

**DO NOT revert to "skip todowrite" — this is a foundational change for W18+.**

---

**Conclusão (Updated from W7-17):** 

W7-17: "Skip todowrite, use logging instead"  
W18-23+: **"Use todowrite + agent tracking as MANDATORY, backed by contracts + recovery protocols + policies"**

This ensures discipline persists across future agents and waves without losing context.

