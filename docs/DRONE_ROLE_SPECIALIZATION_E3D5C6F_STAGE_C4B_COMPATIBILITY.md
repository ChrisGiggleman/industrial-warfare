# E3d5c6f C4B — Isolated acceptance and targeted compatibility

Developer confirmed C4B isolated F6 14/14 labeled sections passed locally in Godot against implementation commit bed2c8dd4189d5fc1c2a9572134e5ef761a1723c on 2026-11-25. Cumulative unique accepted coverage 73 suites / 997 expected sections (B4 68/923 + C1 1/12 + C2 1/16 + C3 1/18 + C4A 1/14 + C4B 1/14); last fresh full regression remains B4 68/923. C4B targeted compatibility 53 existing suites / 751 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect individual assertion logs. C5 gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved.

Run each scene with F6, stop on first error. Counts inherited from accepted manifests and labeled sections, not assertion-level logs. All paths verified at implementation commit. Selection is the deduplicated union of C3 and C4A compatibility manifests plus C4A isolated fixture. C4B itself already passed and is not counted as a rerun. This expanded gate covers shared flight, worker, escrow, staging, reservation, recovery and role authority paths; full fresh regression remains C5. Explicit controller cancellation only; retired builder remains DOCKED and disabled, with charging history retained; no generalized reroute, dynamic relocation, source destruction or Main integration. No gameplay changes at this checkpoint.

| Order | Scene under res://tests/ | Expected sections |
|---:|---|---:|
| 1 | `specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` | 6 |
| 2 | `specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` | 7 |
| 3 | `specialized_drone_single_owner_e3d5c6f_b1_test.tscn` | 9 |
| 4 | `specialized_drone_logistics_e3d5c6f_b2_test.tscn` | 9 |
| 5 | `specialized_drone_builder_e3d5c6f_b3_test.tscn` | 12 |
| 6 | `specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` | 12 |
| 7 | `specialized_drone_loaded_cancel_e3d5c6f_c2_test.tscn` | 16 |
| 8 | `specialized_drone_staging_recovery_e3d5c6f_c3_test.tscn` | 18 |
| 9 | `specialized_drone_builder_blackout_e3d5c6f_c4a_test.tscn` | 14 |
| 10 | `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| 11 | `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 |
| 12 | `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 |
| 13 | `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| 14 | `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 |
| 15 | `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 |
| 16 | `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| 17 | `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| 18 | `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| 19 | `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| 20 | `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| 21 | `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| 22 | `construction_power_coverage_e3d5c3a_test.tscn` | 16 |
| 23 | `completed_power_structures_e3d5c3b1_test.tscn` | 16 |
| 24 | `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| 25 | `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 |
| 26 | `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 |
| 27 | `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 |
| 28 | `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| 29 | `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| 30 | `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| 31 | `playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` | 14 |
| 32 | `playable_unified_construction_e3d5c6d_stage_a_test.tscn` | 16 |
| 33 | `playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` | 14 |
| 34 | `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` | 13 |
| 35 | `cancelled_site_custody_e3d5c6c_stage_a_test.tscn` | 13 |
| 36 | `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 |
| 37 | `playable_automatic_construction_drone_stage_a_test.tscn` | 8 |
| 38 | `playable_automatic_construction_drone_stage_b_test.tscn` | 8 |
| 39 | `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| 40 | `playable_direct_build_authorization_e3d5c6b_test.tscn` | 11 |
| 41 | `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` | 14 |
| 42 | `blueprint_material_staging_e3d5c4c_test.tscn` | 16 |
| 43 | `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 |
| 44 | `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 |
| 45 | `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 |
| 46 | `inventory_trasnfer_test.tscn` | 4 |
| 47 | `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 |
| 48 | `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| 49 | `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| 50 | `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| 51 | `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| 52 | `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| 53 | `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| | Total | 751 |

Manifest: [CSV](../tools/specialized_drones_e3d5c6f_c4b_compatibility.csv). After all pass, record full C4B acceptance and prepare C5 fresh full regression and manual playable verification.
