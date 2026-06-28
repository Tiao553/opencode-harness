# Fixture: Visual Artifact Request

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-07-visual-artifact-request |
| Title | Final visual diagram needed for presentation |
| Purpose | Preserve behavior: Route to visual:* command, generate presentation-quality visual, not stored as durable artifact |
| Group | Artifact Generation |

## Request

**User input:**
```
"/visual:architecture-diagram for our Fabric medallion pattern. 
Make it ready for executive presentation."
```

## Expected Behavior

### Route
- Coordinator: `visual:*` (direct command, not Altitude)
- Mode: `visual_artifact`

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Visual output (SVG/PNG/HTML) | created | presentation-ready diagram |
| Stored in .specs or docs | maybe | depends on user request |

### Allocation
- **Global scope:** Visual generation only
- **Forbidden scope:** No code generation, no .specs changes
- **Specialists:** Visual designer (reason: presentation quality required)

### Context Loaded
- architecture docs or references provided by user
- design conventions
- branding/style guide if applicable

### Todos
- [ ] Gather architecture source (text, Mermaid, or user description) — verify: clear input received
- [ ] Design visual layout for presentation audience — verify: mockup or wireframe approved
- [ ] Generate final visual artifact — verify: output viewable and polished

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| visual quality | visual review | Professional appearance, clear legend, readable |
| audience fit | executive review | Presentation-appropriate level of detail |
| format correct | output check | SVG/PNG/HTML as requested |

### State Update
- No phase or .specs state change
- Visual artifact may be embedded in docs but doesn't trigger documentation mode

## Must Not

- ❌ Store visual as the only architecture record (it's supplementary)
- ❌ Use text-architecture Mermaid without adding presentation polish
- ❌ Forget to include legend or labels
- ❌ Assume visual can replace text documentation

## Notes

This fixture validates that visual:* is independent of coordinator lifecycle.
Visual artifacts are final communication tools, not architectural sources.
