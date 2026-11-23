# E3d5c6d — Stage B targeted compatibility regression (39 suites / 536 checks)

**2026-11-22 — Wave 1 ACCEPTED: developer reports all 12/12 tests passed locally, 155 manifest-expected checks. Wave 2 27/381 PENDING.** The original staged instructions below are retained as the initial planning state. No assistant execution or per-check transcript has been claimed. **Mandatory cross-chat test UI:** [Godot F6 Copy Navigator](GODOT_F6_COPY_NAVIGATOR.md) — one scene with functioning Copy, Previous and Next controls at a time.

**2026-11-22 — STAGED FOR DEVELOPER-LOCAL F6; NO STAGE B SUITES CLAIMED RUN YET.** Engine Godot 4.6.2 Stable; repository `ChrisGiggleman/industrial-warfare`, branch `main`.

## Prerequisites

- E3d5c6d Stage A **16/16 A–P ACCEPTED**, explicitly confirmed by developer locally after commit `deb619d`, documented at [Stage A](UNIFIED_CONSTRUCTION_E3D5C6D_STAGE_A.md). This user-reported F6 is not an assistant-run test.
- Last fresh full pre-integration baseline: **61/61 suites passed locally**, with **850 manifest-expected checks**. Adding accepted new Stage A suite gives **62 unique accepted suites / 866 planned checks**; **not yet a fresh 62-suite combined run**.
- No E3d5c6d Stage B gameplay edits/dispatchers/docks/ticks; only this manifest and documentation.

## Scope and accounting

The existing selected compatibility set is **39 distinct, previously present Godot F6 scenes / 536 expected assertions**. None of these scenes or their script code has been modified. Source of truth: [Stage B CSV](../tools/unified_construction_e3d5c6d_stage_b_compatibility.csv), verified to reference 39 unique scene paths under `res://tests/` at the staging HEAD.

This gate contains:
- **Wave 1 — 12 scenes / 155 checks**: current unified scene 16, accepted prior recovery scene 14, and 10 historically accepted placement/authorization/priority/preview/receiver-autowire supplemental tests totaling 125. These include old tests outside the 61-suite baseline; rerunning them does *not* make them newly written Stage B checks or advance the unique milestone baseline.
- **Wave 2 — 27 scenes / 381 checks**: exactly the previously accepted [E3d5c6c Stage C compatibility manifest](CANCELLED_SITE_RECOVERY_STAGE_C_COMPATIBILITY.md): original drone, finite battery, staging/escrow/provenance, supply and return reservations, physical recovery, dispatch, original Direct Build and cancellation suites. Do not double-count the overlap.
- **Combined targeted result if developer confirms both waves: 39/39 scenes and 536/536 expected checks locally**. It will *not* establish fresh complete 62-suite regression nor manual player-controlled acceptance, and will add **zero new unique checks**.

## Run instructions

1. In VS Code terminal, check `git status --short`; preserve important local edits. Then `git fetch origin`, `git switch main`, `git pull --ff-only origin main`. Avoid force checkout/reset.
2. In Godot 4.6.2 Stable open **each exact scene** from this guide's table under `res://tests/`. Press **F6 Run Current Scene**, not F5. **Run one scene at a time**, in listed order. Do not run a concurrently ticking collection or fabricate a new test runner.
3. Verify each fixture's own final ALL/PASS banner or all expected individual assertions; inspect Debugger for red Parser/assertion errors. Mark one checkbox locally only after that scene passed.
4. **Report Wave 1 12/12 then Wave 2 27/27** along with any failing first line, or report the exact failing scene and first red error immediately. Do not infer further success after the first failure.
5. After BOTH waves pass and the documentation is updated, continue E3d5c6d Stage C separate **real playable F6** using `res://scenes/core/playable_unified_construction_e3d5c6d.tscn` for mouse/keyboard Direct Build, Blueprint authorization, priority, actual physical cancellation/return, generator ON/OFF, finite recharge and unaffected Main.

## Wave 1 — permission/scope/historical placement (12 suites / 155 checks)

| # | Scene under `res://tests/` | Expected | Passed? |
|---:|---|---:|:---:|
| 01 | [`playable_unified_construction_e3d5c6d_stage_a_test.tscn`](../tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn) | 16 | ✓ |
| 02 | [`playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`](../tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn) | 14 | ✓ |
| 03 | [`blueprint_sandbox_mode_test.tscn`](../tests/blueprint_sandbox_mode_test.tscn) | 12 | ✓ |
| 04 | [`timed_storage_placement_test.tscn`](../tests/timed_storage_placement_test.tscn) | 4 | ✓ |
| 05 | [`planned_storage_build_mode_test.tscn`](../tests/planned_storage_build_mode_test.tscn) | 6 | ✓ |
| 06 | [`storage_blueprint_preview_snap_e3c2b_test.tscn`](../tests/storage_blueprint_preview_snap_e3c2b_test.tscn) | 15 | ✓ |
| 07 | [`conveyor_building_placement_snap_test.tscn`](../tests/conveyor_building_placement_snap_test.tscn) | 8 | ✓ |
| 08 | [`build_hotbar_keyboard_integration_test.tscn`](../tests/build_hotbar_keyboard_integration_test.tscn) | 12 | ✓ |
| 09 | [`sandbox_blueprint_authorization_test.tscn`](../tests/sandbox_blueprint_authorization_test.tscn) | 18 | ✓ |
| 10 | [`blueprint_construction_priority_e3d5a_test.tscn`](../tests/blueprint_construction_priority_e3d5a_test.tscn) | 15 | ✓ |
| 11 | [`sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn`](../tests/sandbox_authorization_receiver_autowire_e3d5c5d_test.tscn) | 19 | ✓ |
| 12 | [`blueprint_click_inspection_e3d5c3d2e_test.tscn`](../tests/blueprint_click_inspection_e3d5c3d2e_test.tscn) | 16 | ✓ |
| | **Wave 1 total** | **155** | **ACCEPTED (developer-local)** |

## Wave 2 — drone logistics/power/custody compatibility (27 suites / 381 checks)

| # | Scene under `res://tests/` | Expected | Passed? |
|---:|---|---:|:---:|
| 13 | [`prototype_construction_worker_drone_e3d5c4u_test.tscn`](../tests/prototype_construction_worker_drone_e3d5c4u_test.tscn) | 16 | ☐ |
| 14 | [`prototype_drone_battery_dock_e3d5c4x_test.tscn`](../tests/prototype_drone_battery_dock_e3d5c4x_test.tscn) | 20 | ☐ |
| 15 | [`blueprint_material_staging_e3d5c4c_test.tscn`](../tests/blueprint_material_staging_e3d5c4c_test.tscn) | 16 | ☐ |
| 16 | [`blueprint_physical_staging_e3d5c4d_test.tscn`](../tests/blueprint_physical_staging_e3d5c4d_test.tscn) | 16 | ☐ |
| 17 | [`blueprint_site_staging_ownership_e3d5c4h_test.tscn`](../tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn) | 16 | ☐ |
| 18 | [`blueprint_anchored_receiver_e3d5c4i_test.tscn`](../tests/blueprint_anchored_receiver_e3d5c4i_test.tscn) | 16 | ☐ |
| 19 | [`blueprint_receiver_recovery_audit_e3d5c4j_test.tscn`](../tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn) | 12 | ☐ |
| 20 | [`blueprint_construction_material_escrow_e3d5c2a_test.tscn`](../tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn) | 16 | ☐ |
| 21 | [`drone_storage_discovery_e3d5c5x3_test.tscn`](../tests/drone_storage_discovery_e3d5c5x3_test.tscn) | 12 | ☐ |
| 22 | [`drone_supplier_reservations_e3d5c5x4a_test.tscn`](../tests/drone_supplier_reservations_e3d5c5x4a_test.tscn) | 12 | ☐ |
| 23 | [`drone_return_reservations_e3d5c5x4b_test.tscn`](../tests/drone_return_reservations_e3d5c5x4b_test.tscn) | 14 | ☐ |
| 24 | [`drone_physical_pickup_e3d5c5x5a_test.tscn`](../tests/drone_physical_pickup_e3d5c5x5a_test.tscn) | 12 | ☐ |
| 25 | [`drone_physical_delivery_e3d5c5x5b_test.tscn`](../tests/drone_physical_delivery_e3d5c5x5b_test.tscn) | 13 | ☐ |
| 26 | [`drone_delivered_worker_e3d5c5x5c_test.tscn`](../tests/drone_delivered_worker_e3d5c5x5c_test.tscn) | 16 | ☐ |
| 27 | [`drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn`](../tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn) | 13 | ☐ |
| 28 | [`drone_finite_hub_charging_e3d5c5x7a_test.tscn`](../tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn) | 13 | ☐ |
| 29 | [`drone_cargo_worker_reuse_e3d5c5x7b_test.tscn`](../tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn) | 16 | ☐ |
| 30 | [`drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn`](../tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn) | 12 | ☐ |
| 31 | [`drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn`](../tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn) | 13 | ☐ |
| 32 | [`drone_lost_site_recovery_e3d5c5x7c3_test.tscn`](../tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn) | 14 | ☐ |
| 33 | [`drone_automatic_dispatch_e3d5c5x8a_test.tscn`](../tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn) | 14 | ☐ |
| 34 | [`drone_automatic_lifecycle_e3d5c5x8b_test.tscn`](../tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn) | 15 | ☐ |
| 35 | [`playable_automatic_construction_drone_stage_c_test.tscn`](../tests/playable_automatic_construction_drone_stage_c_test.tscn) | 13 | ☐ |
| 36 | [`playable_direct_build_authorization_e3d5c6b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_test.tscn) | 11 | ☐ |
| 37 | [`playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn) | 14 | ☐ |
| 38 | [`cancelled_site_custody_e3d5c6c_stage_a_test.tscn`](../tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn) | 13 | ☐ |
| 39 | [`cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn`](../tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn) | 13 | ☐ |
| | **Wave 2 total** | **381** | **PENDING** |

## Explicit safeguards

Do not change `scenes/core/main.tscn`, accepted E3d5c6b/E3d5c6c gameplay scenes or tests, old construction/escrow/flight/charging modules, or create additional dispatcher/worker/tick owner. No new resources, power generation, docking research, silos or multi-drone/fleet work. On failure repair only proven regression; rerun failed scene and relevant prior scenes.

**NEXT gate:** After Stage B developer-local acceptance, stage a separate Stage C hands-on unified gameplay checklist and record visible screenshots/manual results. The final combined 62-suite/866-expected-check run remains a later gate and must not be claimed here.
