# C5P-B1 targeted compatibility gate

2026-11-27: Developer confirmed C5P-B1 compatibility Wave 2 all 15/15 F6 scenes passed locally in Godot against 199 manifest-expected sections. Targeted fresh compatibility progress 30/43 suites and 445/606 sections; isolated 1/10 remains accepted separately; cumulative historical unique coverage unchanged at 74/1007. Runtime expected 1b3908f plus documentation-only checkpoints; local HEAD and individual logs not independently inspected. Final Wave 3 (13/161) pending. No gameplay, existing tests, manifest or Main changes; C5P-B2/B3 not started.

2026-11-27: Developer confirmed C5P-B1 compatibility Wave 1 all 15/15 F6 scenes passed locally in Godot against 246 manifest-expected sections. Targeted fresh compatibility progress 15/43 suites and 246/606 sections; isolated 1/10 remains accepted separately; cumulative historical unique coverage unchanged at 74/1007. Runtime expected 1b3908f plus documentation-only checkpoints; local HEAD and individual logs not independently inspected. Wave 2 (15/199) and Wave 3 (13/161) pending. No gameplay, existing tests, manifest or Main changes; C5P-B2/B3 not started.

2026-11-27: Developer confirmed all 10/10 isolated C5P-B1 F6 labeled sections passed locally after freed-object guard correction at 1b3908f7e23820cbea8d69c78742c3a30fdc1578 (local HEAD and logs not independently inspected). Isolated acceptance only. Historical 73/997 plus new isolated 1/10 = cumulative unique 74/1007, not fresh full regression. Targeted compatibility gate: 43 existing suites / 606 manifest-expected sections in 3 waves; all pending. No gameplay, existing tests, historical manifest or Main changes. B2/B3 remain blocked pending B1 compatibility acceptance and separate implementation approval.

Selection: existing manifest suites with drone, cancelled-site, unified-construction, readiness coordinator, owned readiness or material escrow in scene name. This deliberately broad targeted selection covers legacy worker, battery, dock, discovery, reservations, dispatch, cancellation, specialized roles and linked integration; remaining historical suites deferred to C5P-C full regression. Counts are manifest labels, not independent assertions. Run each F6 on consistent runtime; stop on errors.

## Wave 1 — 15 suites / 246 sections

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

## Wave 2 — 15 suites / 199 sections

- `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` — 18
- `res://tests/drone_delivered_worker_e3d5c5x5c_test.tscn` — 16
- `res://tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` — 13
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
- `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` — 13

## Wave 3 — 13 suites / 161 sections

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
