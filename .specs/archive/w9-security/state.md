# W9-SECURITY: Security & Secrets Detection

**Change ID:** w9-security  
**Status:** ready_for_execution  
**Phase:** Execution  
**Created:** 2026-06-29  
**Owner:** altitude-execution  

## Overview

Pre-write security gate: detect secrets (AWS keys, tokens), PII (SSN, phone), block sensitive writes.

Deliverables:
1. `.specs/shared/security-contract.md` (100-120 lines)
2. `tools/security-scan.sh` (bash script with scan, pii, report commands)
3. `tools/security-scan.contract.md` (command reference)
4. Update `agents/altitude-execution.agent.md` (pre-write security gate, ~15 lines)
5. `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md` (2 scenarios)

## Validation Status

- validation_status: 90 (PASSED)
- last_validation_run: baseline
- ready_for_execution: true

## Active Tasks

- security-contract: ✅ implemented
- security-scan-script: ✅ implemented
- altitude-execution-integration: ✅ implemented
- security-fixtures: ✅ implemented

## Change Status

**execution_status:** completed  
**ready_for_validation:** true  
**validation_required:** false  
**next_phase:** validation or ship
