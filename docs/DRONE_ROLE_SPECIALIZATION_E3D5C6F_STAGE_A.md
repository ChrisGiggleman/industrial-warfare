# E3d5c6f — Stage A Role Contracts (isolated F6 accepted locally)

**Approval:** 2026-11-24. **Scope:** additive, exact-opt-in role leases and immutable internal receipt snapshot only. **Developer-local isolated F6 acceptance confirmed 2026-11-24.** The assistant did not execute Godot or inspect assertion-by-assertion logs.

## New isolated resources
- `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn` — Stage A empty scope, no simulation loops or entities; only a guarded contract node.
- `res://scripts/components/specialized_drone_role_contracts_e3d5c6f.gd` — default OFF unless enabled in exact scene; read-only job, priority queue, staging registry, bill and escrow verification. Logistics lease is exclusive; receipt records pinned original identity and escrow ID/bill internally, without exposing a caller-mutable receipt dictionary; different builder can claim it once. Revocation is a fail-closed tombstone; no material, worker, power or progress mutation.
- F6 tests below. Test fixtures use original staging and escrow services to create real held material; this is **not** a simulation of physical two-drone delivery.

## F6 one-at-a-time navigator (both passed locally)
| # | Exact path | Expected printed sections |
|---|---|---:|
| 1 | `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` | 6 |
| 2 | `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` | 7 |

**Result:** Both F6 scenes passed locally per developer report. These fixtures contain 13 labeled PASS sections, not a separate authoritative individual-assertion count. Existing 63-suite / 880-manifest-check baseline is historical and was not rerun as a combined regression. Run scenes with **F6**, not F5, if retesting.

## Preserved scope
Main, existing E3d5c6b/c/d/e scenes, all accepted tests, gameplay source, dispatcher, job timers and charging/recovery implementations are untouched. Existing **63/63 developer-reported passed suites; 880 manifest-expected checks** remains historical accepted baseline, not rerun by this change. No physical two-drone movement, transport rearm, scheduler worker admission, charging policy, cancellation recovery transport or new manufacturing/power/ore systems.

**Stage B is not approved.** Do not enable physical specialized movement until explicit follow-up approval.
