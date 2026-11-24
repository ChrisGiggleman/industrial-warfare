# E3d5c6e Stage B — Targeted compatibility F6 regression (42 scenes / 584 checks)

**2026-11-23 — WAVE 1 ACCEPTED 15/15 F6 scenes (203 manifest-expected checks), developer-reported locally; Wave 2 27/381 NOT YET RUN.** Full 42/584 Stage B remains pending. No full fresh 63-suite / 880-expected-check regression performed yet. The original PREPARED/PENDING instructions below reflect the historical planning state, and Wave 1 scene rows are checked to capture current acceptance. No Godot tests executed by assistant, no Output transcripts provided. Follow [interactive Copy navigator instructions](GODOT_F6_COPY_NAVIGATOR.md).

**2026-11-23 — PREPARED, NOT YET RUN.** E3d5c6e new isolated Stage A **14/14 accepted locally** by developer report. Previously accepted fresh whole project baseline was 62 suites / 866 manifest-expected checks. **The new Stage A makes 63 distinct accepted suites / 880 expected checks**, but the full 63-suite regression has **not** been rerun after the code change.

## Purpose and checked scope

Test original scene isolation, Direct Build authorization, queue/priority, finite construction power, physical drone delivery, immutable staged source custody, charged/rearmed worker lifecycle and cancellation recovery **after** Stage A's default-off extension of `PrototypeConstructionWorkerDrone` and `PrototypeDroneAutomaticDispatch`. The prior accepted scenes and tests themselves were not changed, and no new tick owners, second drone or Main feature enablement is permitted.

The 42 test files are **already present, distinct `res://tests/*.tscn` scene files verified in GitHub main**. Source of truth is [Stage B manifest](../tools/drone_power_interruption_e3d5c6e_stage_b_compatibility.csv). Reruns add zero new unique suites. Wave 1 includes `E3d5c6e Stage A` as a repeat for new-scope sanity and both isolated power cases; Wave 2 exactly repeats the previous E3d5c6d Wave 2 compatibility manifest. Full 63/880 remains a later independent final acceptance gate.

| Wave | Coverage | Suites | Manifest-expected checks |
|---|---|---:|---:|
| **1 — START HERE** | New one-drone Stage A + historical scene/authorization isolation + real power coverage/finite power | **15** | **203** |
| **2 — AFTER WAVE 1** | Physical drone battery, logistics, escrow/custody, charging, recovery and original Direct Build | **27** | **381** |
| **Total Stage B target** | 42 distinct existing scenes, no new tests | **42** | **584** |

## How to run

1. In VS Code repo, check `git status --short`, preserving any local edits. Safely fetch and fast-forward `main`: `git fetch origin`, `git switch main`, `git pull --ff-only origin main`. Do not reset/force away local changes.
2. Godot **4.6.2 Stable** — open each exact `res://tests/<name>.tscn` scene **one at a time**, and run **F6 Current Scene** (not F5 Main). Check every suite's Output/PASS banner and Debugger; no made-up combined runner.
3. User's preferred [interactive Copy scene / Previous / Next navigator](GODOT_F6_COPY_NAVIGATOR.md) is mandatory for displaying test paths. Start with **Wave 1: 15 tests / 203 expected checks**. Navigation alone does not imply test completion.
4. On first red parser/assertion error, STOP and send exact scene path, first error with line number, and last PASS output. Fix only proven regression and rerun affected gates.
5. When all 15 pass report **"E3d5c6e Stage B Wave 1 all 15 passed"**. Only then proceed to Wave 2's 27 tests. Stage B acceptance requires user-local confirmation of all 42 scenes; the **584 is the verified expected-check sum**, not individually audited Output evidence.
6. After both waves pass, prepare separate Stage C real playable F6 checks in `res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn`, especially blackout parking while real Press construction is underway, restored power, physically bound worker resume and cancellation with real inventory return. Later create final full 63-suite/880-expected-check manifest.

## Wave 1 — 15 suites / 203 expected checks (PENDING)

| # | Verified F6 scene | Expected checks | Developer-local status |
|---:|---|---:|:---:|
| 01 | [`playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn`](../tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn) | 14 | ✓ |
| 02 | [`playable_unified_construction_e3d5c6d_stage_a_test.tscn`](../tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn) | 16 | ✓ |
| 03 | [`playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`](../tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn) | 14 | ✓ |
| 04 | [`blueprint_sandbox_mode_test.tscn`](../tests/blueprint_sandbox_mode_test.tscn) | 12 | ✓ |
| 05 | [`timed_storage_placement_test.tscn`](../tests/timed_storage_placement_test.tscn) | 4 | ✓ |
| 06 | [`planned_storage_build_mode_test.tscn`](../tests/planned_storage_build_mode_test.tscn) | 6 | ✓ |
| 07 | [`storage_blueprint_preview_snap_e3c2b_test.tscn`](../tests/storage_blueprint_preview_snap_e3c2b_test.tscn) | 15 | ✓ |
| 08 | [`conveyor_building_placement_snap_test.tscn`](../tests/conveyor_building_placement_snap_test.tscn) | 8 | ✓ |
| 09 | [`build_hotbar_keyboard_integration_test.tscn`](../tests/build_hotbar_keyboard_integration_test.tscn) | 12 | ✓ |
| 10 | [`sandbox_blueprint_authorization_test.tscn`](../tests/sandbox_blueprint_authorization_test.tscn) | 18 | ✓ |
| 11 | [`blueprint_construction_priority_e3d5a_test.tscn`](../tests/blueprint_construction_priority_e3d5a_test.tscn) | 15 | ✓ |
| 12 | [`sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn`](../tests/sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn) | 19 | ✓ |
| 13 | [`blueprint_click_inspection_e3d5c3d2e_test.tscn`](../tests/blueprint_click_inspection_e3d5c3d2e_test.tscn) | 16 | ✓ |
| 14 | [`construction_power_coverage_e3d5c3a_test.tscn`](../tests/construction_power_coverage_e3d5c3a_test.tscn) | 16 | ✓ |
| 15 | [`finite_construction_power_e3d5c3b2_test.tscn`](../tests/finite_construction_power_e3d5c3b2_test.tscn) | 18 | ✓ |
| | **Wave 1** | **203** | **ACCEPTED (developer-local)** |

## Wave 2 — 27 suites / 381 expected checks (PENDING)

| # | Verified F6 scene | Expected checks | Developer-local status |
|---:|---|---:|:---:|
| 01 | [`prototype_construction_worker_drone_e3d5c4u_test.tscn`](../tests/prototype_construction_worker_drone_e3d5c4u_test.tscn) | 16 | ☐ |
| 02 | [`prototype_drone_battery_dock_e3d5c4x_test.tscn`](../tests/prototype_drone_battery_dock_e3d5c4x_test.tscn) | 20 | ☐ |
| 03 | [`blueprint_material_staging_e3d5c4c_test.tscn`](../tests/blueprint_material_staging_e3d5c4c_test.tscn) | 16 | ☐ |
| 04 | [`blueprint_physical_staging_e3d5c4d_test.tscn`](../tests/blueprint_physical_staging_e3d5c4d_test.tscn) | 16 | ☐ |
| 05 | [`blueprint_site_staging_ownership_e3d5c4h_test.tscn`](../tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn) | 16 | ☐ |
| 06 | [`blueprint_anchored_receiver_e3d5c4i_test.tscn`](../tests/blueprint_anchored_receiver_e3d5c4i_test.tscn) | 16 | ☐ |
| 07 | [`blueprint_receiver_recovery_audit_e3d5c4j_test.tscn`](../tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn) | 12 | ☐ |
| 08 | [`blueprint_construction_material_escrow_e3d5c2a_test.tscn`](../tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn) | 16 | ☐ |
| 09 | [`drone_storage_discovery_e3d5c5x3_test.tscn`](../tests/drone_storage_discovery_e3d5c5x3_test.tscn) | 12 | ☐ |
| 10 | [`drone_supplier_reservations_e3d5c5x4a_test.tscn`](../tests/drone_supplier_reservations_e3d5c5x4a_test.tscn) | 12 | ☐ |
| 11 | [`drone_return_reservations_e3d5c5x4b_test.tscn`](../tests/drone_return_reservations_e3d5c5x4b_test.tscn) | 14 | ☐ |
| 12 | [`drone_physical_pickup_e3d5c5x5a_test.tscn`](../tests/drone_physical_pickup_e3d5c5x5a_test.tscn) | 12 | ☐ |
| 13 | [`drone_physical_delivery_e3d5c5x5b_test.tscn`](../tests/drone_physical_delivery_e3d5c5x5b_test.tscn) | 13 | ☐ |
| 14 | [`drone_delivered_worker_e3d5c5x5c_test.tscn`](../tests/drone_delivered_worker_e3d5c5x5c_test.tscn) | 16 | ☐ |
| 15 | [`drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn`](../tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn) | 13 | ☐ |
| 16 | [`drone_finite_hub_charging_e3d5c5x7a_test.tscn`](../tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn) | 13 | ☐ |
| 17 | [`drone_cargo_worker_reuse_e3d5c5x7b_test.tscn`](../tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn) | 16 | ☐ |
| 18 | [`drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn`](../tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn) | 12 | ☐ |
| 19 | [`drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn`](../tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn) | 13 | ☐ |
| 20 | [`drone_lost_site_recovery_e3d5c5x7c3_test.tscn`](../tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn) | 14 | ☐ |
| 21 | [`drone_automatic_dispatch_e3d5c5x8a_test.tscn`](../tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn) | 14 | ☐ |
| 22 | [`drone_automatic_lifecycle_e3d5c5x8b_test.tscn`](../tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn) | 15 | ☐ |
| 23 | [`playable_automatic_construction_drone_stage_c_test.tscn`](../tests/playable_automatic_construction_drone_stage_c_test.tscn) | 13 | ☐ |
| 24 | [`playable_direct_build_authorization_e3d5c6b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_test.tscn) | 11 | ☐ |
| 25 | [`playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn) | 14 | ☐ |
| 26 | [`cancelled_site_custody_e3d5c6c_stage_a_test.tscn`](../tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn) | 13 | ☐ |
| 27 | [`cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn`](../tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn) | 13 | ☐ |
| | **Wave 2** | **381** | **PENDING** |

## Guardrails

Preserve legacy Main and E3d5c6b/E3d5c6c/E3d5c6d scenes/tests, original site escrow and source custody, no instant refund, no second dispatcher, and exact gate for new E3d5c6e parking. **Stage A 14/14 accepted locally; Stage B not yet run; Stage C not yet run; final full 63/880 not yet run.** For each later stage record developer-local results in HANDOFF/DEVLOG/ROADMAP/DRONE_CONSTRUCTION_LOGISTICS without treating repeat assertions as new unique checks.
