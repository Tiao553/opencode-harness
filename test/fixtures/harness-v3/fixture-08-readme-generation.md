# Fixture: README Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-08-readme-generation |
| Title | README creation/update for project |
| Purpose | Preserve behavior: Route to core:readme-maker command, generate structured README with quick start and features |
| Group | Artifact Generation |

## Request

**User input:**
```
"/core:readme-maker for our new data platform integration. 
Include quick start, features, and architecture overview."
```

## Expected Behavior

### Route
- Coordinator: `core:readme-maker` (direct command)
- Mode: `readme_artifact`

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| README.md | created/updated | Structured README in project root or specified path |

### Allocation
- **Global scope:** README generation only
- **Forbidden scope:** Code changes
- **Specialists:** None required (template-driven)

### Todos
- [ ] Gather project context and features — verify: list of features/patterns collected
- [ ] Write Quick Start section — verify: runnable commands documented
- [ ] Include Architecture section — verify: overview diagram or text present
- [ ] Add Links section — verify: related docs linked

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| README readable | markdown check | Well-formed Markdown, no syntax errors |
| quick start works | review | Steps are clear and reproducible |
| structure complete | section check | Purpose, quick start, features, architecture, links present |

### State Update
- No .specs state change
- active_state stays same

## Must Not

- ❌ Assume README alone suffices for architecture documentation
- ❌ Skip the Quick Start section
- ❌ Leave placeholder links

## Notes

This fixture validates core:readme-maker as a retained command surface.
README is end-user documentation, not durable architectural record.
