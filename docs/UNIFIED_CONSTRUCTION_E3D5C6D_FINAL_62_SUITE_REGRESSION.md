# E3d5c6d — Final fresh automated regression: 62 suites / 866 expected checks

**2026-11-23 — STAGED FOR DEVELOPER-LOCAL F6, NOT YET RUN.** E3d5c6d Stage A 16/16 isolated, Stage B 39/39 targeted compatibility (536 manifest-expected rerun checks), and Stage C 10/10 manual *are* accepted by developer local Godot report. **This is a distinct final whole-baseline regression, not an already accepted run.**

## Exact derivation and source

- Previous **fresh full 61/61-suite pass** on 2026-11-22 covered **850 expected checks** in [older historical manifest](../tools/industrial_warfare_combined_61_suite_regression.csv).
- One **new** unified Stage A isolated `playable_unified_construction_e3d5c6d_stage_a_test.tscn` with **16 accepted checks**, not already in the older 61.
- **62 unique F6 scenes / 866 expected checks**. No duplicate scene paths; all existing 61 remain in identical manifest order, new isolated scene #62 appended. [Canonical new 62-scene manifest](../tools/unified_construction_e3d5c6d_final_62_suite_regression.csv).
- The Stage B **39/536 targeted reruns**, ten manual checks and historical supplemental suites are NOT additional unique check counts.

## Safeguards / execution procedure

1. VS Code: check `git status --short`; preserve uncommitted work. Run `git fetch origin`, `git switch main`, `git pull --ff-only origin main` (no force reset).
2. Godot 4.6.2 Stable: choose each exact scene from the ordered list below, separately in FileSystem, and press **F6 (Current Scene)**. **Do not press F5** and do not add another tick/test runner.
3. Follow the [preferred interactive one-test-at-a-time Copy navigator](GODOT_F6_COPY_NAVIGATOR.md): TEST N OF 62, expected checks, Copy scene path, Previous/Next. Copy the verified `res://tests/<filename>` path for the selected test.
4. Inspect Output and Debugger; each suite must show its expected passing checks or final banner. At first red error or missing assertion, STOP and capture the exact scene, first error, and preceding PASS lines. Do not assume remaining suites passed.
5. Report **all 62/62 suites passed** only after running every individual scene. The 866 figure is the checked sum of expected checks in the manifest, not a separately reviewed per-assertion transcript unless provided. This is the last gate before E3d5c6d milestone closeout and discussion of independent drone parking design.

## Complete F6 scene order

| # | Scene (under `res://tests/`) | Expected checks | Local F6 |
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
| | **62 unique suites** | **866** | **PENDING** |

## Next

After developer confirms full combined 62/62 local pass, mark E3d5c6d fully accepted, update HANDOFF, DEVLOG, ROADMAP, DRONE_CONSTRUCTION_LOGISTICS and this guide. Maintain default Main unchanged. Then obtain explicit separate architectural authorization before implementing proposed worker-drone Hub parking on power loss or split logistics vs construction drone roles; [design document](DRONE_POWER_INTERRUPTION_DESIGN.md). No game code changes as part of this document-only checkpoint.
