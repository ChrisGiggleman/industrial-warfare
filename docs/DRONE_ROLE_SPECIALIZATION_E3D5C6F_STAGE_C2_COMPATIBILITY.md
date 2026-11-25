# E3d5c6f C2 — Isolated acceptance and targeted compatibility

Developer confirmed C2 isolated F6 16/16 labeled sections passed locally in Godot against implementation commit bb666235f575bad4c83cdde90a7d378c9c25e4ba on 2026-11-25. Cumulative unique accepted coverage 70 suites / 951 expected sections (B4 68/923 + C1 1/12 + C2 1/16); last fresh full regression remains B4 68/923. C2 targeted compatibility 27 existing suites / 356 manifest-expected sections PENDING; reruns overlap accepted coverage. Assistant did not run Godot or inspect assertion logs. C3 gated on local compatibility acceptance; Main, prior scenes/tests, local edits and unmerged draft PR #1 preserved.

Run each scene with F6, stop on first error. Counts inherited from B4/C1, not assertion-level logs. All scene paths verified at implementation commit. The x6 canceled cargo recovery fixture includes actual destination deletion, not included in the new C2 fixture. Selection retains the 22 C1 compatibility scenes and adds inventory transfer, escrow, staging ownership, historical loaded cargo recovery and accepted C1 isolation. C2 itself already passed; not counted as a compatibility rerun.

| Order | Scene under res://tests/ | Expected sections |
|---:|---|---:|
| 1 | `inventory_trasnfer_test.tscn` | 4 |
| 2 | `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 |
| 3 | `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 |
| 4 | `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 |
| 5 | `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 |
| 6 | `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 |
| 7 | `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 |
| 8 | `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 |
| 9 | `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 |
| 10 | `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 |
| 11 | `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 |
| 12 | `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 |
| 13 | `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 |
| 14 | `finite_construction_power_e3d5c3b2_test.tscn` | 18 |
| 15 | `drone_finite_hub_charging_e3d5c5x7a_test.tscn` | 13 |
| 16 | `drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` | 16 |
| 17 | `drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` | 12 |
| 18 | `drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` | 13 |
| 19 | `drone_lost_site_recovery_e3d5c5x7c3_test.tscn` | 14 |
| 20 | `drone_automatic_lifecycle_e3d5c5x8b_test.tscn` | 15 |
| 21 | `playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` | 14 |
| 22 | `specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` | 6 |
| 23 | `specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` | 7 |
| 24 | `specialized_drone_single_owner_e3d5c6f_b1_test.tscn` | 9 |
| 25 | `specialized_drone_logistics_e3d5c6f_b2_test.tscn` | 9 |
| 26 | `specialized_drone_builder_e3d5c6f_b3_test.tscn` | 12 |
| 27 | `specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` | 12 |
| | Total | 356 |

Manifest: [CSV](../tools/specialized_drones_e3d5c6f_c2_compatibility.csv). After all pass, record full C2 acceptance and prepare C3 staging and escrow physical recovery proposal. No gameplay changes at this checkpoint.
