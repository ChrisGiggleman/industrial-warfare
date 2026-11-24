# E3d5c6f — Stage A Role Contracts (pending Godot F6 acceptance)

**Approval:** 2026-11-24. **Scope:** additive, exact-opt-in role leases and immutable internal receipt snapshot only. This checkpoint is **not accepted/tested locally**.

## New isolated resources
- `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn` — Stage A empty scope, no simulation loops or entities; only a guarded contract node.
- `res://scripts/components/specialized_drone_role_contracts_e3d5c6f.gd` — default OFF unless enabled in exact scene; read-only job, priority queue, staging registry, bill and escrow verification. Logistics lease is exclusive; receipt records pinned original identity and escrow ID/bill internally, without exposing a caller-mutable receipt dictionary; different builder can claim it once. Revocation is a fail-closed tombstone; no material, worker, power or progress mutation.
- F6 tests below. Test fixtures use original staging and escrow services to create real held material; this is **not** a simulation of physical two-drone delivery.

## F6 one-at-a-time navigator (unrun)
| # | Exact path | Expected printed sections |
|---|---|---:|
| 1 | `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` | 6 |
| 2 | `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` | 7 |

**Total:** 2 isolated scenes; 13 expected printed sections. These counts are **not individual assertions or verified passes**. No new accepted unique suites or expected-check tally is claimed before Godot run and explicit acceptance. Run each scene with **F6**, not F5. Report printed PASS sections or the first error and line.

## Preserved scope
Main, existing E3d5c6b/c/d/e scenes, all accepted tests, gameplay source, dispatcher, job timers and charging/recovery implementations are untouched. Existing **63/63 developer-reported passed suites; 880 manifest-expected checks** remains historical accepted baseline, not rerun by this change. No physical two-drone movement, transport rearm, scheduler worker admission, charging policy, cancellation recovery transport or new manufacturing/power/ore systems.

**Stage B is not approved.** Do not enable physical specialized movement until explicit follow-up approval.
