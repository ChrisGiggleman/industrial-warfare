# E3d5c6f C4A — Isolated acceptance and targeted compatibility

### 2026-11-25 — C4A FULLY ACCEPTED; C4B proposal

Developer confirmed C4A compatibility 40/40 F6 scenes passed locally against 581 manifest-expected sections on 2026-11-25, following isolated 14/14. C4A FULLY ACCEPTED: 41 gate scene runs / 595 associated sections; 40/581 overlap prior accepted coverage. Unique accepted coverage 72 suites / 983 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect assertion logs. C4B awaits explicit implementation approval. [C4B implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C4B_PLAN.md). Documentation-only checkpoint; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved. No C4B gameplay or F6 fixture yet.


Developer confirmed C4A isolated F6 14/14 labeled sections passed locally in Godot against implementation commit 18391041722c4ae2fc4ff4f92645f7930b43f4b0 on 2026-11-25. Cumulative unique accepted coverage 72 suites / 983 expected sections (B4 68/923 + C1 1/12 + C2 1/16 + C3 1/18 + C4A 1/14); last fresh full regression remains B4 68/923. C4A targeted compatibility 40 existing suites / 581 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect individual assertion logs. C4B gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved.

Run each scene using F6, stop on first error. Counts inherited from accepted manifests and labeled sections, not assertion-level logs. All paths verified at implementation commit. Targeted selection emphasizes specialized B2/B3 and C1-C3, shared worker/flight/charging services, power and scheduler readiness, legacy power parking, custody and playable recovery. Includes historical automatic drone and direct-build integrations. Does not repeat every C3 compatibility scene or C4A itself; full regression remains C5. Terminal cancellation and hand-back deferred C4B; dynamic site relocation and automatic rerouting out of scope. No gameplay changes at this checkpoint.

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
| 9 | `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| 10 | `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 |
| 11 | `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 |
| 12 | `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| 13 | `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 |
| 14 | `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 |
| 15 | `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 |
| 16 | `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| 17 | `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| 18 | `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| 19 | `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| 20 | `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| 21 | `construction_power_coverage_e3d5c3a_test.tscn` | 16 |
| 22 | `completed_power_structures_e3d5c3b1_test.tscn` | 16 |
| 23 | `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| 24 | `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 |
| 25 | `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 |
| 26 | `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 |
| 27 | `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| 28 | `drone_automatic_dispatch_e3d5c5x8a_test.tscn` | 14 |
| 29 | `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| 30 | `playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` | 14 |
| 31 | `playable_unified_construction_e3d5c6d_stage_a_test.tscn` | 16 |
| 32 | `playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` | 14 |
| 33 | `cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` | 13 |
| 34 | `cancelled_site_custody_e3d5c6c_stage_a_test.tscn` | 13 |
| 35 | `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 |
| 36 | `playable_automatic_construction_drone_stage_a_test.tscn` | 8 |
| 37 | `playable_automatic_construction_drone_stage_b_test.tscn` | 8 |
| 38 | `playable_automatic_construction_drone_stage_c_test.tscn` | 13 |
| 39 | `playable_direct_build_authorization_e3d5c6b_test.tscn` | 11 |
| 40 | `playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` | 14 |
| | Total | 581 |

Manifest: [CSV](../tools/specialized_drones_e3d5c6f_c4a_compatibility.csv). After all pass record full C4A acceptance and prepare scoped C4B terminal cancellation and recovery hand-back.
