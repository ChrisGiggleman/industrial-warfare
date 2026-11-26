# E3d5c6f C5 — Fresh regression and manual playable verification

Developer confirmed C4B compatibility 53/53 F6 scenes passed locally against 751 manifest-expected sections on 2026-11-25, following isolated 14/14. C4B FULLY ACCEPTED: 54 gate scene runs / 765 associated sections; compatibility overlaps prior accepted coverage. Unique accepted coverage 73 suites / 997 expected sections; last fresh full regression B4 68/923. Assistant did not run Godot or inspect assertion logs. C5A fresh full 73/997 regression PENDING. C5B manual playable verification requires a separately approved isolated harness; existing specialized scene is inert B1 by default, has no player-facing controls or camera, and B2/B3/C stages require explicit fixture setup and manual ticks. No C5 gameplay or harness implementation yet; no manual acceptance.

## C5A — fresh regression

All paths verified at ab589e0d356d3671e05f01276675c752e8618c2b; B4 manifest unchanged and C1,C2,C3,C4A,C4B appended to wave 4. No previous pass counts as fresh. Run F6 for each scene and stop on any failure; report exact scene/error. Record each wave locally against manifest counts. Counts are labeled sections, not independent assertion logs. If gameplay changes after a wave, record changed revision and rerun impacted coverage; fresh final baseline requires consistent runtime revision.

| Wave | Scenes | Expected sections |
|---|---:|---:|
| 1 | 20 | 245 |
| 2 | 20 | 333 |
| 3 | 20 | 258 |
| 4 | 13 | 161 |
| Total | 73 | 997 |

[Manifest](../tools/specialized_drones_e3d5c6f_stage_c5_73_suite_regression.csv)

1. Wave 1 — `res://tests/inventory_trasnfer_test.tscn` (4)
2. Wave 1 — `res://tests/item_port_transfer_test.tscn` (7)
3. Wave 1 — `res://tests/manufacturing_transaction_test.tscn` (9)
4. Wave 1 — `res://tests/recipe_output_capacity_test.tscn` (11)
5. Wave 1 — `res://tests/conveyor_automatic_loading_test.tscn` (10)
6. Wave 1 — `res://tests/conveyor_automatic_unloading_test.tscn` (9)
7. Wave 1 — `res://tests/conveyor_connected_transport_test.tscn` (7)
8. Wave 1 — `res://tests/conveyor_splitter_test.tscn` (10)
9. Wave 1 — `res://tests/conveyor_merger_test.tscn` (10)
10. Wave 1 — `res://tests/conveyor_physical_only_conservation_test.tscn` (9)
11. Wave 1 — `res://tests/timed_storage_conveyor_delivery_test.tscn` (6)
12. Wave 1 — `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` (16)
13. Wave 1 — `res://tests/unified_receiver_consolidation_e3d5c5v_test.tscn` (56)
14. Wave 1 — `res://tests/playable_construction_logistics_e3d5c5w_test.tscn` (13)
15. Wave 1 — `res://tests/playable_construction_power_e3d5c5x1_test.tscn` (9)
16. Wave 1 — `res://tests/playable_construction_drone_e3d5c5x2_test.tscn` (11)
17. Wave 1 — `res://tests/drone_storage_discovery_e3d5c5x3_test.tscn` (12)
18. Wave 1 — `res://tests/drone_supplier_reservations_e3d5c5x4a_test.tscn` (12)
19. Wave 1 — `res://tests/world_salvage_destruction_test.tscn` (12)
20. Wave 1 — `res://tests/destruction_cargo_recovery_test.tscn` (12)
21. Wave 2 — `res://tests/drone_return_reservations_e3d5c5x4b_test.tscn` (14)
22. Wave 2 — `res://tests/prototype_construction_worker_drone_e3d5c4u_test.tscn` (16)
23. Wave 2 — `res://tests/prototype_drone_worker_readiness_e3d5c4v_test.tscn` (21)
24. Wave 2 — `res://tests/prototype_construction_drone_fleet_e3d5c4w_test.tscn` (21)
25. Wave 2 — `res://tests/prototype_drone_battery_dock_e3d5c4x_test.tscn` (20)
26. Wave 2 — `res://tests/prototype_construction_drone_reuse_e3d5c4y_test.tscn` (20)
27. Wave 2 — `res://tests/prototype_construction_drone_tick_e3d5c4z_test.tscn` (20)
28. Wave 2 — `res://tests/sandbox_construction_drone_bridge_e3d5c5a_test.tscn` (20)
29. Wave 2 — `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn` (12)
30. Wave 2 — `res://tests/blueprint_material_staging_e3d5c4c_test.tscn` (16)
31. Wave 2 — `res://tests/blueprint_physical_staging_e3d5c4d_test.tscn` (16)
32. Wave 2 — `res://tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn` (16)
33. Wave 2 — `res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` (16)
34. Wave 2 — `res://tests/blueprint_owned_readiness_e3d5c4r_test.tscn` (18)
35. Wave 2 — `res://tests/blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` (12)
36. Wave 2 — `res://tests/drone_physical_delivery_e3d5c5x5b_test.tscn` (13)
37. Wave 2 — `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` (18)
38. Wave 2 — `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn` (15)
39. Wave 2 — `res://tests/drone_delivered_worker_e3d5c5x5c_test.tscn` (16)
40. Wave 2 — `res://tests/drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` (13)
41. Wave 3 — `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16)
42. Wave 3 — `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (16)
43. Wave 3 — `res://tests/finite_construction_power_e3d5c3b2_test.tscn` (18)
44. Wave 3 — `res://tests/drone_finite_hub_charging_e3d5c5x7a_test.tscn` (13)
45. Wave 3 — `res://tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` (16)
46. Wave 3 — `res://tests/drone_pre_pickup_cancellation_e3d5c5x7c1_test.tscn` (12)
47. Wave 3 — `res://tests/drone_post_delivery_cancellation_e3d5c5x7c2_test.tscn` (13)
48. Wave 3 — `res://tests/drone_lost_site_recovery_e3d5c5x7c3_test.tscn` (14)
49. Wave 3 — `res://tests/drone_automatic_dispatch_e3d5c5x8a_test.tscn` (14)
50. Wave 3 — `res://tests/drone_automatic_lifecycle_e3d5c5x8b_test.tscn` (15)
51. Wave 3 — `res://tests/playable_automatic_construction_drone_stage_a_test.tscn` (8)
52. Wave 3 — `res://tests/playable_automatic_construction_drone_stage_b_test.tscn` (8)
53. Wave 3 — `res://tests/playable_automatic_construction_drone_stage_c_test.tscn` (13)
54. Wave 3 — `res://tests/playable_construction_building_expansion_e3d5c6a_test.tscn` (8)
55. Wave 3 — `res://tests/playable_construction_building_expansion_e3d5c6a_stage_b_test.tscn` (12)
56. Wave 3 — `res://tests/playable_construction_building_expansion_e3d5c6a_stage_c_test.tscn` (11)
57. Wave 3 — `res://tests/playable_direct_build_authorization_e3d5c6b_test.tscn` (11)
58. Wave 3 — `res://tests/playable_direct_build_authorization_e3d5c6b_stage_b_test.tscn` (14)
59. Wave 3 — `res://tests/cancelled_site_custody_e3d5c6c_stage_a_test.tscn` (13)
60. Wave 3 — `res://tests/cancelled_site_physical_recovery_e3d5c6c_stage_b_test.tscn` (13)
61. Wave 4 — `res://tests/playable_cancelled_site_recovery_e3d5c6c_stage_c_test.tscn` (14)
62. Wave 4 — `res://tests/playable_unified_construction_e3d5c6d_stage_a_test.tscn` (16)
63. Wave 4 — `res://tests/playable_drone_power_interruption_e3d5c6e_stage_a_test.tscn` (14)
64. Wave 4 — `res://tests/specialized_drone_role_guards_e3d5c6f_stage_a_test.tscn` (6)
65. Wave 4 — `res://tests/specialized_drone_handoff_e3d5c6f_stage_a_test.tscn` (7)
66. Wave 4 — `res://tests/specialized_drone_single_owner_e3d5c6f_b1_test.tscn` (9)
67. Wave 4 — `res://tests/specialized_drone_logistics_e3d5c6f_b2_test.tscn` (9)
68. Wave 4 — `res://tests/specialized_drone_builder_e3d5c6f_b3_test.tscn` (12)
69. Wave 4 — `res://tests/specialized_drone_pre_pickup_cancel_e3d5c6f_c1_test.tscn` (12)
70. Wave 4 — `res://tests/specialized_drone_loaded_cancel_e3d5c6f_c2_test.tscn` (16)
71. Wave 4 — `res://tests/specialized_drone_staging_recovery_e3d5c6f_c3_test.tscn` (18)
72. Wave 4 — `res://tests/specialized_drone_builder_blackout_e3d5c6f_c4a_test.tscn` (14)
73. Wave 4 — `res://tests/specialized_drone_builder_cancel_e3d5c6f_c4b_test.tscn` (14)

## C5B — proposed interactive verification harness (approval required)

Source review of scenes/core/playable_specialized_drones_e3d5c6f.tscn and scripts/ui/playable_specialized_drones_e3d5c6f.gd at ab589e0d356d3671e05f01276675c752e8618c2b confirms the named scene is an exact-scoped component fixture, not a usable interactive sandbox: B1 enabled, no camera or player-facing controls, physical B2/B3 and cancellation controllers off. Do not claim opening it with F6 exercises specialized gameplay. Propose a separate wrapper scene instantiating the existing exact scene, with a single bounded explicit tick driver routing only to the current token owner and real controller entry points; distinct drone visual markers, camera, ground, HUD (job/progress, energy, stock/staging/escrow/cargo, worker count, tick owner); scenario reset via fresh scope, no direct resource mutations except declared fixture initialization and optional controlled destination capacity test. Start, power toggle, cancel and reset controls. No change to Main, historical scenes/tests, no second dispatcher. Use original physical fixture setup and preserve exact anchored receiver/escrow/receipt. No autonomous generalized fleet reuse, source destruction, automatic reroute after permanent destination deletion, or Main integration. Harness requires implementation and its own isolated smoke gate before manual checks; if new automated fixture added, final full coverage increases only after local pass and regression freshness must be assessed again. No invented scene path or keys until implemented.

Proposed manual checklist (12 checks):
1. Fresh fixture shows distinct drones at left/right berths, Storage 15 ingots and no active worker.
2. Authorize/start real Press job; logistics physically collects 5, Storage becomes 10.
3. Logistics physically delivers to anchored staging and escrow; returns empty before builder departure.
4. Builder physically arrives, original job advances only with power and one worker.
5. Toggle power off during work; progress freezes, escrow remains five, builder physically parks empty.
6. While docked unpowered, battery and progress do not increase; logistics stays docked.
7. Restore power; finite recharge, builder returns and resumes same progress.
8. Complete normal job; one real Press, original escrow consumed, Storage remains 10, builder returns empty.
9. Reset and cancel before pickup or while loaded using explicit existing C1/C2 paths (separate fresh runs); inventory conserved.
10. Reset and cancel active/paused builder; progress frozen, no Press activation, builder retires at right berth and single owner hands back.
11. Logistics physically collects original staged five, deposits at eligible Storage; blocked capacity or blackout waits safely, restore and finish.
12. Verify total 15 after canceled run, no duplicate job/cargo/replay, one owner, no unintended Main activation.

C5B checks are proposed and unrun. After C5A, approve harness scope, implement and test, then conduct manual checks. No automatic merge; integration review after full acceptance. Preserve local changes and draft PR #1.
