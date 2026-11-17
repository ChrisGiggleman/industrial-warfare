# Industrial Warfare — Current Development Handoff

Updated 2026-11-17. Repository: ChrisGiggleman/industrial-warfare, main. Godot 4.6.2, GDScript, Forward+.
Read this first when resuming a new conversation. GitHub history and actual source take precedence over chat recollection; verify main HEAD and any local changes before making edits.

## Current checkpoint

- E3d5c5x2 playable drone lifecycle accepted (33/33 targeted checks plus manual power resume, completion, cancellation and Hub return).
- E3d5c5x3 Storage supplier discovery accepted (12/12).
- E3d5c5x4a source reservations fully accepted (12/12 isolated and 207/207 across 16 targeted compatibility suites; 219/219). Acceptance commit [2987d49](https://github.com/ChrisGiggleman/industrial-warfare/commit/2987d497bfdd5bca2050ea35bd47f580b1b73245).
- E3d5c5x4b return capacity reservations isolated accepted (14/14 A–N, developer explicitly confirmed all 14 passed in Godot). Implementation [d6d1ed9](https://github.com/ChrisGiggleman/industrial-warfare/commit/d6d1ed9d74af73aaffa175ec9748e77671325d10); staging documentation [1fec87a](https://github.com/ChrisGiggleman/industrial-warfare/commit/1fec87aa4b72a37603215314b1f19ed2cd65d81e).
- **E3d5c5x4b fully accepted: 259/259 (14 isolated + 245 across 20 targeted compatibility suites).** Developer confirmed every suite on 2026-11-17. Current next milestone: E3d5c5x5a guarded physical pickup staged; 12 isolated checks pending.
- No independent runtime execution by assistant; evidence is developer's local Godot report. No production code changes in this handoff update.

## Current next action — E3d5c5x5a pickup testing

Code staged: exact-claim pickup, battery-metered travel, finite cargo custody. Open `res://tests/drone_physical_pickup_e3d5c5x5a_test.tscn`, press F6. Expected `ALL 12 E3D5C5X5A DRONE PHYSICAL PICKUP TESTS PASSED`. 12 isolated checks pending; verify local parse/runtime, then targeted compatibility before x5b. Loaded drone remains stationary at source pending delivery/recovery implementation. No Main activation. Pull only with clean working tree.

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
- Physical pickup/cargo custody is staged, not yet accepted; site delivery, actual unloading, active-claim destruction recovery and persistence are not implemented/accepted yet. No assumption of pathfinding safety or production activation.

## Roadmap from here

1. x4b compatibility acceptance — complete.
2. E3d5c5x5 guarded physical pickup and delivery, exact-once material conservation and authorized-site escrow integration; review implementation before staging.
3. E3d5c5x6 canceled-job cargo recovery, safe retention/rerouting and return unloading.
4. E3d5c5x7 charging and repeated assignments.
5. Multiple drones/sites, researchable Storage docking attachments, bulk silos, construction depots, persistence/destruction integration and playable Main activation through separate gates.

Read [DEVLOG](DEVLOG.md), [ROADMAP](ROADMAP.md), [Drone Construction Logistics](DRONE_CONSTRUCTION_LOGISTICS.md), [Architecture](ARCHITECTURE.md), [Construction and Power](CONSTRUCTION_AND_POWER_ARCHITECTURE.md), and [Future Features](FUTURE_FEATURES.md) for detail.

## Continuity procedure

At each major milestone, before changing chats, and when stopping mid-gate: record tested commit, developer-confirmed results, pending and failed tests, changes, design decisions, limitations and next action here and in the appropriate history/roadmap docs. Keep prior history in DEVLOG and Git; do not mark pending work accepted. Provide the new-chat prompt below. A new chat should inspect this file at main and current HEAD, reconcile differences and resume from the documented gate, not restart or redesign. Exact chat capacity is not reliably observable; rotate at clean checkpoints, or checkpoint before long implementation/testing.

### Reusable new-chat prompt

Continue Industrial Warfare development from ChrisGiggleman/industrial-warfare, main. Use the GitHub connector to read docs/HANDOFF.md, latest DEVLOG and ROADMAP, relevant design docs and current main HEAD. Reconcile pending versus accepted tests and continue the next documented step without repeating accepted work or skipping gates. Preserve agreed gameplay and sandbox/default-off guardrails. Update the handoff and DEVLOG after each major milestone and provide a new-chat prompt before moving to a new conversation.
