# W7 Command Compatibility Inventory

**T-090 — Command compatibility inventory**
**Date:** 2026-07-25

## All 8 /workflow:* Commands

| Command | Agent | Skill | Preamble | Build Output Gate | Separation enforced |
|---|---|---|---|---|---|
| `/workflow:brainstorm` | workflow.brainstorm-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:define` | workflow.define-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:design` | workflow.design-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:build` | workflow.build-agent | workflow-commands | Added W7 | Enforced | ✅ |
| `/workflow:validate` | workflow.validate-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:ship` | workflow.ship-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:iterate` | workflow.iterate-agent | workflow-commands | Added W7 | N/A | ✅ |
| `/workflow:create-pr` | cloud.aws-deployer (or gh) | workflow-commands | Added W7 | N/A | ✅ |

## Isolation Guarantee (ADR-0004)

All 8 commands route to AgentSpec workflow agents. None invoke Altitude phase agents. None write to `.specs/changes/`. Verified by: `bash test/w7-compatibility.sh`.
