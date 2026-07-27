# Harness V3 Tactical Data Engineer Coordinator - Intent

## Problem

Harness V3 requires two visible primary coordinators: `Altitude` for strategic durable work and `Data Engineer` for bounded tactical data-engineering work. The current data-engineering behavior is spread across `/data:*` command mappings, a command-centered skill, and specialist agents.

## Objective

Create a visible `data-engineer` coordinator that routes tactical data work internally using the existing `/data:*` mapping ideas.

## Constraints

- Do not delete old `/data:*` behavior.
- Do not rewrite every data specialist.
- Do not route broad strategic architecture work through Data Engineer.
- Keep durable changes under Altitude.

## Success Criteria

- `agents/data-engineer.agent.md` exists.
- `opencode.json` exposes `data-engineer` as primary.
- the coordinator prompt maps SQL, dbt, schema, pipeline, data quality, data contracts, migration, lakehouse/Fabric, Spark, Airflow, and AI pipeline work to internal routes/specialists.
- config remains valid JSON.

