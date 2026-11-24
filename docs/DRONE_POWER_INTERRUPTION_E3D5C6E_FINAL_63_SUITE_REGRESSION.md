# E3d5c6e — Final fresh full 63-suite / 880-expected-check automated regression

**2026-11-24 — STAGED ONLY. THIS COMBINED 63-SUITE REGRESSION HAS NOT BEEN RUN.** The developer has already reported success for E3d5c6e Stage A 14/14 isolated, Stage B Wave 1 15/15 and Wave 2 27/27 targeted compatibility (42/42 suites total, 584 manifest-expected rerun checks), and Stage C real playable 10/10. **E3d5c6e cannot be marked fully accepted before this separate fresh final gate.**

## Source of exact suite order and count

- Original [accepted fresh E3d5c6d full-baseline manifest](../tools/unified_construction_e3d5c6d_final_62_suite_regression.csv) = **62 distinct Godot F6 scenes / 866 manifest-expected checks**; developer confirmed all 62 locally before the E3d5c6e gameplay changes.
- Add one **new** isolated `playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` (14 expected check groups, developer-local accepted in Stage A) **exactly once** as scene **#63**.
- New canonical [63-scene final manifest](../tools/drone_power_interruption_e3d5c6e_final_63_suite_regression.csv): **63 distinct files, 880 expected checks**, validated count/sum. Preserves original 62 scene order exactly; no duplicate scene names. The previously rerun 42/584 targeted compatibility checks are already included in the overall inventory where applicable and **must not be added again**. Ten manual actions are also not automated checks.

## Developer-local Godot 4.6.2 execution

1. Verify `git status --short` in VS Code and preserve any local edits. Safely update `main` using `git fetch origin`, `git switch main`, `git pull --ff-only origin main`, without hard resets or force operations.
2. Run **each individual existing scene** using Godot **F6 / Run Current Scene**, not F5/Run Project. All paths follow `res://tests/<filename>`. Let the scene finish, check Output and Debugger for actual PASS messages/errors, then advance to the next scene. Do not use a made-up batch runner.
3. Use the mandatory [one-scene-at-a-time interactive Copy path / Previous / Next navigator](GODOT_F6_COPY_NAVIGATOR.md), showing **TEST N OF 63**, expected check count, progress indicator and one-click exact scene path for each.
4. If **any** fixture has a parser/assertion/runtime error or never reaches its accepted end banner, **stop**, record exact failing scene and first red error/source line/last PASS label, and report it; do not claim 63/63 or proceed to closeout. Narrow fixes should preserve all accepted scenes, one original dispatcher and physical material custody.
5. On full completion, report **"E3d5c6e final regression: All 63 passed"**. Only then record a new **developer-local fresh 63/63** acceptance against **880 manifest-expected checks** (not 880 independently audited per-check transcript unless such output is actually supplied) in HANDOFF, DEVLOG, ROADMAP, DRONE_CONSTRUCTION_LOGISTICS and this final guide. Close E3d5c6e **only after** this result, leaving Main unaffected.

## Full scene list — all PENDING final fresh verification

| # | Exact F6 scene under `res://tests/` | Expected checks | Developer-local final |
|---:|---|---:|:---:|
| 01 | [`inventory_trasnfer_test.tscn`](../tests/inventory_trasnfer_test.tscn) | 4 | ☐ |
| 02 | [`item_port_transfer_test.tscn`](../tests/item_port_transfer_test.tscn) | 7 | ☐ |
| 03 | [`manufacturing_transaction_test.tscn`](../tests/manufacturing_transaction_test.tscn) | 9 | ☐ |
| 04 | [`recipe_output_capacity_test.tscn`](../tests/recipe_output_capacity_test.tscn) | 11 | ☐ |
| 05 | [`conveyor_automatic_loading_test.tscn`](../tests/conveyor_automatic_loading_test.tscn) | 10 | ☐ |
| 06 | [`conveyor_automatic_unloading_test.tscn`](../tests/conveyor_automatic_unloading_test.tscn) | 9 | ☐ |
| 07 | [`conveyor_connected_transport_test.tscn`](../tests/conveyor_connected_transport_test.tscn) | 7 | ☐ |
| 08 | [`conveyor_splitter_test.tscn`](../tests/conveyor_splitter_test.tscn) | 10 | ☐ |
| 09 | [`conveyor_merger_test.tscn`](../tests/conveyor_merger_test.tscn) | 10 | ☐ |
| 10 | [`conveyor_physical_only_conservation_test.tscn`](../tests/conveyor_physical_only_conservation_test.tscn) | 9 | ☐ |
| 11 | [`timed_storage_conveyor_delivery_test.tscn`](../tests/timed_storage_conveyor_delivery_test.tscn) | 6 | ☐ |
| 12 | [`blueprint_construction_material_escrow_e3d5c2a_test.tscn`](../tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn) | 16 | ☐ |
| 13 | [`unified_receiver_consolidation_e3d5c5v_test.tscn`](../tests/unified_receiver_consolidation_e3d5c5v_test.tscn) | 56 | ☐ |
| 14 | [`playable_construction_logistics_e3d5c5w_test.tscn`](../tests/playable_construction_logistics_e3d5c5w_test.tscn) | 13 | ☐ |
| 15 | [`playable_construction_power_e3d5c5x1_test.tscn`](../tests/playable_construction_power_e3d5c5x1_test.tscn) | 9 | ☐ |
| 16 | [`playable_construction_drone_e3d5c5x2_test.tscn`](../tests/playable_construction_drone_e3d5c5x2_test.tscn) | 11 | ☐ |
| 17 | [`drone_storage_discovery_e3d5c5x3_test.tscn`](../tests/drone_storage_discovery_e3d5c5x3_test.tscn) | 12 | ☐ |
| 18 | [`drone_supplier_reservations_e3d5c5x4a_test.tscn`](../tests/drone_supplier_reservations_e3d5c5x4a_test.tscn) | 12 | ☐ |
| 19 | [`world_salvage_destruction_test.tscn`](../tests/world_salvage_destruction_test.tscn) | 12 | ☐ |
| 20 | [`destruction_cargo_recovery_test.tscn`](../tests/destruction_cargo_recovery_test.tscn) | 12 | ☐ |
| 21 | [`drone_return_reservations_e3d5c5x4b_test.tscn`](../tests/drone_return_reservations_e3d5c5x4b_test.tscn) | 14 | ☐ |
| 22 | [`prototype_construction_worker_drone_e3d5c4u_test.tscn`](../tests/prototype_construction_worker_drone_e3d5c4u_test.tscn) | 16 | ☐ |
| 23 | [`prototype_drone_worker_readiness_e3d5c4v_test.tscn`](../tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn) | 21 | ☐ |
| 24 | [`prototype_construction_drone_fleet_e3d5c4w_test.tscn`](../tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn) | 21 | ☐ |
| 25 | [`prototype_drone_battery_dock_e3d5c4x_test.tscn`](../tests/prototype_drone_battery_dock_e3d5c4x_test.tscn) | 20 | ☐ |
| 26 | [`prototype_construction_drone_reuse_e3d5c4y_test.tscn`](../tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn) | 20 | ☐ |
| 27 | [`prototype_construction_drone_tick_e3d5c4z_test.tscn`](../tests/prototype_construction_drone_tick_e3d5c4z_test.tscn) | 20 | ☐ |
| 28 | [`sandbox_construction_drone_bridge_e3d5c5a_test.tscn`](../tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn) | 20 | ☐ |
| 29 | [`drone_physical_pickup_e3d5c5x5a_test.tscn`](../tests/drone_physical_pickup_e3d5c5x5a_test.tscn) | 12 | ☐ |
| 30 | [`blueprint_material_staging_e3d5c4c_test.tscn`](../tests/blueprint_material_staging_e3d5c4c_test.tscn) | 16 | ☐ |
| 31 | [`blueprint_physical_staging_e3d5c4d_test.tscn`](../tests/blueprint_physical_staging_e3d5c4d_test.tscn) | 16 | ☐ |
| 32 | [`blueprint_site_staging_ownership_e3d5c4h_test.tscn`](../tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn) | 16 | ☐ |
| 33 | [`blueprint_anchored_receiver_e3d5c4i_test.tscn`](../tests/blueprint_anchored_receiver_e3d5c4i_test.tscn) | 16 | ☐ |
| 34 | [`blueprint_owned_readiness_e3d5c4r_test.tscn`](../tests/blueprint_owned_readiness_e3d5c4r_test.tscn) | 18 | ☐ |
| 35 | [`blueprint_receiver_recovery_audit_e3d5c4j_test.tscn`](../tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn) | 12 | ☐ |
| 36 | [`drone_physical_delivery_e3d5c5x5b_test.tscn`](../tests/drone_physical_delivery_e3d5c5x5b_test.tscn) | 13 | ☐ |
| 37 | [`construction_readiness_coordinator_e3d5c3c1_test.tscn`](../tests/construction_readiness_coordinator_e3d5c3c1_test.tscn) | 18 | ☐ |
| 38 | [`blueprint_construction_readiness_e3d5c1_test.tscn`](../tests/blueprint_construction_readiness_e3d5c1_test.tscn) | 15 | ☐ |
| 39 | [`drone_delivered_worker_e3d5c5x5c_test.tscn`](../tests/drone_delivered_worker_e3d5c5x5c_test.tscn) | 16 | ☐ |
| 40 | [`drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn`](../tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn) | 13 | ☐ |
| 41 | [`construction_power_coverage_e3d5c3a_test.tscn`](../tests/construction_power_coverage_e3d5c3a_test.tscn) | 16 | ☐ |
| 42 | [`completed_power_structures_e3d5c3b1_test.tscn`](../tests/completed_power_structures_e3d5c3b1_test.tscn) | 16 | ☐ |
| 43 | [`finite_construction_power_e3d5c3b2_test.tscn`](../tests/finite_construction_power_e3d5c3b2_test.tscn) | 18 | ☐ |
| 44 | [`drone_finite_hub_charging_e3d5c5x7a_test.tscn`](../tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn) | 13 | ☐ |
| 45 | [`drone_cargo_worker_reuse_e3d5c5x7b_test.tscn`](../tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn) | 16 | ☐ |
| 46 | [`drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn`](../tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn) | 12 | ☐ |
| 47 | [`drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn`](../tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn) | 13 | ☐ |
| 48 | [`drone_lost_site_recovery_e3d5c5x7c3_test.tscn`](../tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn) | 14 | ☐ |
| 49 | [`drone_automatic_dispatch_e3d5c5x8a_test.tscn`](../tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn) | 14 | ☐ |
| 50 | [`drone_automatic_lifecycle_e3d5c5x8b_test.tscn`](../tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn) | 15 | ☐ |
| 51 | [`playable_automatic_construction_drone_stage_a_test.tscn`](../tests/playable_automatic_construction_drone_stage_a_test.tscn) | 8 | ☐ |
| 52 | [`playable_automatic_construction_drone_stage_b_test.tscn`](../tests/playable_automatic_construction_drone_stage_b_test.tscn) | 8 | ☐ |
| 53 | [`playable_automatic_construction_drone_stage_c_test.tscn`](../tests/playable_automatic_construction_drone_stage_c_test.tscn) | 13 | ☐ |
| 54 | [`playable_construction_building_expansion_e3d5c6a_test.tscn`](../tests/playable_construction_building_expansion_e3d5c6a_test.tscn) | 8 | ☐ |
| 55 | [`playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn`](../tests/playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn) | 12 | ☐ |
| 56 | [`playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn`](../tests/playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn) | 11 | ☐ |
| 57 | [`playable_direct_build_authorization_e3d5c6b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_test.tscn) | 11 | ☐ |
| 58 | [`playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn`](../tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn) | 14 | ☐ |
| 59 | [`cancelled_site_custody_e3d5c6c_stage_a_test.tscn`](../tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn) | 13 | ☐ |
| 60 | [`cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn`](../tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn) | 13 | ☐ |
| 61 | [`playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn`](../tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn) | 14 | ☐ |
| 62 | [`playable_unified_construction_e3d5c6d_stage_a_test.tscn`](../tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn) | 16 | ☐ |
| 63 | [`playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn`](../tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn) | 14 | ☐ |
| | **63 distinct suites** | **880** | **PENDING** |

## Post-gate

After developer confirms passing 63/63, record full E3d5c6e acceptance and prepare a new-chat handoff. Drone specialization, Storage docking, ore variety and coal/solar/wind power remain separate future approved-plan candidates, not part of this already isolated blackout-worker parking milestone.
