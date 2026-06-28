---
name: generate-web-diagram
description: Generate a standalone HTML architecture, workflow, or system diagram from the provided inputs.
---

# Generate Web Diagram Command

## Usage

```bash
/visual:generate-web-diagram <context>
```

## Process

1. Read every referenced file and argument.
2. Identify the diagram type: architecture, flow, sequence, dependency map, or process overview.
3. Produce a self-contained HTML artifact with:
   - clear title
   - legend if needed
   - labeled nodes and edges
   - short explanatory notes
4. Keep the diagram readable before making it decorative.

## Output

- One standalone visual artifact suitable for local review or browser opening.
