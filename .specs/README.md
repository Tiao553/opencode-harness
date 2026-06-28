# Altitude Specs Local Ledger

`.specs/` is the project-local execution ledger for the Altitude Specs Harness.

Shareable baseline files live in:

- `.specs/shared/` - local contracts and policies
- `.specs/templates/` - templates for changes, tasks, evidence, reports, and state

Private runtime files normally live in:

- `.specs/changes/` - real change requests
- `.specs/memory/` - local project memory
- `.specs/archive/` - shipped or cancelled changes
- `.specs/reports/` - generated reports

The harness should version the method and templates. Real execution artifacts are private by default unless a project explicitly chooses to version sanitized `.specs` content.
