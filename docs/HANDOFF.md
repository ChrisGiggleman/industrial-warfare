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
- No independent runtime execution by assistant; evidence is developer's local Godot report. No production code changes in this handoff update.

## Current next action — E3d5c5x5c delivered-worker integration testing

Staged: explicit handoff of empty delivered drone into the existing owned-material coordinator and finite worker scheduler, exact escrow provenance, physical arrival and return energy, pause/resume and empty return. Run `res://tests/drone_delivered_worker_e3d5c5x5c_test.tscn` with F6; expect `ALL 16 E3D5C5X5C DELIVERED DRONE WORKER INTEGRATION TESTS PASSED`. 16 isolated checks pending. No normal gameplay activation. After isolated acceptance rerun targeted compatibility, then x6 cancellation cargo return. Pull with clean working tree.

## Completed compatibility gate — x5b

All 35 compatibility suites and 503/503 groups passed in local Godot; 516/516 including 13 isolated checks. Next x5c delivered-drone worker/readiness integration.

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

x5b fully accepted; x5c delivered-worker handoff staged, not accepted. Successful unload remains DELIVERED until explicit coordinator handoff. Cancellation return unloading, loaded-drone destruction/persistence and Main activation remain separate gates.

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
- Physical pickup/cargo custody fully accepted; site delivery fully accepted; return unloading, active-claim destruction recovery and persistence remain pending. No assumption of pathfinding safety or production activation.

## Roadmap from here

1. x4b compatibility acceptance — complete.
2. E3d5c5x5a fully accepted; x5b fully accepted. x5c guarded delivered-drone worker/readiness integration staged; 16 checks pending before compatibility and x6.
3. E3d5c5x6 canceled-job cargo recovery, safe retention/rerouting and return unloading.
4. E3d5c5x7 charging and repeated assignments.
5. Multiple drones/sites, researchable Storage docking attachments, bulk silos, construction depots, persistence/destruction integration and playable Main activation through separate gates.

Read [DEVLOG](DEVLOG.md), [ROADMAP](ROADMAP.md), [Drone Construction Logistics](DRONE_CONSTRUCTION_LOGISTICS.md), [Architecture](ARCHITECTURE.md), [Construction and Power](CONSTRUCTION_AND_POWER_ARCHITECTURE.md), and [Future Features](FUTURE_FEATURES.md) for detail.

## Continuity procedure

At each major milestone, before changing chats, and when stopping mid-gate: record tested commit, developer-confirmed results, pending and failed tests, changes, design decisions, limitations and next action here and in the appropriate history/roadmap docs. Keep prior history in DEVLOG and Git; do not mark pending work accepted. Provide the new-chat prompt below. A new chat should inspect this file at main and current HEAD, reconcile differences and resume from the documented gate, not restart or redesign. Exact chat capacity is not reliably observable; rotate at clean checkpoints, or checkpoint before long implementation/testing.

### Reusable new-chat prompt

Continue Industrial Warfare development from ChrisGiggleman/industrial-warfare, main. Use the GitHub connector to read docs/HANDOFF.md, latest DEVLOG and ROADMAP, relevant design docs and current main HEAD. Reconcile pending versus accepted tests and continue the next documented step without repeating accepted work or skipping gates. Preserve agreed gameplay and sandbox/default-off guardrails. Update the handoff and DEVLOG after each major milestone and provide a new-chat prompt before moving to a new conversation.
