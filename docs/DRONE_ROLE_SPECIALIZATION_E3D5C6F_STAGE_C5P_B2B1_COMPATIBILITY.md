# C5P-B2b-1 targeted compatibility gate

2026-11-27: Developer confirmed C5P-B2b-1 isolated F6 all 12/12 labeled sections passed locally in Godot against expected runtime ba5d179cce1bf01a2580d16036183b29724920df; local HEAD/logs not independently inspected. Cumulative historical unique acceptance 76 suites / 1030 sections, not fresh full regression. Targeted compatibility 46 suites / 645 expected sections pending in 4 waves. B2b-2/B2b-3/B2c/B3 blocked pending acceptance and respective approval. No gameplay, existing tests, historical manifest or Main changes.

Selection: manifest drone suites, cancellation custody/recovery, unified construction, readiness coordinator, owned readiness, material escrow, finite construction power, and newly accepted B1 and B2a fixtures. Broad targeted scope because shared worker, supplier and docking components and specialized logistics controller changed. Counts are manifest-expected or new fixture labeled sections, not individual assertion counts. Remaining historical suites deferred to C5P-C full fresh regression. Stop on error; no acceptance until developer confirms.

## Wave 1 — 15 suites / 246 expected sections

- `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` — 16
- `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` — 11
- `res://tests/drone_storage_discovery_e3d5c5x3_test.tscn` — 12
- `res://tests/drone_supplier_reservations_e3d5c5x4a_test.tscn` — 12
- `res://tests/drone_return_reservations_e3d5c5x4b_test.tscn` — 14
- `res://tests/prototype_construction_worker_drone_e3d5c4u_test.tscn` — 16
- `res://tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn` — 21
- `res://tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn` — 21
- `res://tests/prototype_drone_battery_dock_e3d5c4x_test.tscn` — 20
- `res://tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn` — 20
- `res://tests/prototype_construction_drone_tick_e3d5c4z_test.tscn` — 20
- `res://tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn` — 20
- `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` — 12
- `res://tests/blueprint_owned_readiness_e3d5c4r_test.tscn` — 18
- `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn` — 13

## Wave 2 — 15 suites / 204 expected sections

- `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` — 18
- `res://tests/drone_delivered_worker_e3d5c5x5c_test.tscn` — 16
- `res://tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` — 13
- `res://tests/finite_construction_power_e3d5c3b2_test.tscn` — 18
- `res://tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn` — 13
- `res://tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` — 16
- `res://tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` — 12
- `res://tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` — 13
- `res://tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn` — 14
- `res://tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn` — 14
- `res://tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn` — 15
- `res://tests/playable_automatic_construction_drone_stage_a_test.tscn` — 8
- `res://tests/playable_automatic_construction_drone_stage_b_test.tscn` — 8
- `res://tests/playable_automatic_construction_drone_stage_c_test.tscn` — 13
- `res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn` — 13

## Wave 3 — 15 suites / 184 expected sections

- `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` — 13
- `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` — 14
- `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn` — 16
- `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` — 14
- `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` — 6
- `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` — 7
- `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` — 9
- `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` — 9
- `res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn` — 12
- `res://tests/specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` — 12
- `res://tests/specialized_drone_loaded_cancel_e3d5c6f_c2_test.tscn` — 16
- `res://tests/specialized_drone_staging_recovery_e3d5c6f_c3_test.tscn` — 18
- `res://tests/specialized_drone_builder_blackout_e3d5c6f_c4a_test.tscn` — 14
- `res://tests/specialized_drone_builder_cancel_e3d5c6f_c4b_test.tscn` — 14
- `res://tests/specialized_drone_battery_independent_e3d5c6f_c5p_b1_test.tscn` — 10

## Wave 4 — 1 suites / 11 expected sections

- `res://tests/specialized_drone_power_authorization_e3d5c6f_c5p_b2a_test.tscn` — 11
