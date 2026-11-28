# E3d5c6f Stage B4 — Final Full Regression Closeout

**Accepted 2026-11-25 — developer-local Godot 4.6.2 verification.** Stage B1/B2/B3 targeted gates previously accepted; B4 final fresh combined **68/68 unique F6 scenes PASSED** against **923 manifest-expected check sections**. This is a *scene-level developer-reported* pass and an audited *manifest expected* total; the assistant did not run Godot and did not independently inspect 923 assertions.

## Fresh acceptance evidence

| Wave | Unique F6 scenes passed locally | Associated manifest-expected sections |
|---|---:|---:|
| 1 — original inventory/production/early construction | 20/20 | 245 |
| 2 — drone workers/physical cargo/staging/escrow | 20/20 | 333 |
| 3 — power/charging/dispatch/building/cancel | 20/20 | 258 |
| 4 — previous final construction/blackout and specialization A/B1/B2/B3 | 8/8 | 87 |
| **Fresh B4 total** | **68/68 unique** | **923 expected** |

The developer explicitly confirmed Wave 4 8/8 fresh local F6 success on 2026-11-25, after separate Wave 1, Wave 2, and Wave 3 20/20 confirmations. Source manifest `tools/specialized_drones_e3d5c6f_stage_b4_68_suite_regression.csv` was previously audited for 68 unique, existing Godot scene paths and total 923 expected; 63 inherited E3d5c6e suites / 880 historical expected groups plus five new E3d5c6f scenes / 43 new labeled PASS sections. No targeted rerun is counted again as a new unique suite. See [B4 regression procedure](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_B4_REGRESSION.md).

## Stage B accepted within scope

The exact opt-in `res://scenes/core/playable_specialized_drones_e3d5c6f.tscn` and isolated tests demonstrate distinct authentic drones: physical five-ingot material collection from Storage (15→10), original-site staging, original material escrow, verified role handoff, logistics return, physical construction-drone arrival, real original power allocation and worker scheduler, 18-second original Ammunition Press construction, correct escrow commit, metered return, and controlled outage pause/resumption in the B3 test. B1 single-controller guards and Stage A role contracts also remain accepted.

**Scope limitations / not yet implemented or accepted:** the new architecture is not promoted into `main.tscn`; fully generalized multi-job or fleet dispatch, specialized cancellation at each physical stage, return-to-storage/material recovery, full charging/fairness, save/load, persistent research/storage docks, additional ores/energy sources, zombie combat and broad manual playable acceptance remain future work. No claim of production-readiness from isolated F6 passes.

## Repository safety and next milestone

- Code remains on `feature/e3d5c6f-stage-a-role-contracts`. Draft PR #1 is open/unmerged. Do **not** merge as an incidental closeout operation, change `main`, or overwrite developer's uncommitted `data/buildings/*.tres`, `data/recipes/*.tres` or other `.tscn`.
- No gameplay source changes for final B4 acceptance. Preserve all legacy accepted fixtures/tests and the one simulation owner.
- **Recommended next separate gate:** `E3d5c6f Stage C — Specialized Drone Cancellation and Physical Material Custody Recovery`, starting with a **read-only GitHub architecture/design audit**, explicit phase-by-phase cancellation/escrow/return ownership model, and a small opt-in F6 test plan, **not immediate gameplay changes**. See [Stage C proposal](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C_PROPOSAL.md).
