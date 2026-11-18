# Industrial Warfare — Current Development Handoff

Updated 2026-11-17. Repository: ChrisGiggleman/industrial-warfare, main. Godot 4.6.2, GDScript, Forward+.
Read this first when resuming a new conversation. GitHub history and actual source take precedence over chat recollection; verify main HEAD and any local changes before making edits.

## Current checkpoint

- E3d5c5x2 playable drone lifecycle accepted (33/33 targeted checks plus manual power resume, completion, cancellation and Hub return).
- E3d5c5x3 Storage supplier discovery accepted (12/12).
- E3d5c5x4a source reservations fully accepted (12/12 isolated and 207/207 across 16 targeted compatibility suites; 219/219). Acceptance commit [2987d49](https://github.com/ChrisGiggleman/industrial-warfare/commit/2987d497bfdd5bca2050ea35bd47f580b1b73245).
- E3d5c5x4b return capacity reservations isolated accepted (14/14 A–N, developer explicitly confirmed all 14 passed in Godot). Implementation [d6d1ed9](https://github.com/ChrisGiggleman/industrial-warfare/commit/d6d1ed9d74af73aaffa175ec9748e77671325d10); staging documentation [1fec87a](https://github.com/ChrisGiggleman/industrial-warfare/commit/1fec87aa4b72a37603215314b1f19ed2cd65d81e).
- **E3d5c5x4b fully accepted: 259/259 (14 isolated + 245 across 20 targeted compatibility suites).** Developer confirmed every suite on 2026-11-17. 
- **E3d5c5x5a isolated physical pickup accepted (12/12)**, developer confirmed in Godot 2026-11-17. Tested code [6ed2e2b](https://github.com/ChrisGiggleman/industrial-warfare/commit/6ed2e2bdffa40ea8bcb301bada6a7a8e96190501). Full acceptance 409/409 (12 isolated + 397 across 28 compatibility suites), developer-confirmed.
- **E3d5c5x5b isolated physical delivery accepted (13/13)**, developer confirmed all checks in Godot 2026-11-17. Implementation [5e2fbbc](https://github.com/ChrisGiggleman/industrial-warfare/commit/5e2fbbc122f2f72329d7f811504cecf0698b7616). Full targeted acceptance 516/516 (13 isolated + 503 across 35 compatibility suites), developer-confirmed.
- **E3d5c5x5c isolated accepted (16/16)**, developer screenshot 2026-11-17, implementation [6652bd0](https://github.com/ChrisGiggleman/industrial-warfare/commit/6652bd0db58594a8efd0c7d862c533abdbe782fb). **Fully accepted 565/565 (16 isolated + 549 across 38 compatibility suites)**, developer-confirmed 2026-11-17.
- **E3d5c5x6 isolated canceled cargo recovery accepted (13/13)**, developer Godot Output screenshot; **Fully accepted 578/578 (13 isolated + 565 across 39 compatibility suites)**.
- **E3d5c5x7a finite Hub charging isolated accepted (13/13)**, developer Godot Output screenshot; **Fully accepted 641/641 (13 isolated + 628 across 43 compatibility suites)**.
- E3d5c5x7b guarded cargo-worker rearm and repeated assignments staged (16 isolated tests pending).
- No independent runtime execution by assistant; accepted evidence is developer's local Godot report. Normal gameplay remains unchanged.

## Current next action — E3d5c5x7b safe cargo-worker rearm

**Staged; 16 isolated checks pending.** Implementation and test scene [d0fa281](https://github.com/ChrisGiggleman/industrial-warfare/commit/d0fa281f2d964243cf960334727c17ed5641d61e); latest guard/test refinement [acdcdf7](https://github.com/ChrisGiggleman/industrial-warfare/commit/acdcdf76861f012ed2231dd8760e23d02f928d6b). Original registered home must remain unchanged even if both Hub and drone are moved together; nonfinite home/position refused. Test F now checks the combined move as well. Default-off explicit cargo-worker rearm separated from the legacy build-only method. Require terminal delivered assignment or successfully deposited canceled cargo, exact physical Hub registration and full battery under the still-live x7a charging authority, empty cargo and no pickup/return tokens, authoritative same-scope supplier/return ledgers, matching live owned-mode coordinator/escrow/scheduler, exact pinned delivered-worker scheduler and escrow where applicable, no reservation/escrow records or active worker slots, no old worker binding. Rearm disconnects old job/site callbacks and clears assignment provenance only, leaves receiver ownership/material quantities untouched; subsequent pickup uses new authorization/claim and live finite-charge gate. One drone runs complete, canceled in-flight recovery, complete, canceled during construction, with two committed bills and conserved remaining stock. Explicit calls only; an entire scope must be quiescent, full charge required, fixed Hub, no pre-pickup cancellation rearm, nonterminal lost-site recovery rearm, empty delivered-before-worker cancellation rearm, automatic dispatch, multi-trip, persistence/destruction integration or normal scene activation. Those are separate future gates. 

Run `res://tests/drone_cargo_worker_reuse_e3d5c5x7b_test.tscn` with F6. Expected `ALL 16 E3D5C5X7B CARGO WORKER REUSE TESTS PASSED`. Checks A–P: default-off, loaded/no premature rearm, first completion/home return, battery and stale binding, legacy bypass denial, exact services/original dock including combined Hub/drone relocation, outstanding source/return claims, escrow, callback cleanup, new authorization and fresh claim, canceled successor protected recovery, finite recharge and second rearm, later successful build, canceled working job and conservation, feature-loss interlock, normal-scene opt-out. No independent Godot parse/runtime execution. After isolated acceptance run targeted compatibility including x7a, prior lifecycle, scheduler and escrow suites. No normal scene activation. Pull with clean tracked working tree.

## Completed compatibility gate — x7a

**Isolated accepted: 13/13 A–M**, developer's Godot Output screenshot, 2026-11-17 local date, implementation and test scene [61c3d7e](https://github.com/ChrisGiggleman/industrial-warfare/commit/61c3d7e454e51cceb8c85edec44d1172c9ace665), documentation checkpoint a97db8f. All PASS A–M and final ALL 13 E3D5C5X7A FINITE HUB CHARGING TESTS PASSED visible. Default-off, exclusive authority, exact home, no legacy bypass, invalid delta, construction-first shared budget, rate/headroom, outage, restored allocation, physical dock checks, feature loss, duplicate allocator, metered return and recharge, authority removal and normal-scene opt-out passed. No independent execution.

**Accepted: all 43 compatibility suites / 628 checks**, developer explicitly confirmed in local Godot; 641/641 including 13 isolated checks. Implementation 61c3d7e, gate documentation f62e8de. Targeted, not full-project regression; no independent execution. Next x7b.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| `drone_cancelled_cargo_recovery_e3d5c5x6_test.tscn` | 13 | Passed |
| `construction_power_coverage_e3d5c3a_test.tscn` | 16 | Passed |
| `completed_power_structures_e3d5c3b1_test.tscn` | 16 | Passed |
| `finite_construction_power_e3d5c3b2_test.tscn` | 18 | Passed |
| **Total (43 suites)** | **628** | Passed |

## Completed compatibility gate — x6

**Isolated accepted: 13/13 A–M**, developer's Godot 4.6.2 Output screenshot, 2026-11-17 local date, implementation and test scene [6675009](https://github.com/ChrisGiggleman/industrial-warfare/commit/6675009fe9862d8830b2eedc3e3c33427cfb4dc1), documentation checkpoint 20cabd2. All PASS A–M and final ALL 13 E3D5C5X6 CANCELED CARGO RECOVERY TESTS PASSED visible. Default-off/active-job refusal, actual nearest reservation, ordinary intake protection, physical metered flight, moved dock, exact deposit, empty home return, invalid/full destination, flag loss/reroute, capacity shrink/deleted dock, unreachable route, conservation and normal scene opt-out passed. No independent execution.

**Accepted: all 39 compatibility suites / 565 checks**, explicitly developer-confirmed in local Godot; 578/578 including 13 isolated checks. Implementation 6675009, gate documentation f1215dc. This is targeted, not full-project regression; no independent execution. Next x7.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| `drone_delivered_worker_e3d5c5x5c_test.tscn` | 16 | Passed |
| **Total (39 suites)** | **565** | Passed |

## Completed compatibility gate — x5c

**Isolated accepted: 16/16 A–P**, local developer Godot 4.6.2 Output screenshot 2026-11-17, implementation [6652bd0](https://github.com/ChrisGiggleman/industrial-warfare/commit/6652bd0db58594a8efd0c7d862c533abdbe782fb). Explicit coordinator handoff of empty delivered drone into existing owned-material coordinator and finite worker scheduler, exact escrow provenance, physical arrival and return energy, pause/resume, empty return, cancellation conservation, reuse quarantine and normal-scene opt-out passed. No independent runtime execution by assistant.

**Accepted: all 38 compatibility suites / 549 check groups** explicitly reported passed by developer in local Godot on 2026-11-17, plus 16 isolated checks: 565/565 targeted acceptance. Tested implementation 6652bd0; documentation checkpoint 955eab6. Not independently executed or a full-project regression. Next x6 automatic canceled-job cargo recovery.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| `drone_physical_delivery_e3d5c5x5b_test.tscn` | 13 | Passed |
| `construction_readiness_coordinator_e3d5c3c1_test.tscn` | 18 | Passed |
| `blueprint_construction_readiness_e3d5c1_test.tscn` | 15 | Passed |
| **Total (38 suites)** | **549** | Passed |

## Completed compatibility gate — x5b

All 35 compatibility suites and 503/503 groups passed in local Godot; 516/516 including 13 isolated checks. Historical baseline for x5c compatibility.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| `drone_physical_pickup_e3d5c5x5a_test.tscn` | 12 | Passed |
| `blueprint_material_staging_e3d5c4c_test.tscn` | 16 | Passed |
| `blueprint_physical_staging_e3d5c4d_test.tscn` | 16 | Passed |
| `blueprint_site_staging_ownership_e3d5c4h_test.tscn` | 16 | Passed |
| `blueprint_anchored_receiver_e3d5c4i_test.tscn` | 16 | Passed |
| `blueprint_owned_readiness_e3d5c4r_test.tscn` | 18 | Passed |
| `blueprint_receiver_recovery_audit_e3d5c4j_test.tscn` | 12 | Passed |
| **Total (35 suites)** | **503** | Passed |

## Completed compatibility gate — x5a

All 28 suites and 397 check groups passed in local Godot, plus 12 isolated checks: 409/409 targeted acceptance. Next x5b: guarded delivery to the original authorized site's owned staging.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| `drone_return_reservations_e3d5c5x4b_test.tscn` | 14 | Passed |
| `prototype_construction_worker_drone_e3d5c4u_test.tscn` | 16 | Passed |
| `prototype_drone_worker_readiness_e3d5c4v_test.tscn` | 21 | Passed |
| `prototype_construction_drone_fleet_e3d5c4w_test.tscn` | 21 | Passed |
| `prototype_drone_battery_dock_e3d5c4x_test.tscn` | 20 | Passed |
| `prototype_construction_drone_reuse_e3d5c4y_test.tscn` | 20 | Passed |
| `prototype_construction_drone_tick_e3d5c4z_test.tscn` | 20 | Passed |
| `sandbox_construction_drone_bridge_e3d5c5a_test.tscn` | 20 | Passed |
| **Total (28 suites)** | **397** | Passed |

x5b fully accepted; x5c delivered-worker handoff fully accepted. Successful unload remains DELIVERED until explicit coordinator handoff. Cancellation return unloading, loaded-drone destruction/persistence and Main activation remain separate gates.

## Completed compatibility gate — x4b

Completed locally in Godot (F6); retain this list as the acceptance record. The x4a 16-suite gate is reused, plus supplier reservations, automatic unloading, timed Storage conveyor delivery and recipe output capacity because ordinary intake capacity changed. This is targeted coverage, not a full project regression.

| Scene under res://tests/ | Expected check groups | Result |
|---|---:|---|
| `inventory_trasnfer_test.tscn` | 4 | Passed |
| `item_port_transfer_test.tscn` | 7 | Passed |
| `manufacturing_transaction_test.tscn` | 9 | Passed |
| `recipe_output_capacity_test.tscn` | 11 | Passed |
| `conveyor_automatic_loading_test.tscn` | 10 | Passed |
| `conveyor_automatic_unloading_test.tscn` | 9 | Passed |
| `conveyor_connected_transport_test.tscn` | 7 | Passed |
| `conveyor_splitter_test.tscn` | 10 | Passed |
| `conveyor_merger_test.tscn` | 10 | Passed |
| `conveyor_physical_only_conservation_test.tscn` | 9 | Passed |
| `timed_storage_conveyor_delivery_test.tscn` | 6 | Passed |
| `blueprint_construction_material_escrow_e3d5c2a_test.tscn` | 16 | Passed |
| `unified_receiver_consolidation_e3d5c5v_test.tscn` | 56 | Passed |
| `playable_construction_logistics_e3d5c5w_test.tscn` | 13 | Passed |
| `playable_construction_power_e3d5c5x1_test.tscn` | 9 | Passed |
| `playable_construction_drone_e3d5c5x2_test.tscn` | 11 | Passed |
| `drone_storage_discovery_e3d5c5x3_test.tscn` | 12 | Passed |
| `drone_supplier_reservations_e3d5c5x4a_test.tscn` | 12 | Passed |
| `world_salvage_destruction_test.tscn` | 12 | Passed |
| `destruction_cargo_recovery_test.tscn` | 12 | Passed |
| **Total** | **245** | Passed |

Inventory scene's historical filename typo is intentional; inventory's four groups have no ALL banner, and manufacturing and output capacity print unnumbered ALL banners. All 245 passed; 259/259 including isolated checks. Next: x5 isolated pickup transaction, then movement and site delivery.

## Design decisions and guardrails

- Permanent conveyors move factory materials; construction drones physically collect eligible Storage stock and deliver it to authorized sites. No temporary belts required for construction, no magical transfer.
- Preserve existing conveyor paths, manual construction authorization (E selected, Ctrl+E all), priority ordering (never auto-authorizes), escrow, timed construction, power/readiness, and all accepted tests.
- Preserve sandbox-only/default-off feature gates and Main opt-out. No unreviewed production activation.
- Incoming capacity and outgoing stock claims are independent; physical inventory remains unchanged by reserving or releasing. Current return claim is whole single-material load, exact owner/Storage/dock/inventory identity, and newest excess claims released first after capacity reduction.
- On cancellation, an actual loaded drone should retain its cargo and select nearest eligible Storage with reserved capacity and safe battery forecast; do not discard or duplicate material. Re-evaluate assignment only after safe unloading. Researchable docking retrofits, silos and depots remain agreed future features.
- Physical pickup/cargo custody fully accepted; site delivery and isolated return unloading fully accepted; active-claim destruction recovery and persistence remain pending. No assumption of pathfinding safety or production activation.

## Roadmap from here

1. x4b compatibility acceptance — complete.
2. E3d5c5x5a fully accepted; x5b fully accepted. x5c fully accepted 565/565; proceed to x6.
3. E3d5c5x6 fully accepted 578/578; proceed to x7.
4. E3d5c5x7a fully accepted 641/641; x7b guarded cargo-worker rearm/repeated assignments staged, 16 isolated checks and compatibility pending.
5. Multiple drones/sites, researchable Storage docking attachments, bulk silos, construction depots, persistence/destruction integration and playable Main activation through separate gates.

Read [DEVLOG](DEVLOG.md), [ROADMAP](ROADMAP.md), [Drone Construction Logistics](DRONE_CONSTRUCTION_LOGISTICS.md), [Architecture](ARCHITECTURE.md), [Construction and Power](CONSTRUCTION_AND_POWER_ARCHITECTURE.md), and [Future Features](FUTURE_FEATURES.md) for detail.

## Continuity procedure

At each major milestone, before changing chats, and when stopping mid-gate: record tested commit, developer-confirmed results, pending and failed tests, changes, design decisions, limitations and next action here and in the appropriate history/roadmap docs. Keep prior history in DEVLOG and Git; do not mark pending work accepted. Provide the new-chat prompt below. A new chat should inspect this file at main and current HEAD, reconcile differences and resume from the documented gate, not restart or redesign. Exact chat capacity is not reliably observable; rotate at clean checkpoints, or checkpoint before long implementation/testing.

### Reusable new-chat prompt

Continue Industrial Warfare development from ChrisGiggleman/industrial-warfare, main. Use the GitHub connector to read docs/HANDOFF.md, latest DEVLOG and ROADMAP, relevant design docs and current main HEAD. Reconcile pending versus accepted tests and continue the next documented step without repeating accepted work or skipping gates. Preserve agreed gameplay and sandbox/default-off guardrails. Update the handoff and DEVLOG after each major milestone and provide a new-chat prompt before moving to a new conversation.
