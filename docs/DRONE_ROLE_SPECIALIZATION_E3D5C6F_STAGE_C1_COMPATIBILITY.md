# E3d5c6f C1 — Isolated acceptance and targeted compatibility

### 2026-11-25 — E3d5c6f C1 FULLY ACCEPTED; C2 proposal

Developer confirmed C1 targeted compatibility 22/22 F6 scenes passed locally against 295 manifest-expected sections on 2026-11-25, following isolated 12/12 acceptance. C1 FULLY ACCEPTED: 23 gate scene runs / 307 associated expected sections, of which 22/295 overlap B4. Unique accepted coverage 69 suites / 935 expected sections; last fresh full B4 68/923 remains distinct. Assistant did not run Godot or inspect individual assertion logs. Next C2 scoped plan awaits explicit implementation approval. [C2 implementation plan](DRONE_ROLE_SPECIALIZATION_E3D5C6F_STAGE_C2_PLAN.md). Documentation-only checkpoint; Main, all previously accepted scenes/tests, local edits and draft PR #1 preserved. No C2 gameplay code or new F6 fixture yet.


Developer confirmed all 12/12 labeled C1 sections passed locally in Godot against implementation commit acec11e64df4d9987a8156e63bc68f7ff59ad56f. Assistant did not execute Godot. Cumulative unique accepted coverage 69 suites / 935 expected sections (68/923 historical fresh B4 + 1/12 C1); no fresh full 69-suite regression claimed. Targeted compatibility 22 existing scenes / 295 manifest-expected sections PENDING; these overlap B4 and must not inflate unique coverage. C2 remains gated on developer-local compatibility acceptance. Main, accepted scenes/tests, local edits and unmerged draft PR #1 preserved.

Run each scene in Godot F6, stop on first error. Counts inherited from B4 manifest, not assertion-level logs. All paths verified at implementation commit. No new gameplay code in this checkpoint.

| Order | Scene under res://tests/ | Expected sections |
|---:|---|---:|
| 1 | `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| 2 | `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| 3 | `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| 4 | `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| 5 | `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| 6 | `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 |
| 7 | `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| 8 | `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| 9 | `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 |
| 10 | `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| 11 | `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| 12 | `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| 13 | `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| 14 | `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| 15 | `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| 16 | `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| 17 | `playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` | 14 |
| 18 | `specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` | 6 |
| 19 | `specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` | 7 |
| 20 | `specialized_drone_single_owner_e3d5c6f_b1_test.tscn` | 9 |
| 21 | `specialized_drone_logistics_e3d5c6f_b2_test.tscn` | 9 |
| 22 | `specialized_drone_builder_e3d5c6f_b3_test.tscn` | 12 |
| | Total | 295 |

Manifest: [CSV](../tools/specialized_drones_e3d5c6f_c1_compatibility.csv). The selection covers shared charging, supplier and return reservations, physical flight, pickup/delivery, worker reuse, cancellation and blackout, and all five accepted specialization fixtures. C1 isolated scene already passed; not counted as a compatibility rerun. After all pass, record acceptance before C2 loaded cargo recovery.
