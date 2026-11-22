# Industrial Warfare — Combined automated regression: 61 suites / 850 checks

**Checkpoint: 2026-11-22 — STAGED, NOT YET RUN AS A FRESH COMBINED PASS.**

Godot **4.6.2 Stable**, GDScript, Forward+.
Repository: `ChrisGiggleman/industrial-warfare`, branch `main`.

## Accepted prerequisites (developer-reported local evidence)

- E3d5c6a Building Expansion: 56 unique automated suites / 785 checks, manual 9/9 accepted.
- E3d5c6b Direct Build Authorization: Stage A 11/11 new checks, Stage B 14/14 new checks, their prior targeted compatibility gates accepted, and **Stage C original playable manual 10/10 accepted locally on 2026-11-22**. This new confirmation covers A1–A6, B1–B3, C1 in `docs/DIRECT_BUILD_STAGE_C_MANUAL.md` and was **not assistant-executed**.
- E3d5c6c Cancelled-Site Physical Recovery: Stage A 13/13, Stage B 13/13, Stage C 14/14 new isolated automated checks; Stage C targeted compatibility 27/27 suites / 381/381 overlapping existing checks; Stage C playable manual 10/10 accepted locally.
- Cumulative accepted unique milestone baseline **61 suites / 850 checks**. The suites have been individually accepted in prior milestones, but a **fresh combined 61/850 run on the current main branch is not yet confirmed**.

## Test-set derivation

- [Building Expansion final original 56-suite manifest](../tools/building_expansion_final_regression.csv): 56 suites / 785 checks.
- Add Direct Build E3d5c6b Stage A (**11**), Stage B (**14**).
- Add Cancelled-Site E3d5c6c Stage A (**13**), Stage B (**13**), Stage C (**14**).
- **Total: 56+5 = 61 unique suites; 785+11+14+13+13+14 = 850 unique checks.** All 61 unique scene files were verified present under `res://tests/` in `main` on 2026-11-22; no names were duplicated.

Manifest (single source of truth): [`tools/industrial_warfare_combined_61_suite_regression.csv`](../tools/industrial_warfare_combined_61_suite_regression.csv).

## How to run this gate

1. Make sure your local working tree has no important uncommitted conflicting edits; in VS Code terminal run `git status` and then `git pull --ff-only origin main`.
2. In Godot select each of the exact 61 `res://tests/` scenes below and press **F6 (Run Current Scene)**. Run them **separately in sequence**, not all at once or through a custom invented runner.
3. Inspect **Output** and **Debugger** for each suite. Record its own PASS count and terminal banner. Some historical suites (for example `inventory_trasnfer_test.tscn`) print multiple PASS groups rather than an ALL banner; ensure **all expected checks** are present.
4. Record and report **61/61 scenes and 850/850 checks** only if every existing test passes locally in this fresh combined gate. On any failure stop the acceptance gate and send the **first Debugger error plus preceding PASS lines** to isolate the regression. We will fix narrowly and rerun impacted tests before final acceptance.
5. **Do not** include historical targeted compatibility reruns (27/381, 29/395, etc.) or manual tests in this **unique** 61/850 tally.

## F6 run checklist

| # | Scene path under `res://tests/` | Expected checks | Local run |
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
| | **61 distinct suites** | **850** | **PENDING** |

## Exit / next milestone

After the developer confirms **fresh combined 61/61 suites and 850/850 checks**, update the acceptance record, then stage the **next isolated opt-in construction integration** milestone. Existing Main, original Direct Build, and accepted Stage C recovery scene must remain unchanged until separately scoped gameplay integration and tests are accepted. Preserve immutable canceled-site staging provenance, no instant material refunds, real Storage destination capacity, finite physical drone flights/battery charging, player authorization boundaries, and single-drone process ownership.

**Current checkpoint:** E3d5c6b manual 10/10 accepted; E3d5c6c manual 10/10 accepted; fresh combined 61/850 **PENDING**.
