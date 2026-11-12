# Universal Construction, Blueprint Planning, and Power Grid — Architecture Proposal

**Project:** Industrial Warfare — one zombie-planet playable demo  
**Date:** 2026-11-08  
**Status:** ConstructionJob **14/14**, universal ConstructionSite **15/15**, original compatibility suites **23/23**, per-definition durations **12/12**, and building Blueprint Mode **12/12** passed in Godot 4.6.2. Building Blueprint Mode passed 7-step manual authorization and 6-step cancellation/overlap checks. Post-Blueprint-Mode conveyor compatibility **14/14 passed** (2026-11-09). Stand-alone straight conveyor blueprint E1 **passed 14/14 scripted F6 checks** and its seven-step manual placement/authorization/cancellation sequence was confirmed (2026-11-09). E2a planned direct/right/left route-geometry discovery **passed 12/12 in Godot 4.6.2** (2026-11-09). E2b exclusive endpoint reservations **passed 16/16** in Godot 4.6.2 (2026-11-09). E2c1 isolated deferred physical connection activation **passed 15/15** in the developer's Godot 4.6.2 run. E2c2 sandbox-only connected blueprint corner presentation **passed 17/17 F6 checks** in Godot 4.6.2. Planned left/right corner visuals, cancellation rollback, and completed physical links are implemented in the Factory Testing Sandbox; all six player-facing manual steps were confirmed on 2026-11-09. Post-E2c2 compatibility regressions PASSED **45/45** (E2b 16, E2c1 15, planned Storage Build Mode 6, conveyor corner cargo 8). Independent manual testing also confirmed E authorization works regardless of the selected ghost rotation. E3a future Storage-port geometry discovery **passed 15/15 in Godot 4.6.2**. E3b isolated future-port reservations **passed 18/18 in Godot 4.6.2**. E3c0 shared endpoint-claim broker **passed 18/18 F6 checks** in Godot 4.6.2; E2b/E3b can optionally share it. E3c1 isolated real Storage-port activation **passed 18/18 F6 checks** in Godot 4.6.2. E3c2a sandbox-only automatic planned Storage/Conveyor port registration **passed 16/16 in Godot 4.6.2**. E3c2b opt-in Storage blueprint ghost-to-port preview snapping is committed with **14 F6 checks pending**; manual placement and compatibility tests remain later gates. Connections to unfinished Storage, Main-scene enablement, real power and worker/material services remain unimplemented.  
**Compatibility baseline:** Godot 4.6.2 Stable, `main`; timed Storage construction and planned Storage belt reservations remain sandbox-only.

## 1. Existing Implementation and Constraints

The current code provides:

- `BuildingDefinition`: stable `building_id`, scene, category, grid footprint.
- `FactoryGrid`: world-unit grid, rotated footprints, odd/even tile origins and port geometry.
- `ConstructionLifecycle`: PLANNED / CONSTRUCTING / COMPLETE, elapsed work, multiplier and completion signal. It currently owns no resources, power or placement.
- `ConstructionSite`: reserved collision footprint, visible progress, non-operational port markers, timed activation of a real building and deferred conveyor links. Current planned markers are tailored to `InputPort` and `OutputPort`.
- `WorldInteraction`: existing building/conveyor placement, preview, demolition and optional timed Storage flow. Its planned Storage options are disabled in normal Main.
- `ConveyorSegment`, `ItemPortComponent` and transport components: operational directional links and inventory-conserving transfer. Real conveyor segments are currently placed instantly.
- `WorldDestructionService` and `DestructionTransaction`: guarded removal and inventory recovery for completed player-built entities.

Do not replace these interfaces in one migration. Protect the current Main scene and factory testing sandbox with opt-in feature flags and the existing Godot regression suite.

## 2. Separate Plan, Job, Site, and Operational Entity

| Layer | Proposed responsibility | Explicitly excluded |
| --- | --- | --- |
| `BuildingDefinition` plus construction data | Duration, footprint, stable ID, required materials, future worker requirements and power class | Mutable per-instance progress |
| `ConstructionPlan` data object | Desired definition ID, world transform, orientation, geometry/port reservation IDs, optional parent blueprint group | Live building inventory, manufacturing or firing |
| `ConstructionJob` | Player authorization, queue order, requirements/gating, progress policy, cancellation accounting, status/reason | Physical conveyor or production logic |
| `ConstructionLifecycle` | Reusable elapsed-work clock, work multiplier and one-time completion | Power allocation, materials, user input |
| `ConstructionSite` | Non-operational visual, spatial reservation, collision, pending port mappings, activation transaction | Active producer, combat turret, storage or belt cargo |
| Completed scene | Unchanged real building or conveyor components activated once construction succeeds | Blueprint-only ownership or placeholder effects |

A site may visualize a plan before authorization; **planned/queued structures must not instantiate live gameplay components into the world**. The operational entity appears only after successful activation.

### Job state machine

```text
PLANNED --authorize--> QUEUED --requirements met--> CONSTRUCTING
                                  |                       |
                                  | waiting reason        | power/material/worker unavailable
                                  v                       v
                                QUEUED <--------------- PAUSED
                                                          |
                                           requirements restored
                                                          |
                                                          v
                                                     CONSTRUCTING
                                                          |
                                               duration completed
                                                          v
                                                       COMPLETE

PLANNED / QUEUED / CONSTRUCTING / PAUSED --cancel--> CANCELLED
```

- `PLANNED`: reserves logical footprint only; player may cancel or reposition before authorization. No power, material or operational benefit.
- `QUEUED`: authorized but waiting for service coverage, worker, delivered materials, or predecessor jobs; record explicit wait reasons.
- `CONSTRUCTING`: all required conditions satisfied and work advances. The existing lifecycle performs only the timing.
- `PAUSED`: preserves elapsed work and already delivered materials; work does not advance until blocking conditions resolve.
- `COMPLETE`: atomic real-entity activation, then release site reservation; existing health, selection, production, cargo and combat components own behavior.
- `CANCELLED`: release all logical claims, safely return or preserve delivered resources and tear down reservations; never silently delete cargo.

Represent wait reasons separately from job states so a job may be blocked by more than one condition. Keep current `ConstructionLifecycle.State` values and methods compatible during migration; job state wraps the lifecycle instead of repurposing its timer.

### Construction inputs

Use an optional `construction_seconds` value per buildable definition (or associated construction definition), with a future list of `ItemAmount` material requirements. A short belt duration still must be greater than zero in normal gameplay. Prototype test fixtures may deliberately use zero duration. Worker count, work multipliers, energy requirements and research modifiers are separate, additive policies.

Do not consume materials merely because the player draws a blueprint. Future material delivery must occur through physical inventory transfer to a site or job-owned construction inventory. Specify refunds/salvage before enabling cancellation with delivered goods.

### Gate B implementation checkpoint — isolated construction job

`scripts/components/construction_job.gd` is now committed as a `RefCounted` policy wrapper around `ConstructionLifecycle`; `tests/construction_job_test.tscn` is the corresponding **14-check local F6 regression, passed 14/14 in Godot 4.6.2**.

- Its public state machine is `PLANNED → QUEUED → CONSTRUCTING ↔ PAUSED → COMPLETE`, plus `CANCELLED` from any nonterminal state. `authorize()` is the only way out of `PLANNED`.
- Power, materials, and workers are separate externally supplied **availability flags**. Each required flag defaults to false (fail-closed), and `get_wait_reasons()` reports the missing requirements. The future power grid, material transfer, and worker fleet must validate their availability truthfully.
- Construction time stays exclusively in the existing `ConstructionLifecycle`. A paused job never invokes `advance()` on its timer; resuming preserves accrued work, and completion signals only once.
- Deliberate bootstrap/test jobs may opt out of individual gates (for example, the Main Hub) and may use zero seconds in a test; real conveyors and normal structures will later use positive construction durations from building definitions.
- Cancellation **does not return materials or free a world footprint in this isolated class**, because neither is owned by it. The later construction-site integration must handle safe cancellation transactions, port reservation cleanup, material salvage and collision ownership.
- None of these scripts currently activates scene objects or connects physical conveyors. Main, WorldInteraction, Production Debug, and factory transport remain unchanged.

Gate B passed its 14-check Godot test. Integration is now staged behind the opt-in site path described below; do not enable it in WorldInteraction until the new site and legacy regression scenes pass.

---

### Gate C implementation checkpoint — opt-in job-driven sites

The existing `ConstructionSite` now provides `setup_with_job(definition, duration, requires_power, requires_materials, requires_workers)`. This configures a `ConstructionJob` while retaining the original `setup()` and its automatically starting `ConstructionLifecycle` for proven timed-Storage placement. The branch is selected when the site enters the scene tree; existing Main and Factory Testing Sandbox scenes do not call the new path.

- An unapproved job site stays `PLANNED` with a reserved collision footprint and **no operational child inventory, machine, turret, or conveyor**. Progress labels distinguish planned, queued, constructing, and paused.
- The planned-site marker builder copies all direct building `ItemPortComponent` nodes, including multiple named merger/splitter ports. For belts it also copies `InputEndpoint` and `OutputEndpoint`, without creating a real cargo buffer, timer or movable inventory.
- `accepts_planned_connections()` centralizes allowed reservation states. Legacy sites accept while constructing; job-driven sites accept while planned, queued, constructing or paused. Existing strict geometry alignment and connection-on-completion checks are retained.
- When the job emits completion, the site instantiates its real `BuildingDefinition.building_scene` at the stored transform, initializes `BuildingRuntime` when present, revalidates pending physical belt links, and retires the placeholder. For a conveyor definition this creates its actual `ConveyorSegment` transport components **only after completion**.
- Cancelling the isolated job retires an inventory-free site. **Before physical materials are ever delivered to jobs**, extend cancellation to a guarded material-salvage transaction; do not allow cargo-bearing site cancellation using this temporary path.
- `res://tests/universal_construction_site_test.tscn` passed all **15/15** checks in the developer's local Godot 4.6.2 run. The next gate is rerunning legacy construction, planned-port discovery, reservation and Build Mode regressions for compatibility.

**Scope limitation:** This does **not** yet automatically snap blueprint belts to other blueprint belts, implement physical blueprint conveyor graph reservation, assign build durations through `BuildingDefinition`, create worker drones, or apply actual power/material costs. These need separately tested follow-up checkpoints.

---

### Gate D1 implementation checkpoint — construction duration metadata

- `BuildingDefinition.construction_seconds` is an authorable positive float specifying the universal job duration for each buildable definition. All nine current prototype definitions now have initial values; 2 seconds for a straight conveyor and 10–20 seconds for larger production and defensive structures. This is provisional balancing, not a final difficulty specification.
- `ConstructionSite.setup_with_definition_job()` reads the timing directly from the selected definition and rejects invalid/nonpositive values. It delegates to the previously validated opt-in `setup_with_job()` path; the original `setup(definition, duration)` and sandbox `storage_construction_seconds` remain unchanged.
- `res://tests/building_construction_duration_test.tscn` adds a **12-check F6 regression** for all duration assets, blueprint inactivity, gating, pausing, real activation, multiport structures and legacy construction behavior. **Developer execution remains pending.**
- Do not connect these durations into normal `WorldInteraction` until Gate D1 passes and blueprint collision/reservation/authorizing interactions are independently validated.

---

### Gate D2 — Sandbox-only building Blueprint Planning Mode

The Factory Testing Sandbox opts into a first **building-only** interactive planning phase through `WorldInteraction.enable_blueprint_planning`. Normal Main scene remains opt-out. Press P while in Build Mode to switch to a blue BLUEPRINT MODE (TEST) HUD; left click reserves a non-operational building plan; E authorizes the plan under the cursor; X cancels it. Build Mode continues to use the existing B, R, demolition toggle, and configurable hotbar controls.

- The plan owns a `ConstructionSite` (reserved collision footprint, translucent placeholder, and marker geometry), using the validated definition-driven `ConstructionJob`; no real building inventories, turret damage, or producer components appear before job completion.
- Placement checks both `FactoryGrid` rotated-footprint alignment and intersections with other construction-site reservations, then queries completed-object collision layers. Same-frame duplicate plans are rejected independent of physics synchronization.
- Construction-site authorization does **not** directly generate power/materials/worker capacity. The sandbox-only `blueprint_sandbox_debug_requirements` option explicitly bypasses all three availability gates for interactive testing, and is off by default everywhere. Main has neither blueprint control nor this override enabled.
- Planned building ghosts do **not** snap to live conveyor ports until a real deferred-port reservation transaction is implemented. Blueprint conveyor segments are deferred until endpoint, corner and graph consistency tests; the normal physical conveyor placement system remains unchanged when P mode is off.
- `res://tests/blueprint_sandbox_mode_test.tscn` contains **12 isolated checks; developer F6 validation pending**. Manual mouse hit-testing, UI behavior, cancellation and legacy factory logistics must be verified separately.
- Future planning batches should authorize selected jobs rather than treating construction as instant; per-building materials, power coverage and drone work will replace the temporary readiness override after their own independent regressions.

---

### Gate E proposal — directional conveyor blueprints (not implemented)

**Prerequisite:** Confirm the current-branch existing `planned_storage_build_mode_test.tscn` (6 checks) and `conveyor_corner_cargo_test.tscn` (8 checks) still pass after the Blueprint Mode edits. This is a hard test gate, not inferred from previous regressions.

1. **Plan identity:** A conveyor plan records the chosen piece geometry (straight, 90-degree left, or 90-degree right), its rotation and exact `FactoryGrid`/endpoint transform, a stable per-site ID, and optional links to planned or completed neighbors. It stays a non-operational `ConstructionSite` without `CargoInventory`, transport timer, or `ConveyorSegment` links.
2. **Two-phase connection graph:** A dedicated planned-connection registry reserves `output → input` intent for both real and planned endpoints. Enforce matching directions, proximity/rotation, one exclusive claimant per required endpoint and collision-safe footprint occupancy. A reservation must never grant an active cargo route.
3. **Activation order independence:** When a job completes, instantiate the appropriate existing real conveyor scene once and then attempt only eligible link commitments whose other endpoint is completed. If the neighbor is still a blueprint, retain a pending reservation until that neighbor completes. Revalidate exact geometry and vacancy at the time each physical link is made; if invalid, remain safely disconnected rather than stealing a port or losing cargo.
4. **Shape-specific handling:** Keep existing `ConveyorCornerConversion` and `ConveyorPieceSelector` semantics intact. Planned left/right corners must preserve directional arrows and occupancy; do not model a corner as an arbitrary straight belt that magically changes after it starts moving cargo.
5. **Cancellation and destruction:** Cancelling a plan releases its own footprint and both pending endpoint claims without deleting an operational neighbor or item. Completed conveyors continue to use the validated `can_demolish_safely()` and salvage rules. Later physical delivery of construction materials needs a transactional refund/salvage policy before cancelling stocked construction sites.
6. **Player controls:** Reuse B/P/1–9/R/E/X for preview, plan, authorize and cancel in the sandbox only, but do not intercept normal working conveyor Build Mode when P is off. A planned belt must visibly distinguish direction and status from a live belt.

**Recommended checkpoint sequence:** E1 tests one planned straight piece and its delayed 2-second activation with no cargo before completion; E2 tests a planned Storage + two planned straight ports, including either completion order and conserved item counts; E3 tests left/right corner planned chains and blocked downstream transport; E4 tests cancellation/footprint reuse and a batch authorization path. Add UI/cursor tests at each step before enabling planned belts in Main.

**No live power grid:** The existing sandbox readiness override remains a deliberately explicit testing shortcut. All normal power/material/worker readiness remains fail-closed until real services are built.

---

### Conveyor blueprint E1 implementation — isolated straight pieces only

The Factory Testing Sandbox's opt-in P mode now supports planning a stand-alone, cardinal straight conveyor. Its operation is intentionally narrower than the E2/E3 planned graph proposal:

- `ConveyorBlueprintPlacement.is_clear()` validates the conveyor definition, one-tile integer-grid alignment, cardinal orientation, overlapping blueprint-site footprints, same-frame completed belt tiles and physical collision blockers.
- `WorldInteraction._update_straight_conveyor_blueprint_preview()` avoids every existing physical conveyor snap/corner/bridge path while P mode selects a conveyor. The placement ghost has a green/red validity indicator but **does not claim any neighbor endpoint**.
- `WorldInteraction._create_straight_conveyor_blueprint()` creates a job-backed `ConstructionSite` from the definition's two-second timing. The site has a reserved footprint, a yellow directional label and two non-operational endpoint markers, but **no live conveyor inventory, transport timer or physical link**.
- E and X reuse the blueprint authorization and cancellation commands. The Factory Testing Sandbox alone has the explicit synthetic power/material/worker readiness override. Main scene defaults remain opt-out.
- When the two-second authorized job completes, the existing straight `ConveyorSegment` scene is instantiated once at the saved transform. E1 does not automatically connect it to adjacent belts or buildings; physical endpoint reservations and cargo conservation are future E2/E3 requirements.
- `res://tests/conveyor_blueprint_e1_test.tscn` passed **14/14 in developer-run Godot 4.6.2**. Phase E1 manual cursor/keyboard acceptance is still pending; do not add planned belt link behavior until that interaction and the original conveyor Build Mode are revalidated.

---

### E2a checkpoint — planned straight-to-straight corner intent

`PlannedConveyorRouteGeometry.inspect_pair(source_site, receiver_site)` performs **read-only** discovery of a valid direct link or a source site's potential right/left conversion. It uses the same corner scenes' `OutputEndpoint` transforms and gap/facing thresholds already used by the operational conveyor system. It refuses invalid, non-belt, cancelled, completed and unrelated sites.

- Its result contains the intended `mode`, `turn`, `junction`, `source` and `receiver`. The object is a **candidate**, not a reserved or active link.
- Blueprints keep their straight placeholder graphics and non-operational markers. No preconstruction `ConveyorSegment`, inventory, or extra runtime physics connection is created.
- `res://tests/planned_conveyor_route_geometry_e2a_test.tscn` passed **12/12 in the developer's Godot 4.6.2 run**.
- **E2b ownership requirement:** Reserve both endpoint claims exclusively, protect against duplicate/out-of-date claims, release claims when either site is cancelled or destroyed, and handle either construction completion order. Do not hand a real belt a neighbor reference until that neighbor is a complete, geometry-compatible operational conveyor.
- **E2c player behavior:** Update planned turn arrows and visibly L-shaped placeholders from reserved geometry, then activate correct operational corner shapes and links. Right and left turns, blocked downstream cargo, demolition and conservation must pass separate automated and manual acceptance.
- Main scene remains unchanged. The temporary testing readiness override does not represent generated power or supplied building materials.

---

### E2b — Exclusive pending connection claims and readiness

`PlannedConveyorRouteReservations` (isolated Node service, not yet wired into `WorldInteraction`) owns one exclusive source `out` and receiver `in` claim for each E2a candidate. A transit site may own its incoming and outgoing sides separately. Each claim records immutable endpoint keys, source/receiver sites, direction mode, turn, junction, and optional completed belt references.

- `reserve_pair()` returns a positive reservation ID only for matching geometry with vacant claimed endpoints, or zero on failure. No physical connections, cargo or operational scenes are created.
- `building_completed` updates the corresponding built-belt reference, preserving the reservation even if the site retires. The registry works with either construction completion order; no claim is considered ready until both operational belt scenes exist.
- `get_ready_candidate()` reruns `ConveyorExistingEndpointFinder.inspect_pair()` against the completed physical belts, and requires the original mode, turn, and junction to match. Moving a belt or filling a connection invalidates readiness at the final check; physical connection is still **not** committed at this stage.
- `reservation_ready(reservation_id)` fires once after both completed belts satisfy the current geometry. This is a signal for a future E2c activation transaction, **not** authorization to skip revalidation or connect in E2b.
- Cancelled or unexpectedly removed construction sites, demolished completed conveyors, and explicit release all free both endpoint claims. Keys remain stable even after ConstructionSite instances are freed.
- `res://tests/planned_conveyor_reservations_e2b_test.tscn` has **16 focused checks and awaits developer F6 execution**. Test completion ordering, exclusive claims, source/receiver cancellation, mid-chain sites, stale geometry, unexpected deletion and cleanup before enabling this service in the sandbox.

**Next step:** E2c may bind this service to player planning, reserve a contiguous blueprint route, render planned corner geometry and physically commit using the existing `ConveyorExistingConnection` transaction only when both neighbors are complete. Add separate corner cargo, demolition, item-conservation and Build Mode regression tests. Main scene remains unchanged.

---

### E2c1 — Isolated post-construction physical activation (staged)

The `PlannedConveyorRouteActivator` Node listens for a validated E2b registry's `reservation_ready` events. It does not inspect or connect live neighbors on its own, and is not yet installed in the Factory Testing Sandbox or Main scene.

- The adapter calls `get_ready_candidate()` to verify both reserved endpoints are **completed ConveyorSegments**, mutually free, correctly oriented and located at the originally recorded junction. An unbuilt blueprint never receives cargo.
- The adapter delegates the actual physical transaction to `ConveyorExistingConnection.try_connect_candidate()`, which revalidates the candidate and uses the already-proven real direct, right-corner or left-corner conversion path. Successful activation requires reciprocal `next_segment` / `previous_segment` references.
- Successful connections release only their own endpoint reservation claims. Failed or out-of-date connections keep their reservations; `try_commit(id)` explicitly retries after the physical cause is corrected. Completed belts are never silently connected to a second occupied endpoint.
- This stage tests runtime connection/cargo conservation, not blueprint visuals. `res://tests/planned_conveyor_activation_e2c1_test.tscn` includes **15 F6 checks pending developer validation**; the prior E2b reservation checks passed **16/16**.
- **E2c2 remains necessary:** bind the isolated services to player P-mode in the Factory Testing Sandbox, create planned route claims on placement, convert transparent straight placeholders to directional L-shapes, and validate mouse/keyboard, build-order independence, resource conservation and demolition. Do not enable E2c1 automatically in Main.

---

### E2c2 — Opt-in player-sandbox connected belt plans (staged)

`WorldInteraction.enable_connected_conveyor_blueprints` defaults to **false** and is explicitly enabled only in the Factory Testing Sandbox. After the player places an E1 straight belt plan, `BlueprintConveyorRouteCoordinator.register_new_site()` finds eligible adjacent planned conveyor endpoints and requests E2b **exclusive** directed reservations. A transit site may have one independent input and output claim.

- The planned **source** changes presentation only when the reserved route requires a right or left turn. `ConstructionSite.set_planned_conveyor_turn()` uses the existing `ConveyorCornerVisualMesh`, copies the true corner `OutputEndpoint` transform and shows a corresponding turn arrow. The site still has no real cargo, inventory, transport, building-port link, or combat function.
- E2b's new `reservation_released` signal notifies the coordinator after a claim is removed; `WeakRef` prevents dangling placeholder references. Cancelling a planned receiver safely returns its unfinished source to the original straight mesh, output marker and arrow.
- The validated E2c1 activator listens to that same registry. Once both physical conveyors are constructed, it revalidates the junction and uses the existing `ConveyorExistingConnection.try_connect_candidate()` transaction, including the proven in-place right/left runtime corner conversion and cargo-conservation paths.
- A compact conveyor progress label reduces previously observed adjacent `PLANNED 0%` overlaps without changing building labels.
- **17/17 scripted checks and all six manual player-control steps PASSED** in developer-run Godot 4.6.2. The corner-blueprint visuals and normal P-off Build Mode were manually accepted. Correct receiver orientation is a graph requirement for initial placement. Independent manual retesting confirmed E authorization of an already placed site does not depend on the current preview rotation; no authorization-code fix is required. Before feature expansion, rerun the four previously validated compatibility suites (16+15+6+8 = 45 checks).
- This first version discovers **blueprint-to-blueprint adjacent belts only**; it does not yet plan ports on unfinished Storage or completed machinery, resolve longer gaps, handle every route editing pattern, supply construction materials, or implement physical electrical coverage. Those remain separate tested phases before Main is enabled.

---

### E3a — Read-only unfinished building-port geometry (staged)

`PlannedBuildingPortGeometry.inspect_pair(building_site, belt_site, input_side)` checks a **job-backed unfinished** building's planned port marker against a planned straight conveyor's future physical endpoint. The direction convention is defined from the building: `input_side=true` means **conveyor output → building input**, and `false` means **building output → conveyor input**.

- Uses the same `LogisticsConnectionGeometry.are_endpoints_aligned()` and `ConveyorSegment.CONNECTION_GAP` as real logistics. No magic transfers, new snapping tolerance or active port classes are introduced.
- Preserves future Storage input and output as independently identifiable exact world-space endpoints. Rotated building and belt transforms work; misalignment, reverse-facing belts, wrong ports and distant endpoints fail closed.
- Accepts PLANNED, QUEUED, CONSTRUCTING and PAUSED construction-site jobs. Rejects cancelled and already completed sites. It creates **no** active inventory, `ItemPortComponent`, cargo movement, route reservation, completion or worker/material/power availability.
- `res://tests/planned_building_port_geometry_e3a_test.tscn` passed **15/15** in developer-run Godot 4.6.2. The prior post-E2c2 compatibility suite passed **45/45**.
- **E3b planned resource ownership:** Explicitly reserve the building's input/output side and conveyor's corresponding endpoint; share claims safely with E2b's conveyor-to-conveyor registry and existing `ConstructionSite.reserve_conveyor()` pending live-belt reservations. Maintain exclusive occupancy and release on cancellation, site removal and demolition; retain stable references after construction sites retire.
- **E3c activation:** Only connect once BOTH real building and real belt are completed, and require reciprocal `ItemPortComponent.connected_conveyor` / `ConveyorSegment.input_building_port` or `output_building_port`. Test both completion orders and ore conservation across upstream belt → Storage → downstream belt. No activation without power/material/worker readiness.
- **E3d sandbox UI:** Add optional future port-snapping to building blueprints after independent geometry, reservation and cargo tests. Keep Main disabled, and no standalone save system prior to the integrated save/load architecture.

---

### E3b — Isolated future Storage input/output reservations (staged)

`PlannedBuildingPortReservations` accepts the previously validated E3a directed geometry and records two immutable claims for each planned connection: one future building side (`building_input` or `building_output`) and one conveyor blueprint side (`belt_output` or `belt_input`).

- Both sides can be reserved independently for the same Storage blueprint, with separate site lifecycle observers. A site may finish before its conveyor or vice versa; a completed Storage or belt is retained after its temporary `ConstructionSite` leaves the tree.
- `reservation_ready` is advisory only. `get_ready_candidate()` checks the **real** port and belt instances again against original junction position, facing, endpoint vacancy and building-port occupancy. It creates no connection, transport, material delivery or power availability.
- Cancelled or unexpectedly removed blueprints and demolished built endpoints release both claims using immutable keys. Raw `Variant` validity checks precede casts to already-retired objects, avoiding the earlier E2b freed-site failure.
- Existing `ConstructionSite.reserve_conveyor()` legacy live-belt reservations cannot be overwritten by E3b.
- `res://tests/planned_building_port_reservations_e3b_test.tscn` **passed 18/18 in developer-run Godot 4.6.2**.
- **E3c0 shared authority is now staged:** `PlannedEndpointClaimBroker` atomically protects the same `in/out` belt keys across both E2b and E3b when their registries are configured with one broker. Distinct owner tokens avoid accidental cross-registry releases. The new 18-check E3c0 scene must pass before sandbox integration. Each registry's old independent checks remain in place for backwards compatibility.
- Once claims are globally exclusive, reuse existing `ConveyorSegment.try_connect_building_port()` only after both real instances are completed and revalidated. Check reciprocal port references, item conservation, building-first/belt-first timing and stocked-object demolition protection. Main remains opt-out.

---

### E3c0 — Shared endpoint ownership for mixed blueprint routes (staged)

`PlannedEndpointClaimBroker` is an isolated, non-operational Node. It protects the canonical `<ConstructionSite instance ID>:in/out` keys across belt-to-belt (E2b) and belt-to-Storage (E3b) reservations. Planned building ports use distinct `building_input/building_output` keys. Two endpoints are claimed in one synchronous operation or neither is claimed.

- Both registries now support an **optional** `set_claim_broker(broker)` before their first reservation; the same broker must be supplied to both for global exclusivity. Each existing local claim table remains in place to preserve old tests and standalone usages.
- Each registry-scoped owner token includes its Node instance ID plus local reservation ID, preventing one registry's `release()` from clearing another's claim. Broker release uses retained immutable strings and does not dereference freed construction sites.
- A belt's input may belong to an upstream belt while its output feeds a future Storage input, but its **same** output cannot simultaneously be reserved by both a downstream belt and a Storage input. Storage input and output remain independently reservable.
- No port reservations are automatically created in the player sandbox yet; the new broker has not been connected to `BlueprintConveyorRouteCoordinator`. E3c0 makes no physical links or item transfers.
- `res://tests/shared_blueprint_endpoint_ownership_e3c0_test.tscn` **passed 18/18** in developer-run Godot 4.6.2, covering route-first and Storage-first claim conflicts, transit chains, mixed inbound/outbound reservations, cancellation, unexpected removal, completed-belt destruction and clean release.
- **E3c1 after passing:** Revalidate both real endpoint transforms and exclusive claims, use the existing `ConveyorSegment.try_connect_building_port()` transaction to commit reciprocal real references once both constructions finish, and verify cargo conservation through Storage. Only then integrate all services into player placement with manual tests; preserve Main opt-out and the integrated save/load architecture.

---

### E3c1 — Completed Storage-port physical activation (staged)

`PlannedBuildingPortActivator` is a separate Node binding to the E3b reservation manager; it has not yet been wired into the player-facing Factory Testing Sandbox. As both job-driven construction sites complete, it tries a single safe transaction:

1. Revalidate E3b's read-only real-endpoint candidate, including completed/valid building and belt, original exact junction, free input/output endpoint, and physical facing.
2. Require the operational `ItemPortComponent` direction to match the *originally planned* side (Storage INPUT for belt → Storage; Storage OUTPUT for Storage → belt).
3. Delegate to existing `ConveyorSegment.try_connect_building_port(port)` for inventory-policy validation, real alignment and the reciprocal port/belt connection. Reject failure without altering cargo or clearing pending claims.
4. Verify both reciprocal references, then consume exactly this E3b reservation and any E3c0 shared-broker keys. Announce `connection_committed` only after the physical link and release succeed.
5. On stale geometry, occupied port or incorrect direction, retain the claim for a later explicit `try_commit(id)` retry. The existing operational `ConveyorBuildingTransfer` remains solely responsible for item loading/unloading, never the activator.

`res://tests/planned_storage_port_activation_e3c1_test.tscn` adds **18 pending F6 checks**, including a mixed E2b upstream route + two independent Storage ports using the same broker, building-first/belt-first construction, rotated ports, source buffering, full downstream buffer backpressure, port occupancy, stale-alignment retry, cancelled/destroyed endpoints, inventory conservation and disconnection cleanup.

**Compatibility boundary:** Main, `WorldInteraction`, sandbox scene, existing live conveyor modules, power/material/worker availability and integrated save/load are unchanged. E3c2 must separately wire the shared broker and both activators into player Blueprint Mode, validate planned Storage snapping and rerun older physical cargo suites.

---

### E3c2a — Sandbox-only mixed blueprint registration and activation (staged)

The `BlueprintConveyorRouteCoordinator` now supports `enable_storage_port_blueprints` configured **before** it enters the scene tree. When on, it creates one `PlannedEndpointClaimBroker`, shares it across the existing E2b conveyor-route registry and E3b building-port registry, and attaches both E2c1 and E3c1 activators. This prevents the same conveyor endpoint being reserved by two different route types.

- `WorldInteraction.enable_connected_storage_blueprints` defaults **false**, is enabled explicitly in Factory Testing Sandbox, and only takes effect with `enable_blueprint_planning` and `enable_connected_conveyor_blueprints`. Main remains opt-out.
- A newly placed Storage blueprint is registered after its footprint and planned ports exist; it inspects existing straight conveyor blueprints for either future input or future output. A newly placed conveyor checks for compatible planned Storage ports before checking other planned belt ends. All reservations depend on E3a geometry and E3c0 exclusive endpoint ownership; neither creates operational inventory or item transfers.
- Both construction jobs still require explicit authorization. The Factory Testing Sandbox alone has a debug override for future power/material/worker availability; Main will require real systems. Physical completion invokes the already-tested E2c1 or E3c1 transaction, which revalidates current geometry and reciprocal runtime links.
- `res://tests/connected_storage_blueprint_e3c2a_test.tscn` adds **16 Godot F6 checks pending developer execution** for Storage-first and belt-first planning, simultaneous input/output, multi-hop upstream belt routing, cargo conservation and backpressure, rotated Storage, cancellation, invalid facing and legacy right-corner behavior.
- This checkpoint **does not** yet supply cursor hard-snapping to unfinished Storage ports. The player must align the grid-positioned planned belt manually and face it in the correct direction. E3c2b will separately add preview snapping, connection cues and manual B/P/R/LMB/E/X testing, followed by a compatibility regression.
- No standalone save system is being added before the full gameplay save/load architecture is designed.

---

### E3c2b — Read-only future Storage port preview snapping (staged)

`BlueprintStoragePortSnapPreview` discovers the closest available input/output port on a still-unfinished `test_storage` blueprint and proposes the exact **straight-conveyor** transform. It reuses `ConstructionSite.get_planned_belt_transform()` and the proven 0.65-tile radius with no implicit change to the direction the player selected with **R**.

- Only job-driven, active construction sites and unclaimed future Storage ports are eligible. The old timed-site/live-belt reservation and new E3b blueprint port reservation are both respected. Markers on other building types are deliberately excluded from this milestone.
- The opt-in straight blueprint preview in `WorldInteraction` checks the raw unrounded mouse world position before grid rounding, then validates `ConveyorBlueprintPlacement.is_clear()` for the proposed transform. If valid, the ghost uses the exact hard-snap transform that the left-click placement will commit; otherwise it retains normal grid preview.
- The existing Sandbox-only `enable_connected_storage_blueprints` flag gates this behavior. The Main scene, ordinary P-off conveyor snapping, physical connections, cargo movement, power/material/worker availability and eventual integrated save/load design are unchanged.
- `res://tests/storage_blueprint_preview_snap_e3c2b_test.tscn` has **14 Godot F6 checks pending** for independent input/output, raw/fractional cursor, valid rotation, blocked/far targets, claim ownership, cancellation restoration, rotated sites, and Main opt-out.
- After scripted acceptance, manually test B → 5 → P, R to the required direction, move the ghost near unfinished Storage's IN/OUT markers, place and authorize/cancel via LMB/E/X. Review the visual snap and real cargo path before expanding this behavior to other production buildings or Main.

---

## 3. Spatial Occupancy and Port Reservation

1. Use `FactoryGrid` for deterministic planned footprint coordinates and 90-degree rotations. A logical occupancy/reservation registry is authoritative for planned, queued, constructing, and completed footprints; physics bodies remain a secondary obstruction test.
2. Preserve the established one-tile conveyor layout and fractional short-gap/corner geometry. Do not assume every shaped conveyor occupies exactly one unrotated square.
3. Generalize planned port IDs beyond a single `InputPort` / `OutputPort`: future splitters, mergers and machines can expose multiple unique port markers. Keep endpoint direction and final-world transform.
4. Reservations identify both intended endpoints (site/job and optional completed entity). They do **not** add a runtime link, open a cargo path or occupy a completed port prematurely.
5. On activation, instantiate the completed entity once, initialize its definition, recheck spatial occupancy and port compatibility, and convert **only valid** reservations into real physical connections. Invalid/moved/deleted neighbors remain disconnected; they must never force invalid connections or lose cargo.
6. For **planned conveyor pieces**, do not instantiate `ConveyorSegment` cargo inventories/timers until completion. A blueprint belt should be a geometric site with direction, endpoints and reserved links, not a paused operational belt.

Activation must be idempotent, so neither simultaneous job completion nor repeated callbacks can create duplicate entities or duplicate transfers. Preserve the existing safe-disconnection and salvage paths for completed structures.

## 4. Power Network and Coverage

Power is an explicit connected network, not a circular area that creates electricity.

**Proposed services and components:**

- `PowerGridService`: owns a graph of links between completed Main Hub, Power Stations and Power Poles. Recomputes energized connected components after placement, damage, destruction or link changes.
- `PowerNodeComponent`: identifies a node's stable network ID, optional generation, connection limit, relay link range and energized state.
- `PowerConsumerComponent`: declares operating demand/priority, reports whether power was allocated. Initially used only in opt-in scenes until power gating has its own tests.
- `ConstructionCoverageService`: reports whether a position is within energized construction-service coverage. It does not declare that the position is safe from zombies.
- `DroneChargingComponent`: reports charger tier, service area, maximum charging rate and available slots. Charging is limited by the energy allocation the actual connected network can provide.

### Network invariants

- The Main Hub provides limited bootstrap generation and a small initial construction-service area.
- Power Stations increase available generation, **provided they are actually linked to the energized network**.
- Power Poles extend reach only if a real valid graph path connects them back to a generator/Main Hub. Two visually overlapping coverage circles are not, by themselves, a powered connection.
- A disconnected, destroyed, disabled or undersupplied pole cannot create construction coverage or charge a drone.
- A planned or unfinished pole does not transmit electricity. To extend outward, complete a reachable pole, then use its new coverage to authorize the next frontier job. Plans may extend beyond current coverage while waiting.
- Defense coverage is separate from power coverage. A powered factory outside the defensive perimeter remains vulnerable, and placing an uncompleted turret does not secure territory.
- An early demo may use a simple deterministic link/priority allocator before realistic voltage, cable losses, topology redundancy, and electrical animations.

**Link formation is a design choice to validate:** a simple visible link within a finite relay-to-relay distance could be selected automatically at placement, then stored as a graph edge. Do not infer an electrical edge solely from overlapping construction/charging areas.

### Three proposed charging tiers

| Tier | Construction/service reach | Charger ceiling | Energy rule |
| --- | --- | --- | --- |
| Basic Power Pole | Small | Slow | Needs an energized link and sufficient allocated power |
| Advanced Power Pole | Medium | Moderate | Same rule; higher demand at full rate |
| Industrial Power Relay | Large | Fast | Same rule; largest demand and potential worker-drone support |

All distances, charge speeds, battery capacities, concurrent drone slots and watt-equivalent values remain **unbalanced placeholders until tested**. Upgrading a pole must preserve its identity and connected-network bookkeeping without inventing power.

The actual drone recharge per time step is bounded by **battery missing capacity**, **pole's tier rate**, and **energy delivered by the grid**. An energized but overloaded network must slow or stop recharge. Worker construction range and the player's AI drone flight/return range remain separate mechanics.

## 5. Suggested Build Order and Test Gates

**Gate A — conveyor regression (current):** automated and manual tests for planned input/output snapping, rotation, corners, waiting cargo, delayed connections, blocked flow, safe disconnect/demolition and conservation. Keep the earlier full physical logistics suites.

**Gate B — isolated construction job:** introduce data/job state classes, test authorization, pending reasons, progress/pausing/resuming, cancellation and single activation. No live `WorldInteraction` replacement.

**Gate C — universal construction site:** support multiple building definitions and non-operational planned conveyor geometry; test actual built entity parity, port identities and safe deletion in F6. Retain old sandbox routing until replacement passes.

**Gate D — Blueprint Planning Mode:** plan, inspect, cancel, authorize and queue a compact layout. All planned footprints block conflicting placement while producing no cargo or defense.

**Gate E — power core:** Main Hub generator, disconnected/connected relay graph, small bootstrap construction coverage, power station generation and demolition/reconnection tests.

**Gate F — charging/worker foundation:** tiered charge ceiling versus allocated electricity; workers progress eligible construction only with the required materials and power. Keep it test-driven and finite.

**Gate G — First Night slice:** ammunition logistics, powered and supplied defensive expansion, bounded zombie spawn/wave pressure, and one demonstrably complete objective.

For every gate, run focused Godot F6 scenes, then selected conveyor/cargo-conservation and combat/salvage regressions before enabling the behavior in Main.

## 6. Persistence Boundary, Not an Independent Save System

The eventual unified game save/load schema must own building IDs, transforms, blueprint/job states, progress, delivered-material ownership, completed inventories, conveyor topology, power graph, upgrades and drone batteries. Introduce serializable stable identifiers now if needed, but **do not write a standalone blueprint save file or a competing persistence manager**.

## 7. Out of Scope for the Current Demo

Additional planets or enemy factions; interplanetary travel; complex electrical simulation; full research tree; elaborate 3D art; unrestricted construction drones; disconnected save-file systems.

**Next verification:** run `res://tests/planned_storage_bidirectional_conveyor_test.tscn` in Godot 4.6.2 and manually validate both planned ports and corner paths before changing production Build Mode.


---

## E3d5a — Priority Queue Foundation (Implemented; Godot Verification Pending)

ConstructionJob's `priority` is one of High (0), Normal (1, default), or Low (2). The new sandbox-only `BlueprintConstructionPriorityQueue` tracks authorized jobs while they are in QUEUED state. It orders eligible waiting sites by priority and uses stable authorization order to break ties. Reprioritizing a queued job changes its place in the next read-only queue snapshot. Cancellation, construction start, and freed sites remove jobs from future waiting snapshots.

The selected-blueprint tool (Q) assigns H/N/L priority without authorizing work. Priority is per job, not per conveyor network or category, so player intent overrides default structure examples. Jobs currently CONSTRUCTING cannot be reprioritized: priority is a **future dispatch preference**, not an interrupt or preemption command.

**Safety boundary:** This queue is intentionally bookkeeping only. It never calls `ConstructionJob.set_availability()`, `advance()`, or `authorize()` and never sets worker capacity. Until a real WorkerDroneConstructionService and real power/material services are connected, the testing sandbox's explicit debug override continues to start authorized jobs immediately. Future worker dispatch must use the queue ordering, finite capacity and external readiness gates; it must not start jobs just because they are High priority.

Godot acceptance gate: `res://tests/blueprint_construction_priority_e3d5a_test.tscn` — **15/15 checks passed** locally on 2026-11-10 (developer screenshot); manual Q → H/N/L assignment verified via developer screenshot (6 selected, High 2 / Normal 2 / Low 2); the automated tests validate E authorization, while a separate manual post-E screenshot is still outstanding.



## E3d5b — Worker Slot Dispatch Foundation (Test Only; 15/15 F6 Passed)

`BlueprintConstructionSlotScheduler` is an isolated, explicitly configured worker-capacity scheduler built on the existing `ConstructionJob` state machine and `BlueprintConstructionPriorityQueue`. It records each authorized construction site once, retains FIFO registration order within High / Normal / Low tiers, and dispatches only jobs that have **explicit external power and material readiness snapshots**. Unknown readiness is treated as unavailable, not assumed available.

Each worker slot can service one currently constructing job. Jobs with missing power/material requirements do not consume a slot. Active work is non-preemptive. Lost readiness causes a pause with original progress preserved; the slot is released and a later eligible job may start. A paused job resumes only when the relevant external readiness is restored **and** capacity exists. Cancellation, destruction and job completion remove the corresponding active assignment during reconciliation. The scheduler never calls `advance()`, injects materials, generates power, or instantiates real drones.

**Current boundary:** No actual power/material providers or worker drone entities are present in this checkpoint. All availability booleans in `res://tests/blueprint_construction_slots_e3d5b_test.tscn` are controlled test inputs. The service is **not activated** in Main or the Factory Testing Sandbox, protecting current immediate debug construction and preserving E3d5a/H-N-L selection and Ctrl+E behavior.

**Validation gate passed:** Developer-provided Godot 4.6.2 screenshot confirms all 15 E3d5b F6 checks passed on 2026-11-10. The scheduler remains isolated; the next gate is verified power/material services, followed by finite physical worker-drone dispatch.


## E3d5c1 — Read-only Readiness Probe (Isolated; F6 Pending)

`BlueprintConstructionReadinessProbe.inspect(site, power_report, stock, required_materials)` is a read-only inspection service, not a constructor, job authorizer, material delivery service, reservation authority, power grid, or scheduler adapter. Its result describes `authorized`, `power_known`/`power_covered`, `bill_valid`, `stock_known`/`stock_sufficient`, and a per-item `missing_materials` map. An unknown power report is null; only a genuine Boolean is considered a known power observation. Stock must be a live `InventoryComponent`, and the caller's provisional bill must be nonempty with positive integer costs keyed by `ItemDefinition`.

**Critical distinction: stock sufficiency is not committed materials.** Two sites can read the same available inventory; this probe never removes, reserves, delivers, refunds, or owns a single item and never calls `ConstructionJob.set_availability()` or `BlueprintConstructionSlotScheduler.update_requirements()`. Even a report showing covered power and sufficient stock is **NOT** permission to dispatch. Building definitions do not yet contain actual material costs, and there is no real power-coverage provider. The probe therefore cannot safely activate normal construction.

**Integration contract for later checkpoints:** (1) definition-driven positive construction costs; (2) an atomic resource reservation/escrow transaction that prevents double claims, tracks ownership per job and supports cancellation/salvage; (3) a genuine power-coverage service with unknown/outage handling; (4) a sandbox-only coordinator that passes true material readiness to E3d5b **only after** confirmed per-job reservation and verified power readiness, with worker capacity remaining independently bounded and construction timers controlled by ConstructionJob. Active jobs stay non-preemptive; power outages pause and preserve work; consumed/reserved material policy must be explicit. Maintain the current debug override separately until the fully integrated pipeline passes tests.

**Verification:** `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn` has 15 staged checks; local Godot F6 validation is pending. Main and Factory Testing Sandbox remain untouched. Future player-facing queue management should offer clickable controls in addition to H/N/L shortcuts.

## E3d5c2a — Isolated Construction Material Escrow (Godot F6 Pending)

`BlueprintConstructionMaterialEscrow.reserve(site, source, costs)` supports an authorized, live QUEUED ConstructionSite, a single live InventoryComponent and an explicit nonempty dictionary of valid ItemDefinition → positive integer quantities. It verifies the entire bill before any synchronous withdrawal, and tracks held items under a stable reservation ID. Duplicate site reservations and competing claims cannot reuse already-debited inventory stock. A stock-sufficiency snapshot (E3d5c1) must never be misread as an actual reservation.

`recover_to(id)` attempts to return the entire held bill to its original source; `recover_to(id, alternate)` permits another live inventory. When full recovery is not possible the entire in-memory record remains held, `needs_recovery(id)` is true and no capacity-unsafe transfer is initiated. Job cancellation and unexpected site exit try recovery automatically. A successful `ConstructionSite.building_completed` signals real activation; `commit_built(id)` then finalizes the expense once, never before a real building exists.

**Safety limitations:** This is a single-source, memory-only prototype. There is no serialization, multi-source delivery, per-definition construction bill, stocked-site demolition recovery, power coverage, physical drone, or player recovery UI yet. It must NOT be enabled in Main or the Factory Testing Sandbox until those separate requirements are implemented and tested. Escrow does not call ConstructionJob.set_availability or scheduler.update_requirements; worker dispatch remains fail-closed. Future scheduling should acquire reservations in High → Normal → Low order after actual cost validation, and only verified real power plus owned escrow can permit workers.

**Developer validation:** E3d5c1 passed 15/15 on 2026-11-11. E3d5c2a's `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` has 16 staged checks awaiting local F6.

## E3d5c2b — Definition-Driven Construction Costs (Staged; F6 Pending)

`BuildingDefinition.construction_materials: Array[ItemAmount]` reuses the same typed Resource structure already present in `ProductionRecipe`. Nine built-in building definitions now contain nonempty provisional Test Ore/Test Ingot bills. These are *data metadata*, subject to balance revision; initial Main Hub supplies and the bootstrap route to the first Extractor/Smelter still need design.

`ConstructionMaterialBill.inspect(definition)` yields `{valid,error,costs}`, with `costs` an `ItemDefinition → int` map only when the bill is entirely valid. A null definition, missing list, null entry/item, blank item ID, zero/negative quantity or duplicate logical item ID invalidates the whole bill. `get_costs` returns a separate map for valid bills and empty map otherwise; the E3d5c2a escrow already rejects empty bills. The validator does not consume/hold materials or grant power/workers.

**Future dispatch contract:** Actual per-site escrow ownership from `BlueprintConstructionMaterialEscrow`, not observed warehouse stock, must supply material readiness. A genuine power-coverage service supplies the independent power gate; `BlueprintConstructionSlotScheduler` remains responsible for finite non-preemptive assignments. The explicit sandbox debug availability override is still active and is not real construction enforcement.

**F6 gate:** `res://tests/blueprint_construction_costs_e3d5c2b_test.tscn` — 17 checks pending in Godot 4.6.2. E3d5c2a escrow was previously accepted 16/16 on 2026-11-11. Main, Factory Testing Sandbox, production recipes, construction jobs, combat and conveyor transport remain untouched.

## E3d5c3a — Explicit Power Topology and Full-Footprint Coverage (Staged; F6 Pending)

`ConstructionPowerNetworkNode` is an isolated prospective source/relay holder, offline and non-operational by default. Its `is_source`, `source_online`, `operational`, `link_range`, and `coverage_radius` values are supplied by the 16-check test fixture. No real Hub or Power Pole scene currently provides these properties.

`ConstructionPowerCoverageNetwork` owns weak references to registered nodes and explicit undirected edges; no two circles or coverage radii are allowed to imply a valid electrical connection. A node is energized only if a live, operational source that is online reaches it through a chain of operational nodes and range-valid explicit edges. Coverage is recomputed from current positions and flags each query, so removing/moving/disabled relays or losing an online source immediately removes coverage. No power demand is accounted for in this stage, and no generator is actually producing resources.

`covers_site(site)` is a **read-only geometry observation** for nonterminal opt-in `ConstructionSite` jobs. It requires **all four corners of the actual rotated building footprint** to lie inside a single energized source/relay service radius. The single-node rule is deliberately conservative; multi-relay union coverage may be evaluated as a separate future design decision. The function can report coverage for an un-authorized planned site as a preview, but it never modifies the site, job, worker scheduler, escrow, inventory or timer. Coverage does not equal safety from enemy attacks or a powered factory production connection.

**Hard boundary:** Source/operational booleans in this implementation are synthetic test inputs, not verified generator/electricity data. The checker must **not** feed `BlueprintConstructionSlotScheduler.update_requirements(power_ready=true, ...)` until physical completed sources/poles and a real generation/consumption allocation are integrated, and the already-tested material escrow is held by the specific construction site. No Main or Factory Testing Sandbox enablement occurs in E3d5c3a.

**Test:** `res://tests/construction_power_coverage_e3d5c3a_test.tscn` contains 16 isolated F6 checks A–P awaiting local Godot 4.6.2 verification. E3d5c2b definition costs passed 17/17 on 2026-11-11.

## E3d5c3b1 — Power Ownership by Completed Structures (Staged; F6 Pending)

Prototype power production is no longer represented *only* by manually setting a synthetic flag on a standalone test node: `PrototypePowerStructure` is a real Node3D scene runtime with a `BuildingHealthComponent` and its own `ConstructionPowerNetworkNode`. `prototype_main_hub.tscn` is a **prebuilt starter Hub fixture**, rated at **12 units of nameplate production** and initially enabled. `prototype_power_pole.tscn` is a relay scene (zero generation) that can be created by `ConstructionSite` only after completing the new `prototype_power_pole.tres` construction definition (6 seconds and a provisional 2 Test Ingots). Neither appears in Main or the Factory Testing Sandbox.

The runtime synchronizes node operational state with *the actual completed building's* in-tree lifecycle, health, and service switch. A generator must additionally be enabled and have a positive generation rating to mark `source_online`. A pole cannot claim source status or generate power. A planned, queued, or half-built pole has no operational node in the network; completion instantiates a real scene but does not automatically wire any electrical link. `ConstructionPowerCoverageNetwork` still requires an explicit valid path and full-footprint coverage. Newly added parent queue-for-deletion validation makes scheduled destruction stop power immediately, before the following frame.

**Critical separation:** A positive nameplate generation rating is *not* proof of sufficient remaining power after consumers are served. This checkpoint models completed structure ownership and source up/down state, **not** power generation economics or allocation. No `ConstructionJob` availability flag, material escrow, worker assignment, drone energy or build time is advanced by the power runtime. Do NOT forward `covers_site() == true` as true power readiness until verified demand/allocation, completed-entity state and per-site material escrow are integrated behind a sandbox-only feature gate.

**Validation:** E3d5c3a 16/16 passed in developer Godot 4.6.2 on 2026-11-11. `res://tests/completed_power_structures_e3d5c3b1_test.tscn` stages 16 checks A–P pending local F6. After it passes, rerun `res://tests/construction_power_coverage_e3d5c3a_test.tscn`. Main and regular sandbox construction remain isolated.

### E3d5c3b1 — Developer Verification Update (2026-11-11)

The dedicated `res://tests/completed_power_structures_e3d5c3b1_test.tscn` test is accepted: 16/16 A–P passed in developer-run Godot 4.6.2, with no errors visible in the supplied Output. Source enable/disable, completed pole ownership, operational relay link, damaged structure shutdown and held job-readiness gates passed in the isolated fixture.

**Outstanding regression:** `res://tests/construction_power_coverage_e3d5c3a_test.tscn` has not yet been rerun following the parent-queued-for-deletion guard. Wait for its 16/16 confirmation before advancing to an actual power budget allocator. This does not enable Main/Factory Testing Sandbox power consumption.

## E3d5c3b2 — Isolated Finite Nameplate Power Allocation (Godot F6 Pending)

**Prior milestone acceptance:** Post-E3d5c3b1 rerun of `res://tests/construction_power_coverage_e3d5c3a_test.tscn` passed 16/16 on 2026-11-11, confirming the owning-parent deletion guard is compatible; together with E3d5c3b1 16/16, the power foundation has 32/32 accepted checks.

**Topology:** `ConstructionPowerCoverageNetwork.get_operational_component(start)` enumerates explicit live, range-valid operational node connections, even if a component is unpowered; it never asserts generation. `PrototypeConstructionPowerAllocator` groups construction consumers by the energized node containing their *entire rotated footprint*. Within each explicit connected component, it sums only `PrototypePowerStructure` generators whose real completed instance is live/intact/enabled and whose child power node is owned by that instance. A bare synthetic `ConstructionPowerNetworkNode.is_source/source_online` does not count as real generation. Disconnected sources cannot contribute to one another until a valid explicit edge connects their components.

**Budget discipline:** An opt-in authorized QUEUED/PAUSED/CONSTRUCTING site requests a positive finite whole-number power demand, supplied explicitly by the test fixture (not yet from BuildingDefinition). The snapshot allocates a site's entire demand or zero, never a partial electrical permission. Existing constructing work receives budget first; among waiting jobs, priority High → Normal → Low with stable registration order. Nameplate output is the upper bound on total simultaneous allocations inside each component. Recomputing on each query removes grants after outage, structural damage, link removal or reduced rating. In heavily overlapping separate powered components the first registered fully covering energized node is chosen deterministically; selection optimization remains future work.

**Important semantics:** These allocations are **observations, not construction authorization or stable power reservations**. The service never calls `ConstructionJob.set_availability`, `BlueprintConstructionSlotScheduler.update_requirements`, `ConstructionSite._process`, inventory transfer or material escrow. A future scheduler coordinator must use per-site committed escrow ownership plus verified allocations and bounded worker assignments, with a deliberate update/reconcile order and no oversubscription. A physical source's current nameplate rating is still only a prototype budget until real generation/fuel and consumer metering rules are introduced. Pauses due to power loss are not yet triggered by this standalone allocator; they belong to the future coordinator.

**Test and safety gate:** `res://tests/finite_construction_power_e3d5c3b2_test.tscn` stages 18 A–R checks pending Godot 4.6.2 F6. On passing, rerun E3d5c3a and E3d5c3b1 (32 checks). Main, Factory Testing Sandbox, existing construction, defensive combat and physical logistics remain untouched.

### E3d5c3b2 — Validation Note: Test Harness Corrected (2026-11-11)

The first Godot F6 attempt hit a typed-argument error in the *test itself*: passing a freed `ConstructionSite` to `get_allocated_units()`. The allocator's underlying source, budget, and graph code was not changed. The focused correction verifies freed-site eviction using a pre-free snapshot size and `WeakRef`, without calling methods with invalid typed objects. E3d5c3b2 remains **unverified** until all 18 A–R checks pass locally, with no debugger errors. This does not activate the allocator in the Factory Testing Sandbox or Main.

### E3d5c3b2 — Verified Dedicated F6 Result (2026-11-11)

Developer-provided Godot 4.6.2 Output screenshot confirms **18/18 A–R passed** for `res://tests/finite_construction_power_e3d5c3b2_test.tscn`, after correcting the test-only use-after-free at Q. This establishes isolated validation of finite nameplate allocations, component separation/merging, operational priority behavior, source outages, destroyed nodes, and no automatic construction progress.

**Compatibility gate pending:** The additive `get_operational_component()` topology helper and new allocator should be followed by fresh runs of `res://tests/construction_power_coverage_e3d5c3a_test.tscn` and `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (32 combined checks) before a worker/material/power coordinator is attempted. Do not confuse current nameplate-budget observations with reserved, delivered real energy; the live sandbox remains unchanged.

## E3d5c3c1 — Isolated Readiness Coordination (Staged; F6 Pending)

**Power regression gate passed:** E3d5c3b2's 18/18 allocator tests and fresh developer E3d5c3a 16/16 plus E3d5c3b1 16/16 F6 runs give **50/50 passing power checks** on the current implementation (2026-11-11).

`BlueprintConstructionReadinessCoordinator` is a **test-only Node** that composes existing services in the following order per `reconcile()`: (1) discover authorized, fully gated jobs with valid `ConstructionMaterialBill` data; (2) in active-first, High → Normal → Low FIFO order, reserve the entire job-specific bill from one actual InventoryComponent using `BlueprintConstructionMaterialEscrow`; (3) only for verified per-job escrow, register its finite construction energy demand with `PrototypeConstructionPowerAllocator`; (4) compute bounded power availability and pass independent power/material flags to `BlueprintConstructionSlotScheduler.update_requirements()`; (5) run the existing scheduler, which alone grants/releases workers and updates ConstructionJob state. The coordinator never calls `advance()`.

A construction site requires all three baseline power/material/worker gates and must be in QUEUED when first registered. Existing CONSTRUCTING work is not preempted by later HIGH authorization. A power outage revokes readiness, pauses the job and releases its worker; escrow and elapsed time remain. Material shortages cannot consume scarce electrical allocation. Cancellation and actual construction completion use existing escrow signals to refund or commit; the coordinator drops completed/cancelled sites, and does not pass freed typed objects to service APIs.

**Limits and unresolved prerequisites:** Source energy is the existing test-only **completed-generator nameplate budget**, not metered or committed supply. The coordinator owns no physical drones or power production, cannot persist escrow, and does not select a genuine Main Hub inventory/delivery path. Synchronous reconciliation must occur before any world timer is advanced, and future live integration needs a robust invalidated-service/shutdown pathway, save/load, starter-stock bootstrap, charging and world destruction handling. The isolated test is not installed in Main/Factory Testing Sandbox and must not be enabled as live readiness without these gates.

**Validation:** `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` stages 18 A–R checks for materials, priorities, bounded worker/power capacity, outages, progress, cancellation and completion, awaiting developer-run Godot 4.6.2 F6. After passing, rerun E3d5b, E3d5c2a and E3d5c3b2 focused regression suites.

### E3d5c3c1 — Acceptance Note and Remaining Integration Gate (2026-11-11)

**Developer F6 result:** The isolated `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` passed **18/18 checks A–R** in Godot 4.6.2 with no errors visible in Output. Scarce real inventory, per-site escrow ownership, finite prototype nameplate allocation, one worker slot, non-preemptive scheduling, outages, elapsed-time retention, refunds and building activation all succeeded together in the test.

This is NOT live sandbox certification: the coordinator is not instantiated by WorldInteraction or Main, and no physical drones, save/load recovery, starter materials, actual generated energy or charging are wired. The required post-integration focused compatibility regressions are E3d5b 15, E3d5c2a 16 and E3d5c3b2 18, **49 checks pending**. Do not enable player-facing requirements until these pass and separate lifecycle recovery/energy-source invariants are validated.

## E3d5c3c2 — Explicit One-Time Prototype Hub Starter Stock (F6 Pending)

**Integration milestone:** E3d5c3c1's dedicated 18/18 plus fresh E3d5b 15/15, E3d5c2a 16/16, E3d5c3b2 18/18 compatibility suites constitute **67/67 isolated construction integration checks accepted** by developer Godot 4.6.2 screenshots on 2026-11-11. Factory Testing Sandbox is still separate and uses its developer debug gate bypass.

**Main Hub inventory:** `prototype_main_hub.tscn` gains a normal `InventoryComponent` child of capacity 40. It spawns EMPTY, keeping power structure creation independent of item creation. `PrototypeMainHubStarterStock.seed_fresh_hub(hub, bill)` is an explicit and only test-invoked bootstrap entrypoint. It requires an actual live `prototype_main_hub.tscn` instance with intact health, online owned power source, empty finite inventory and a valid nonempty bill of ItemDefinition → positive integer amounts with unique item IDs. It preflights all capacities, deposits the full loadout, and marks the Hub as seeded once. Repeated calls, even from a second service instance, do not create more resources. A pole or damaged Hub cannot be initialized this way.

**Prototype starter balance:** 20 Test Ingots + 8 Test Ore is sufficient to prototype early Storage, Extractor, Smelter and belt creation with current provisional bills, but this is NOT a final economy or a replacement for manufacturing. The system makes no transfers into construction jobs: the normal `InventoryComponent` and `BlueprintConstructionMaterialEscrow` still own all physical item changes. A real per-building materials logistics/delivery model and player-visible inventory UI remain unimplemented.

**Persistence safety:** The one-time per-Hub marker currently lives in runtime metadata, and escrow records are also in-memory. Without an authoritative saved state, neither may be considered secure against save/load duplication or material loss. Consequently this bootstrap is a TEST-ONLY foundation and must not be enabled in normal gameplay until persistence and migration are designed and tested. The current nameplate power allocator is still not actual metered electricity.

**Test:** `res://tests/main_hub_starter_inventory_e3d5c3c2_test.tscn` has 16 staged F6 checks A–P, pending developer validation. Once accepted, rerun existing completed power structures E3d5c3b1 (16) and construction readiness E3d5c3c1 (18) to ensure that the additional inventory child did not change power or coordinator behavior. Main and Factory Testing Sandbox scenes remain completely unchanged.

### E3d5c3c2 — Inventory Lookup Diagnostic (F6 Retest Pending)

The first isolated starter-inventory acceptance run failed before stock seeding at the first inventory availability assertion. The committed prototype Hub scene does declare `InventoryComponent` with the expected `InventoryComponent` script and capacity 40; the actual loaded instance did not yield a usable typed, in-tree inventory according to the screenshot. The root cause has not been verified.

For diagnosis, the F6 fixture now prints the live Hub child list, attached scripts and raw inventory-node type before safely stopping, rather than silently attaching a fallback inventory. The test remains isolated. Do not change bootstrap authorization, inventory stock counts, physical belt logistics, Main or Factory Testing Sandbox until the cause is clear. 16/16 acceptance and follow-up power/coordinator regressions are still pending.

### E3d5c3c2 — Godot TSCN Import Formatting Correction (Pending Retest)

The first bootstrap F6 attempts revealed that Godot instantiated the Hub without the `InventoryComponent` despite the local repository file declaring it. Investigation found `#` comments immediately preceding this final node. Godot documents `;` comments in TSCN; the scene has now been normalized by deleting those hash comments while leaving the inventory node, script, capacity and original power structure unchanged. This is a focused import/serialization correction, not a new source of material creation.

The only authoritative completion gate remains a fresh Godot 4.6.2 F6 run of `main_hub_starter_inventory_e3d5c3c2_test.tscn` with all 16 checks, followed by prior power-structure and readiness-coordinator regressions. Main and Factory Testing Sandbox are unchanged.

### E3d5c3c2 — Confirmed Godot Scene and F6 Acceptance (2026-11-11)

Godot 4.6.2 now shows `InventoryComponent` as a fifth direct child of `PrototypeMainHub` in the editor, and the dedicated starter-inventory scene passes all **16/16 checks A–P**. The prior missing-child issue was resolved after removing unsupported hash-prefixed comments immediately before the new node declaration in the TSCN. This correction added no synthetic inventory fallback or construction bypass.

The Hub's finite 40-slot inventory is empty when instantiated. The explicit opt-in bootstrap seeds a provisional 20-Test-Ingot/8-Test-Ore loadout only once; normal inventory transfer and per-site material escrow own later spending, refund and completion. Save/load persistence of the once-only marker and material escrow is still unimplemented.

**Remaining acceptance gate:** fresh E3d5c3b1 (16) and E3d5c3c1 (18) F6 runs must pass on the new Hub scene. Live Factory Testing Sandbox integration remains disabled, and prototype nameplate electricity should not be represented as metered energy supply.

## E3d5c3d1 — Read-Only Requirements Inspection for Future Sandbox UI (F6 Pending)

**Previous compatibility gate passed:** After the prototype Hub inventory addition, E3d5c3b1 completed power 16/16 and E3d5c3c1 readiness integration 18/18 reruns passed, plus E3d5c3c2 starter inventory 16/16, making **50/50 accepted** for the updated Hub-dependent suites.

`BlueprintConstructionRequirementsInspector.inspect(site, stock?, escrow?, power?, scheduler?)` returns a read-only dictionary describing the building, construction state, priority, progress, validated `ConstructionMaterialBill`, stock source presence and shortages, actual per-job `BlueprintConstructionMaterialEscrow` ownership, `PrototypeConstructionPowerAllocator` full-grant status and finite worker-slot assignment. Each service is optional and independently checked for live/in-tree validity. Missing providers or invalid bills never silently count as ready; warehouse stock sufficiency is only a *quantity observation* and is deliberately separate from escrow reservation. A pole's spatial coverage is not the same as a granted power demand.

The inspector does **not** invoke `ConstructionJob.set_availability`, `advance`, `BlueprintConstructionMaterialEscrow.reserve`, scheduler dispatch, resource movement or power-graph mutations. It can display a raw worker allocation that has not yet been reconciled after power loss, but never treats that pair of contradictory observations as all gates satisfied. The aggregate `prototype_gates_observed` is true only for constructing work with owned bill, full bounded prototype allocation, an active worker and cleared job wait reasons. `live_construction_ready` remains intentionally **false**, since nameplate-rated prototype power and simulated worker slots are not a production energy/delivery guarantee.

The existing `Factory Testing Sandbox` still sets `blueprint_sandbox_debug_requirements = true`; its bypassed job wait reasons must never be displayed as real supply evidence. No in-game UI was changed in this checkpoint. The planned next step after local F6 acceptance is a separately gated, clickable, **read-only** construction requirements panel that reports missing services without enabling real construction. Do not turn on live material/power/worker enforcement until save/load, physical delivery, actual generated electricity and safe disabling/destruction behavior are validated.

**Validation:** `res://tests/construction_requirements_inspector_e3d5c3d1_test.tscn` stages 18 checks A–R; local Godot 4.6.2 F6 pending.

## E3d5c3d2a — Clickable Read-Only Requirements UI (Isolated F6 Pending)

**Prerequisite accepted:** E3d5c3d1 inspector passed all 18/18 checks A–R in developer-run Godot 4.6.2 on 2026-11-11 with no errors visible in the Output.

`BlueprintConstructionRequirementsPanel` is an isolated, dynamically created CanvasLayer. A real top-right Button toggles a PanelContainer; the content uses `BlueprintConstructionRequirementsInspector.inspect()` only. The UI may receive an explicit weak-referenced target with `set_target()`, or resolve the first currently valid planned ConstructionSite from the existing `blueprint_area_selected` group. It can receive weak-referenced optional inventory/escrow/prototype power/scheduler services, but does not create them, mint materials, change priority, authorize, reserve, cancel, reconcile, or advance time. Freed/queue-for-deletion sites are not treated as active targets.

**Presentation guarantees:** Unknown service status is explicitly UNKNOWN; enough warehouse stock is distinguished from actual per-site escrow; an energized coverage circle is not proof of a bounded allocation; stale worker assignment after a generator outage does not imply readiness. The panel always shows **Live readiness: NOT VERIFIED** because the current prototype nameplate allocation and simulated worker slots are not actual delivered electricity or physical drone labor. There is no claim that the Factory Testing Sandbox debug construction bypass is real operational readiness.

**Isolation and next gate:** The standalone `res://tests/blueprint_requirements_panel_e3d5c3d2a_test.tscn` stages 18 A–R automated assertions plus a manual click-open/click-close check. No existing world/controller/sandbox scene is modified. Only after passing should a separate, disabled-by-default sandbox UI feature gate be considered. Live construction enforcement, physical resource delivery, save/load escrow and starter-stock persistence, real energy supply and drone labor remain outside this checkpoint.

### E3d5c3d2a — Automated Godot Verification Accepted (2026-11-11)

The isolated `blueprint_requirements_panel_e3d5c3d2a_test.tscn` passed 18/18 automated A–R checks in developer-run Godot 4.6.2. The test asserts the button's signal actions and inspector values, but **human visual and real mouse-click verification remain pending**. The Output's manual check instruction is not itself evidence that the on-screen panel can be clicked and read.

Until that manual step passes, E3d5c3d2a is automated-only accepted and no Factory Testing Sandbox hookup should be presented as verified. Keep source/fuel, persistence, logistics and physical worker-drone limitations separate from the read-only UI; `live_construction_ready` remains explicitly false.

## E3d5c3d2b — Sandbox Read-Only Panel Opt-In Gate (F6 Pending)

**Visual prerequisite:** E3d5c3d2a automated tests passed 18/18 and developer screenshots confirm the open panel is readable, scrollable, correctly labeled, and explicitly not live-ready. These screenshots alone do not prove physical close/reopen clicks.

`SandboxConstructionRequirementsFeatureGate` is a minimal Node with `@export var enable_read_only_requirements_panel = false`. The actual `factory_testing_sandbox.tscn` includes one disabled gate node. On an explicit opt-in, the gate checks that its parent has both `WorldInteraction` and `BlueprintConstructionSummary`, then attaches the accepted `BlueprintConstructionRequirementsPanel`. The panel queries the `blueprint_area_selected` group and existing validated ConstructionMaterialBill data, but is not connected to any real stock, escrow, power or worker provider in the sandbox. Consequently those statuses are UNKNOWN and `live_construction_ready` is permanently false. The gate never toggles WorldInteraction's `blueprint_sandbox_debug_requirements` flag, authorization, construction timers, cargo, build previews, priorities, or combat.

The isolated F6 fixture instantiates the actual sandbox PackedScene, switches the flag on before its `_ready`, checks display/selection/unchanged blueprint toggles, and leaves the panel visible for a manual game-window mouse test. **16 A–P checks await Godot 4.6.2 validation.** Only after acceptance should we decide whether to enable the UI by default in Factory Testing Sandbox. Main and all live requirement enforcement remain unaffected. Real delivery, battery/drone services, power demand and save/load must be validated before presenting production readiness.

### E3d5c3d2b — Developer F6 Automation Result (2026-11-11)

The isolated fixture `res://tests/blueprint_requirements_sandbox_e3d5c3d2b_test.tscn` passed **16/16 checks A–P** in developer-run Godot 4.6.2 with no errors visible in the supplied Output. It tested the actual Factory Testing Sandbox scene with its requirements-panel feature gate enabled only in that fixture; the committed sandbox remains default-off. Other providers are not connected and must continue reporting UNKNOWN; `Live readiness: NOT VERIFIED` remains mandatory.

**Manual gate remains pending:** Output messages ask for a click-close/click-open demonstration but do not establish that the button was actually clicked in the running game window. Before enabling the UI by default, verify the visible button and panel, real mouse toggling, and ordinary Q/drag blueprint selection within the sandbox. This checkpoint does not authorize construction or supply actual electrical/worker/material resources.

## E3d5c3d2c — UI Coexistence With Production Debug HUD (Pending F6)

**Observed conflict:** The E3d5c3d2b opt-in sandbox screenshot displays Construction Requirements over the Production Debug HUD. Existing `ProductionDebugHUD/InfoPanel` uses top-right screen coordinates; so did the standalone requirements panel. Visual acceptance must not hide established production debugging.

**Design:** The existing `BlueprintConstructionRequirementsPanel` keeps its standalone layout for isolation testing but exposes `dock_after_production_debug(debug_panel)`, called only by `SandboxConstructionRequirementsFeatureGate`. The gate fetches the existing top-right `ProductionDebugHUD/InfoPanel` Control and updates the requirements toggle/panel below its current global rectangle, allowing the InfoPanel to grow with selected building data. The requirements scroll area is bounded by the visible viewport. If the right side cannot hold at least a minimal scrollable area, the controls fall back to upper-left below the Factory Blueprints summary, without modifying either original HUD or construction systems.

The UI remains informational only: no job authority, readiness state updates, stock creation, power generation, escrow or worker assignment. Sandbox feature gate defaults to OFF; debug construction bypass remains ON. The standalone F6 `res://tests/blueprint_requirements_hud_dock_e3d5c3d2c_test.tscn` stages 10 automated nonoverlap, resize and read-only checks plus a real-mouse visual check (not yet completed). Post-change E3d5c3d2a/b compatibility tests are still required before default-on consideration.

### E3d5c3d2c — Verified HUD Layout in Developer Sandbox (2026-11-11)

Local Godot 4.6.2 F6 passed all 10 A–J adaptive HUD-docking checks. The running sandbox screenshot verifies a clear Production Debug HUD above the separate Construction Requirements button and panel, with Factory Blueprints visible at top-left and the selected planned Test Storage clearly displayed. No overlap appears in the submitted 1920×1080 frame. The UI still says UNKNOWN for unconnected material, power and worker providers and `Live readiness: NOT VERIFIED`.

Automated toggle signals pass but human mouse-click close/reopen is not documented by the screenshots. Post-change compatibility requires the E3d5c3d2a 18-check UI suite and the E3d5c3d2b 16-check sandbox gate suite. Until then, the live Factory Testing Sandbox feature gate remains **off by default**, and no real construction readiness or resource delivery has been integrated.

### E3d5c3d2b — Post-Docking Regression Confirmation (2026-11-11)

The developer reran `blueprint_requirements_sandbox_e3d5c3d2b_test.tscn` following the HUD dock changes; Godot Output confirms **16/16 checks A–P passed**. This adds to E3d5c3d2c's previously accepted 10/10. The standalone E3d5c3d2a 18-check suite has not yet been shown on the new dock code. The sandbox gate remains off by default.

The extra `Hit nothing` message is the old WorldInteraction empty raycast-selection log, unrelated to any failing UI assertion. The direct cause of that particular click is not demonstrated. Physical mouse press close/reopen still needs confirmation before the panel can be enabled by default. All stock, escrow, electrical, and worker service readiness remains UNKNOWN in the opt-in sandbox.

### E3d5c3d2a/b/c — UI Regression Matrix Complete (2026-11-11)

A fresh developer Godot 4.6.2 F6 run of the standalone read-only panel passed **18/18** E3d5c3d2a A–R tests after the docking change. Together with current-code E3d5c3d2b **16/16** sandbox and E3d5c3d2c **10/10** docking tests, **44/44 UI automated checks** have passed. The visible standalone report accurately separates sufficient free inventory from held materials and does not assert genuine readiness.

Only actual mouse close/reopen confirmation remains unverified. The sandbox's opt-in UI feature gate therefore remains OFF in the committed scene until physical interaction is confirmed, even though programmatic button signals have passed. No real inventory/escrow/power/worker providers are installed in regular sandbox gameplay; the UI must display UNKNOWN and Live readiness NOT VERIFIED. Real power delivery, material logistics, worker drones, save/load and non-debug construction remain separate milestones.

## E3d5c3d2d — Default-On Read-Only Sandbox Panel (Staged; F6 Pending)

The previous UI changes have **44/44 current-code automated checks accepted**. The developer has demonstrated a physical closed-panel state in a standalone test window, which verifies mouse-close behavior, but a physical close-then-reopen sequence has not yet been independently documented.

The opt-in model is deliberately narrow: `SandboxConstructionRequirementsFeatureGate` retains its **false script default**, while the real `factory_testing_sandbox.tscn` now explicitly sets `enable_read_only_requirements_panel = true`. This means only the developer Factory Testing Sandbox starts with a clickable Construction Requirements **button**. Its panel starts **closed** and opens on user click. The feature-gate `_ready()` still checks the real WorldInteraction and BlueprintConstructionSummary host; `dock_after_production_debug()` keeps the UI away from Production Debug, and `BlueprintConstructionRequirementsInspector.inspect()` alone supplies its data.

**Construction authority is unchanged:** No inventory, escrow, prototype power allocator, or scheduler is supplied to the real sandbox panel. Such fields remain UNKNOWN; `live_construction_ready` remains false even if debug construction completes. `blueprint_sandbox_debug_requirements = true` is intentionally untouched. Main's scene has no new feature gate, and conveyors, destruction, enemies, worker logic, and resource conservation are unchanged.

The focused `res://tests/sandbox_requirements_default_on_e3d5c3d2d_test.tscn` stages **12 A–L** checks (pending user Godot 4.6.2 F6). Revalidate the updated earlier b/c test fixtures (16 and 10) and manually click open/close/reopen while placing/selecting a blueprint in the normal sandbox. Future interactive construction-management buttons must call existing validated command paths with explicit authorization and gating, not simply set `ConstructionJob` readiness.

### E3d5c3d2d — Default-On UI Dedicated Test Accepted, Regressions Pending (2026-11-11)

The developer's Godot 4.6.2 screenshot confirms **12/12 dedicated F6 checks A–L passed** on the committed default-on Factory Testing Sandbox requirements button. The paired running sandbox image verifies HUD coexistence and accurate rendering of a selected High-priority Test Storage blueprint with its 3-ingot construction bill; stock/escrow/power/worker service readings are all UNKNOWN and live construction remains NOT VERIFIED.

This evidence demonstrates UI availability and observational safety, **not** physical delivery or real construction authority. The main game scene is unchanged; Factory Testing Sandbox debug requirements remain intentionally bypassed. E3d5c3d2b (16) and E3d5c3d2c (10) post-enable compatibility checks and regular sandbox physical mouse/placement smoke are still required before complete milestone acceptance. The button may be opened and closed without changing jobs, but automated `pressed.emit()` validation is not a substitute for confirming physical open/close/reopen.

### E3d5c3d2d — Compatibility Gate Progress (2026-11-11)

The developer reran E3d5c3d2b on the default-on Factory Testing Sandbox and supplied Output evidence confirming **16/16 A–P** passing. Alongside E3d5c3d2d dedicated **12/12**, this gives **28/38 verified automatic checks**. Running-window screenshots continue to show nonoverlapping Production Debug / Construction Requirements / Factory Blueprints HUDs and correct UNKNOWN service statuses.

The E3d5c3d2c HUD dock test with 10 A–J assertions remains pending on this default-on version. A physical mouse OPEN/CLOSE/REOPEN demonstration and normal sandbox blueprint/conveyor smoke also remain. Nothing in these checks grants power, workers or materials; sandbox debug bypass continues, and live readiness must remain NOT VERIFIED.

### E3d5c3d2d — Automated Acceptance 38/38 (2026-11-11)

The developer's updated E3d5c3d2c F6 screenshot confirms **10/10** adaptive HUD docking checks after default-on sandbox UI enablement. Coupled with E3d5c3d2d **12/12** and E3d5c3d2b **16/16**, all **38/38 current-code automated UI checks are accepted**. The existing selection, viewport docking and no-authority guarantees remain intact in these fixtures.

**Still required for final gameplay acceptance:** a normal `factory_testing_sandbox.tscn` F6 session with physical mouse OPEN/CLOSE/REOPEN, normal selected/deselected blueprints and a short conveyor placement/turn/delete smoke test. Running an automated test scene with a special fixture is not an exact substitute for regular sandbox interaction. Continue to treat provider data as UNKNOWN, `live_construction_ready` as false and the sandbox debug bypass as intentional until genuine power, material transport and worker systems are connected.

Once that manual smoke is confirmed, the next isolated implementation will be clickable High/Normal/Low selected-blueprint priority controls that reuse existing validated construction commands; no new construction readiness authority will be assigned to UI code.

## E3d5c3d2e — Optional Direct Click Inspection of Blueprint ConstructionSites (F6 Pending)

**Observed UX gap:** The sandbox's Q+drag tool controls the `blueprint_area_selected` set, and the read-only requirements UI initially only followed that group. A plain click on an existing ConstructionSite while in Blueprint Mode entered the normal primary placement path instead of inspecting it. Developer manual F6 screenshots confirm a blueprint present and the panel working, but the user reports the blueprint cannot be clicked. This is not yet accepted as fixed.

**New input boundary:** `WorldInteraction.enable_blueprint_click_inspection` defaults OFF and is enabled only for Factory Testing Sandbox. When the user left-clicks in Blueprint Mode outside Q-area selection, the existing ConstructionSite ReservedFootprint physics raycast on selection layer 2 identifies a managed site. If a signal listener exists, WorldInteraction emits `blueprint_inspection_requested(site)`, consumes that particular click and skips duplicate placement. Shift waypoint/route clicks retain their original handler; clicking empty ground continues the existing building/belt placement path. In neutral selection mode, a clicked planned or waiting site may also be inspected; production Main remains disabled. Q+drag, Shift-add, Alt-subtract and E batch authorization remain separate selection/command semantics.

The opt-in `SandboxConstructionRequirementsFeatureGate` listens only for inspection and calls `BlueprintConstructionRequirementsPanel.set_target(site)` + `set_open(true)`. Entering Q-area mode drops the pinned inspection target so the existing group-driven view is restored. This does **not** add the clicked site to the Q area-selection group, authorize a job, change priority, reserve items, allocate power or start a timer. Any power/escrow/worker services not actually connected remain UNKNOWN, and live readiness remains NOT VERIFIED. A site that is queued for deletion cannot be directly inspected.

**F6 acceptance gate:** `res://tests/blueprint_click_inspection_e3d5c3d2e_test.tscn` stages 16 checks A–P (including actual physics raycast and primary input), awaiting user Godot 4.6.2. Manual confirmation must show direct click on an existing blueprint opening the panel, Q+drag area selection intact, and no undesired placement/cargo/combat interference. Once passed, rerun the established relevant E3d4a/b and E3d5c3d2b/c/d suites. No real construction readiness authority is added.

### E3d5c3d2e — Isolated Click Inspection Automated Validation (2026-11-11)

The new `blueprint_click_inspection_e3d5c3d2e_test.tscn` passed all **16/16 A–P checks** on developer Godot 4.6.2, including a real reserved-footprint hitbox raycast, existing primary mouse input route, read-only signal dispatch, rejection of invalid or detached construction sites, isolation from batch-selection and job authorization, and no opt-in in Main. The requirements view shows Test Storage information while the area-selected counter can remain zero; this is correct by design.

This automated result does not establish normal Factory Testing Sandbox physical click success: the fixture itself sends input events, and only its open-panel state is shown. Before acceptance for actual gameplay, left-click a planned Storage in regular sandbox, verify no duplicate placement, then Q+drag a blueprint and confirm the area-selection highlight/count, and test a small conveyor route. Re-run E3d4a/b area-selection and E3d5c3d2b/c/d UI regressions before clickable priority controls. `Footprint blocked or preview invalid` following the automated PASS is a non-fatal debug message unless reproduced during a legitimate click/placement action.

Inspection cannot grant readiness, alter worker slots, reserve materials, allocate power or advance time. Sandbox debug-construction bypass remains on and live construction readiness remains NOT VERIFIED.

## E3d5c3d2d/e — Manual Sandbox Input Acceptance (2026-11-11)

Developer screenshots confirm single-click Storage blueprint inspection can display its read-only requirements while the Q batch selection count remains zero. Q+Drag separately highlights the Storage and sets `Selected: 1`. Conveyor inspection shows the conveyor's one-ingot definition cost, and a multi-turn conveyor path with directional arrows is displayed. A separate area drag selected **22 blueprints**, distributed **7 High / 7 Normal / 8 Low**, without visible loss of the existing selection or HUD panels. Along with passing dedicated 38/38 UI and 16/16 click-inspection tests, this accepts the UI/inspection milestones for normal sandbox manual behavior. Post-click change regressions E3d4a/b and E3d5c3d2b/c/d remain due.

## E3d5c3e1a — Isolated Priority Request Control (F6 Pending)

`BlueprintConstructionPriorityButtons` contains three Godot Button controls and a typed `priority_requested(priority: int)` signal. Its own initial status is disabled and it never obtains construction-site references or calls `ConstructionJob.set_priority`. The only supported values are `ConstructionJob.Priority.HIGH`, `NORMAL`, `LOW`, and invalid requests are ignored. Mouse filtering uses STOP within the control. The `set_selection_available()` interface must be set from an independently validated external selection context before actual interactions produce requests.

A standalone F6 scene `res://tests/construction_priority_buttons_e3d5c3e1a_test.tscn` stages 12 assertions A–L to prove click signal behavior, disabled/invalid fail-closed semantics and unchanged planned job state and selection. Its manual click check must demonstrate real buttons; no UI wiring exists in the Factory Testing Sandbox or Main at this checkpoint.

**Future adapter requirements:** Connect to the existing WorldInteraction priority command only when Q area-selection mode is active and at least one eligible PLANNED site is selected. Don't make a single-click inspection silently reprioritize all plans, and don't bypass WorldInteraction validation, construction escrow, power, worker budget, scheduler, or timers. Retain keyboard H/N/L as alternatives. Validate selected-site counts and mixed priority outcomes with isolated tests before turning the buttons on in the sandbox. E3d4a/b and E3d5c3d2b/c/d remain pending regression evidence after direct-click changes.

## E3d5c3e1b — Compact Sandbox Priority Dock Beside Hotbar (F6 Pending)

The dedicated priority request component `BlueprintConstructionPriorityButtons` is now a narrow `VBoxContainer` showing **L → N → H vertically**, with 48×30 px buttons, 2 px spacing, stop-filtered button clicks, full-text tooltip labels, and the existing signal-only `priority_requested(priority)` contract. Its default selection availability is false. Isolated UI test E3d5c3e1a still tests 12 A–L invariants but was updated to reflect the new compact geometry.

The new `SandboxConstructionPriorityDock` is an **opt-in CanvasLayer**, enabled solely in `Factory Testing Sandbox` (not Main and not the shared BuildHUD packed scene). It tracks the actual `BuildHUD/VisualHotbar` `get_global_rect()`, placing the stack 8 px left and vertically aligned with the center of the hotbar. Buttons are visible only in Blueprint Mode while the visual hotbar is visible. They are disabled unless WorldInteraction confirms Q-area mode is active with selected PLANNED ConstructionSites. Single-click blueprint inspection does not grant Q selection.

A clicked button emits a priority request, and the sandbox adapter **revalidates the current Q selection** and calls the existing `WorldInteraction._set_selected_blueprint_priority(priority)` policy, which independently checks Q mode, build/blueprint mode, planned job state, and WorldInteraction ownership. H/N/L keyboard controls remain unchanged. No button starts construction or changes readiness, inventory reservations, power, workers, priority dispatch preemption or timers. Main's scene and construction authority are unchanged; disconnected resources remain UNKNOWN and live readiness remains NOT VERIFIED.

`res://tests/sandbox_vertical_priority_dock_e3d5c3e1b_test.tscn` stages **16 A–P** checks using a live instantiated Factory Testing Sandbox plus planned blueprint site(s), controller-owned Q area selection and valid signal requests. The updated `res://tests/construction_priority_buttons_e3d5c3e1a_test.tscn` keeps its **12** isolated UI request checks. **Both require Godot 4.6.2 F6 and manual mouse validation before acceptance**. Afterward, rerun the affected pre-existing area-selection and requirements UI suites.

## E3d5c4a — Sandbox-Only Explicit Construction Authorization Controls (F6 Pending)

After the accepted 89/89 E3d5c3e1b and UI/selection regression evidence, a distinct sandbox authorization UI is staged. `BlueprintConstructionAuthorizationButtons` is a request-only HBox with **Authorize Selected (E)** and **Authorize All (Ctrl+E)**, both disabled until eligible PLANNED sites exist. The selected action specifically requires active Q-area selection; inspection-only targets never count as selected. `SandboxConstructionAuthorizationDock` places this row directly above the BuildHUD visual hotbar and does not modify the compact L/N/H stack to its left.

For each click, the sandbox adapter rechecks Build Mode, Blueprint Mode, demolition exclusion, hotbar/catalog visibility, managed ownership, PLANNED state and (for Selected) actual Q-selected membership. It then calls the **already-tested** `WorldInteraction._authorize_selected_blueprint_sites()` or `_authorize_all_blueprint_sites()`; the UI never calls `ConstructionJob.authorize()` directly. All requires two deliberate clicks, displaying **Confirm All**, and confirms only if the exact same eligible-site identity set is still present. Changing that set, leaving Blueprint Mode, or using Selected invalidates All confirmation. Existing physical-key E and Ctrl+E commands are untouched. Priority assignment does not authorize; direct-click requirements inspection remains read-only.

**Non-negotiable readiness separation:** The ordinary Factory Testing Sandbox still explicitly enables its previous debug requirements bypass. This means authorized jobs may immediately enter CONSTRUCTING *in the sandbox only*. The new UI has **no** connection to the isolated material escrow, nameplate power allocator, readiness coordinator, scheduler, stock-provider inventories or worker drones. It neither fabricates requirements nor advances construction seconds. Main remains without planning/authorization UI and without debug construction bypass. A future production adapter may consume authorization only with validated atomic material delivery/escrow, delivered electrical power, real finite worker capacity, recovery and persistence; UI labels or priority metadata must never be treated as those proofs.

**Acceptance:** `res://tests/sandbox_blueprint_authorization_test.tscn` stages **18 A–R** checks against a live sandbox. It deliberately turns debug requirements **off** before authorizing; jobs must remain QUEUED with missing `power`, `materials` and `workers`, retaining zero progress. Additional checks cover dynamic counts, off-default isolation, above-hotbar layout, true Q selection, L/N/H independence, read-only inspection, selected-only authorization, two-click All, candidate-set change invalidation and E/Ctrl+E keyboard fallback. **Godot F6 and ordinary mouse acceptance remain pending.** Run E3d5c3e1b, E3d4b and E3d1 regression scenes after acceptance. The previously accepted 89/89 tests remain historical evidence, not a new CI result.

### E3d5c4a — Developer F6 Acceptance Evidence (2026-11-11)

The developer ran `res://tests/sandbox_blueprint_authorization_test.tscn` under Godot 4.6.2 and provided screenshots of the result. Output confirms **ALL 18 SANDBOX BLUEPRINT AUTHORIZATION TESTS PASSED**. The fixture's final viewport shows **Planned 0 / Queued 6 / Building 0 / Paused 0**, with next waiting job **High: Test Storage**, while its read-only requirements panel displays **Queued, 0%**, **UNKNOWN** inventory/escrow/power/worker services and **Live readiness: NOT VERIFIED**. These observations support fail-closed authorization, not live dispatch or actual resources.

This accepts **automated** E3d5c4a A–R only; ordinary mouse-click execution of both UI buttons in the real sandbox remains unverified. Run dedicated regression scenes E3d5c3e1b (16), E3d4b (13), and E3d1 (7), plus manual UI and conveyor placement smoke, before declaring the player-facing authorization milestone fully accepted. A residual `Placement blocked` line appeared after test completion; no assertion failed, but reproduction during intended placement would warrant triage. Main remains excluded from this UI, and no readiness coordinator/power/escrow provider was installed.

### E3d5c4a — Post-Change Regression Evidence 36/36 (2026-11-11)

Developer-supplied Godot 4.6.2 screenshots verify the three requested post-authorization F6 suites on the current sandbox code: **E3d5c3e1b vertical priority dock 16/16**, **E3d4b advanced blueprint area selection 13/13**, and **E3d1 sandbox batch blueprint authorization 7/7**. All conclude with their corresponding **ALL ... TESTS PASSED** output. This is **36/36** regression checks; alongside the already accepted **18/18** E3d5c4a isolated authorization tests, there are **54/54 verified checks across four scene executions**. It does not represent an integrated CI run or independent new checks beyond overlapping historical suites.

Confirmed architectural boundaries include priority never authorizing jobs, Q-selected E versus Ctrl+E all, correct Shift/Alt selection isolation, no skipped construction time, Main opting out and jobs remaining QUEUED without required materials/power/worker services when the explicit sandbox test override is disabled. The production game remains unconnected to the material escrow/readiness coordinator; live readiness is NOT VERIFIED.

**Outstanding human-UI gate:** No screenshot yet verifies actual physical mouse clicks on the newly added Authorize Selected, Authorize All and Confirm All buttons in a normal Factory Testing Sandbox session, or a post-change conveyor placement/corner/delete smoke. These must precede a full gameplay acceptance label. Existing prototype nameplate power, stock/escrow, real worker delivery, cancellation recovery and save/load remain separate safety-critical integration steps.

### E3d5c4a — Final Sandbox Manual Acceptance (2026-11-11)

The developer confirmed all manual authorization tests and conveyor smoke passed in the ordinary Factory Testing Sandbox. Screenshot shows Q selecting **4 PLANNED** blueprints, H1/N2/L1 priority distribution, green selection outlines, L/N/H priority dock correctly beside the nine-slot hotbar, and active **Authorize Selected (4)** and **Authorize All (4)** controls above it. This particular frame represents the state before authorization, so successful physical Selected / All / Confirm All clicks and completed build/conveyor behavior are recorded as developer-reported manual evidence, not inferred from the screenshot.

Together with the earlier screenshot-verified **18/18** isolated authorization checks and **36/36** three-suite regressions, **E3d5c4a is accepted for sandbox-only interaction**. All authorization remains distinct from priority, readiness and dispatch. Normal sandbox debug bypass is not proof of real delivered materials, electrical power or workers. Production Main is still gated off. Next integration should remain isolated and fail-closed while true resource delivery, worker occupancy, cancellation/recovery and persistence are developed and validated.

## E3d5c4b — Test-Only Authorization-to-Readiness Admission (F6 Pending)

`BlueprintConstructionReadinessAdmission` is a separate opt-in Node. It never appears in Main or Factory Testing Sandbox scenes and defaults `enable_isolated_admission = false`. An isolated test controller must deliberately enable it, attach a configured `BlueprintConstructionReadinessCoordinator`, and turn **OFF** the Factory Testing Sandbox's legacy `blueprint_sandbox_debug_requirements` override. Any later override reactivation makes subsequent admission fail closed. The adapter independently checks live sandbox host, opt-in authorization dock, WorldInteraction-owned ConstructionSite, job state **QUEUED**, all three missing readiness reasons and positive bounded demand. Mere planning, highlighting, clicking L/N/H, cancelled work, repeated requests or debug-authorized work cannot enter its test-only handoff.

`admit_site()` calls only `BlueprintConstructionReadinessCoordinator.track_site()`; `admit_waiting()` explicitly reads already-authorized sites from the existing priority queue. It does not subscribe to priority or authorization UI events, scan per frame, reserve or deliver inventory itself, grant power, set availability, allocate workers, call `reconcile()`, progress timers, or mutate production Main. The coordinator retains independent validation of bills, escrow ownership, rated power allocations and scheduler availability. No live electrical supply is claimed: the existing prototype allocator has **nameplate** capacity, not verified delivered power.

`res://tests/blueprint_readiness_admission_e3d5c4b_test.tscn` stages **16 A–P F6 checks**, using actual sandbox WorldInteraction authorization paths for selected-only and All jobs. The isolated readiness fixture first proves zero-material/no-generator jobs remain QUEUED, then supplies **3 test ingots** and demonstrates one High-priority atomic escrow reservation without generators or workers: all jobs must still remain QUEUED with no time progress. These test-only stock/energy service objects are created by the fixture, **not** the playable scene. No new readiness status may be reported as live from these results. Local Godot verification pending; when successful, separately test the earlier coordinator and authorization scenes. Delivery, genuine power, worker-drones, recovery and save/load remain hard safety prerequisites.

### E3d5c4b — Developer Godot Acceptance 16/16 (2026-11-11)

The developer's latest Godot 4.6.2 Output screenshot shows **PASS A–P** followed by `ALL 16 E3D5C4B READINESS ADMISSION TESTS PASSED`. Assertions cover opted-out Main, sandbox debug-intake prohibition, explicit E / Ctrl+E-style queued admission, malformed demand and duplicate refusal, independent isolated coordinator configuration, and test-only 3-ingot High-priority material escrow without a generator. The test never installs a playable coordinator, manufactures construction permission or advances job time. **E3d5c4b automated milestone accepted**; no in-game readiness or dispatch claim is supported.

A further isolated material staging/transfer fixture is appropriate before physical conveyor-port connection. Source-to-buffer `InventoryComponent.transfer_to()` would prove inventory accounting without pretending to prove a conveyor delivered it. The actual production gates remain physical delivery validation, real electrical service, finite workers, transactional recovery and persistence.

## E3d5c4c — Isolated Material Staging Inventory and Conservation (F6 Pending)

`BlueprintConstructionMaterialStaging` creates a **bounded**, empty `InventoryComponent` only after an explicit test-only opt-in and validation of a live source inventory, valid definition-owned bill and capacity sufficient for one complete bill. Calls to `receive_item()` reject unknown item types/invalid quantities and use existing `InventoryComponent.transfer_to()`; no item is spawned or moved directly to a job. No ability to authorize, change priority, allocate power/workers or advance timers exists. `get_staged_inventory()` intentionally exposes a stock endpoint to the isolated `BlueprintConstructionReadinessCoordinator`; the coordinator's existing atomic escrow still makes the final claim on a bill.

**Critical distinction:** inventory-to-inventory transfer is **not evidence of a real conveyor**. This component does not know conveyor endpoints, active cargo time, port direction, power service, drone arrival or save state, and it is **not installed in Main or the Factory Testing Sandbox**. Production integration requires a separately verified actual conveyor-to-receiver path and recovery/persistence; callers cannot infer readiness from this test-only buffer.

The staged `res://tests/blueprint_material_staging_e3d5c4c_test.tscn` has **16 A–P checks awaiting developer F6**: default-off and invalid-source/capacity refusal, partial delivered quantity, priority changes without authorization, explicit two-site authorization, no escrow on partial bill, atomic High-priority escrow on full 3-ingot bill, zero worker dispatch with no generator, exact 5-ingot conservation after another transfer, cancellation refund blocked by bounded full-buffer condition, alternative recovery to the original live supply, and transfer of recovered ingots back into the staging buffer for the next authorized job's escrow. Neither simulated electrical nameplate supply nor worker capacity is granted, and no normal gameplay scripts or scenes are edited.

### E3d5c4c — Verified Bounded Transfer and Recovery (2026-11-11)

The developer provided Godot 4.6.2 Output showing all **16 A–P** checks and `ALL 16 E3D5C4C MATERIAL STAGING AND RECOVERY TESTS PASSED`. This accepts isolated inventory staging and atomic escrow conservation, including failed refund into a full buffer and subsequent alternative recovery with no loss/duplication of the initial five ingots. It does **not** validate conveyor connectivity or real delivery: the source units were transferred through `InventoryComponent.transfer_to()` into an isolated bounded buffer. Real electrical consumption, physical workers, cancellation persistence, and save/load are still unverified.

Next physical-logistics proof should use the existing conveyor endpoint alignment, reciprocal port connections and timer delivery code to a specifically bill-filtered staging INPUT port in a separate F6 fixture. No prototype nameplate power should become live construction authority.

## E3d5c4d — Isolated Physical Belt-to-Construction Material Input (F6 Pending)

The next staged checkpoint adds a deliberately **disabled-by-default** `BlueprintConstructionStagingInputPort : ItemPortComponent` for a construction staging buffer. Its `bind_staging()` establishes a reference to the exact bounded staging `InventoryComponent`, and its `can_accept_item()` override is read-only and requires the staging feature enabled, a live configured bill/inventory, a supported item and remaining capacity before delegating to the base input policy. It never grants construction availability or moves an item itself. The existing `ConveyorBuildingTransfer.try_unload_from_belt()` performs actual cargo removal only after reciprocal connection, input direction, live inventories, valid endpoint geometry, and the overridden item acceptance pass. `ConveyorTransportTimer.advance_transport()` still enforces full travel time, backpressure, and retention of blocked cargo.

`res://tests/blueprint_physical_staging_e3d5c4d_test.tscn` stages **16 A–P F6 checks**, assembling a synthetic output structure with a real OUTPUT `ItemPortComponent` and supply `InventoryComponent`, an actual `ConveyorSegment` PackedScene and timer, and a test-only staging receiver bearing the new INPUT port. The test verifies blocked aligned-but-disconnected unloading, initially rejected ore retained in cargo then recovered, transfer of four ingots with physical connection and travel time, a filled three-unit buffer preventing overflow, atomic escrow of the delivered three-ingot bill, misalignment rejection, resume after realignment, and conservation across source, moving belt cargo, staging buffer and escrow. The job remains QUEUED because no generator or worker permission exists.

**This fixture validates one real timed belt with real port checks but not a player-built construction receiver or a complete source/factory-to-site logistics route.** The supply node in the fixture is synthetic. It is not an assurance of electrical delivery, resource provenance after destruction, warehouse recovery, drone service or save/load. Main and Factory Testing Sandbox remain unchanged; production construction readiness remains NOT VERIFIED. F6 and targeted earlier regression evidence are pending.

### E3d5c4d — Physical Timed Conveyor Staging Verified (2026-11-11)

Developer-supplied Godot 4.6.2 Output shows **ALL 16 E3D5C4D PHYSICAL CONVEYOR STAGING TESTS PASSED** after assertions A–P. Existing ConveyorSegment endpoint snapping, reciprocal connections, timer and unload code delivered three ingots into a definition-bill-filtered staging receiver; a fourth was blocked by capacity then transferred after escrow and geometry restoration. Ore rejection and exact cargo accounting were verified. The test left work QUEUED with no generator or workers.

**Limit:** the source structure held fixture-supplied ingots, and the receiver remained isolated from build placement, worker delivery, meterable power and persistence. Next test must produce ingots by the real TestSmelter recipe and run a multi-belt factory path before considering any game-scene integration. Real live readiness stays false.

## E3d5c4e — Isolated Actual-Manufacturing Conveyor to Construction Escrow (F6 Pending)

After E3d5c4d's verified single-belt physical delivery, the next fixture exercises a real source building and manufacturing recipe rather than synthetic ingot supply. `res://tests/blueprint_factory_construction_chain_e3d5c4e_test.tscn` instantiates actual `TestStorage` and `TestSmelter` scenes; explicitly seeds **eight Test Ore units** into Storage, not ingots. An Ore conveyor uses reciprocal Storage OUTPUT → Belt INPUT and Belt OUTPUT → Smelter INPUT connections. A second two-belt line uses Smelter OUTPUT → Belt A → Belt B → construction staging INPUT, using the existing reciprocal endpoint geometry and travel timers. The actual Smelter `ProducerComponent` must consume two ore per cycle and manufacture exactly one ingot. Automatic processing on fixture components is disabled for deterministic manual time steps, not bypassed.

Staging remains a separate bounded `BlueprintConstructionMaterialStaging` and `BlueprintConstructionStagingInputPort`; only correct ingots can enter. Three recipe-created ingots fill the buffer, and a fourth waits on the last belt under backpressure. Explicit job authorization plus the isolated `BlueprintConstructionReadinessCoordinator` must atomically escrow exactly three staged ingots, without any generator/worker permission, leaving construction QUEUED at zero work progress. Misalignment must still block the fourth unit; restoration permits delivery with four conserved ingots. Cancelling the job with insufficient staging capacity for the full refund must retain escrow until recovered into the existing Storage inventory, with no duplication.

**This 16-check scene is staged, not run** in Godot. The source has real building-port ownership and real recipe production, but the initial ore is fixture-supplied and the construction staging port is not a player-built construction receiver. Physical power delivery, worker drones, save/load, demolition recovery and deployment in production are still unverified. Production Main and Factory Testing Sandbox remain unmodified.

### E3d5c4e — Developer Godot Acceptance (16/16) on 2026-11-11

The updated F6 test passed **A–P / 16 of 16**, as shown in the developer's Godot 4.6.2 screenshot. Storage-to-Smelter and Smelter-to-staging port connections preserved physical transport and recipe time; 8 seeded ore were consumed to generate 4 ingots. Exactly 3 ingots entered isolated job material escrow, the fourth was staged after backpressure relief, and cancellation returned the held bill once without granting power/worker readiness. The correction to PASS M properly requires `materials` to be cleared from wait reasons once escrow exists; `power` and `workers` remain missing. This is proof of isolated materials routing, not a live factory readiness gate. Next isolate physical ore extraction to a real storage port without using a seeded source.

## E3d5c4f — Finite Resource Node to Real Storage via Physical Conveyor (F6 Pending)

Following acceptance of the real Smelter-to-construction fixture, the next test-only component step uses **no new gameplay runtime code**. `res://tests/blueprint_extraction_storage_e3d5c4f_test.tscn` instantiates the existing finite `TestOreDeposit` and `TestExtractor` scenes and waits for real `ExtractionArea` physics updates, then calls the extractor's actual overlap scan and extraction timer methods. The test does not insert ore directly into any inventory; the ResourceNodeRuntime's initial 500 units must decrease exactly by each successful ExtractorComponent mining cycle.

It then physically connects the Extractor OUTPUT to a real ConveyorSegment INPUT and the conveyor OUTPUT to a real TestStorage INPUT via existing port geometry and reciprocal connection state. The existing ConveyorTransportTimer and building transfer code transport ore to bounded Storage. The **12 A–L** assertions cover 1-second mining/travel increments, four finite ore units delivered in total, backpressure at three-unit capacity, blocked cargo retained on belt during disconnection, recovery only after both capacity and physical connection are restored, and conservation of the original **500 units** across deposit, extractor, one belt, Storage and test drain stock. The fixture is independent from Main, Factory Testing Sandbox, energy generation, construction authorization and job advancement.

**Not yet validated:** This is a staged Godot F6 test, not a passing claim. Deposit-to-Extractor-to-Storage is isolated from the separately proven Storage-to-Smelter-to-construction route. A future combined acceptance suite must prove all links at once. Materials received at a test-only construction port remain no substitute for persisted escrow, delivered power, finite worker drones or real recovery/save-load.

### E3d5c4f — Screenshot-Verified Finite Extraction Logistics (2026-11-11)

The developer's Godot 4.6.2 Output shows **12/12 E3d5c4f** checks passed. The real TestOreDeposit's physics body was detected by the TestExtractor ExtractionArea, mining consumed four of its 500 finite units, and the ordinary belt transport delivered the ore into real TestStorage. Full-buffer backpressure, disconnection while holding actual cargo, clearance, reconnection and conservation of all 500 starting units were verified. The exact result is scoped to the isolated **deposit→extractor→single-belt→storage** route. Combining the previously accepted real Smelter-to-staging test with this mining origin is the next acceptance gate. No metered electricity, physical construction worker service or persistent escrow is yet verified.

## E3d5c4g — Integrated Finite Extraction → Factory → Construction Escrow (F6 Pending)

The E3d5c4g isolated fixture integrates the two separately screenshot-verified foundations: E3d5c4f **12/12** finite deposit/extractor/Storage logistics and E3d5c4e **16/16** real Smelter recipe/construction escrow. It instantiates actual TestOreDeposit, TestExtractor, TestStorage and TestSmelter scenes, plus a separate test-only construction staging input. Four real ConveyorSegments use reciprocal OUTPUT/INPUT ports and existing geometry/snap, timed cargo transfer and backpressure logic. Eight units are depleted from the finite **500**-unit deposit via actual ExtractorComponent mining; NO ore/ingots are inserted into any inventory. Eight ore must move to Storage, then physically into the Smelter input, be consumed in four timed **2 ore → 1 ingot** cycles, and traverse two physically connected belts to bill-filtered staging. Exactly three manufactured ingots become atomic construction escrow; a fourth first blocks at full capacity and later enters the staging buffer. The job is explicitly authorized, but remains QUEUED with zero progress due to missing power/worker authority.

The **18 A–R staged F6 assertions** verify actual overlap discovery, reciprocal connected paths, mining and factory recipe timing, cargo backpressure/misalignment, material escrow with only **power and workers** still missing, and cancellation when the staging buffer lacks capacity for a full three-ingot refund. Escrow must remain recoverable and return exactly once to the existing real Storage inventory. Material conservation uses ore-equivalence (492 in deposit plus four manufactured ingots times the two-ore recipe input equals 500), avoiding the false assumption that eight input ore remain eight inventory units after smelting.

**Safety scope:** The entire fixture is isolated and explicitly steps timers for deterministic acceptance. No gameplay scene installs the test-only construction receiver or the readiness coordinator. The tests do not establish player-built receiver placement, power delivery, physical worker drones, site destruction recovery, or transactional save/load. F6 execution of E3d5c4g has **not yet been verified**.

### E3d5c4g — Integrated Mined-Resource Factory Route Verified (2026-11-11)

Developer-provided Godot 4.6.2 Output confirms **18/18 checks** for E3d5c4g. The actual resource node, extractor, storage, smelter recipe, four conveyor segments, construction staging port, escrow and cancellation refund ran together in one isolated fixture. The source ledger closed at 492 ore remaining plus four physically manufactured ingots, each representing two input ore. Three ingots were held in site-specific escrow, one was buffered, and the job remained QUEUED with `power`/`workers` missing. The test manually advances known production/cargo timers; it does not establish autonomous player-placed construction delivery, delivered electricity, physical worker assignments or persistence. Next isolate **which site is entitled to a given staging/input-port stock**, without reusing one site's materials for another.

## E3d5c4h — Isolated Per-Site Staging and Receiver Ownership (F6 Pending)

The new `BlueprintConstructionSiteStagingRegistry` defaults `enable_isolated_site_registry = false` and is **not installed** in either playable scene. Explicit `claim_site()` accepts only a live, authorized QUEUED ConstructionSite that still awaits power, materials and workers, a valid bill-matching, enabled staging buffer and a physically distinct, enabled input port bound to that exact buffer. Existing staging's read-only `matches_definition()` checks full ItemDefinition/count bill equality, and input port's `get_bound_staging()` checks exact inventory identity. A single registry refuses all duplicate site/staging/inventory/input claims and cross-site substitutions. Ownership is intentionally not automatically released on cancellation or lost references: legitimate later reassignment requires explicit recovery and persistence proof.

`reserve_for_site()` accepts **no arbitrary supply or bill** from its caller. It resolves only the already registered site's inventory and definition-derived costs, then delegates exact atomic reservation to the existing isolated escrow. It does not call authorization, coordinator.reconcile(), job availability, power allocations, worker scheduling, time advancement or any hidden ready state. It does **not** replace the existing coordinator, which currently takes one source inventory; before gameplay integration that coordinator must be adapted or gated to respect these site-specific claims. Until then no per-site resource dispatch is trusted in playable worlds.

The staged `res://tests/blueprint_site_staging_ownership_e3d5c4h_test.tscn` has **16 A–P assertions awaiting Godot F6**. Two authorized Storage blueprints are given distinct bounded staging ports with separate ingot supplies. A third Smelter blueprint must not attach to a Storage material bill. An incomplete A buffer or empty B buffer cannot debit escrow; completing each buffer creates one site-specific reservation, never cross-spending. Filling A's buffer after escrow and cancelling A must preserve an unrecoverable-to-buffer bill, then permit explicit one-time alternate source refund. Cancellation and receiver lockout must leave both sites' combined nine-ingot starting quantity conserved. The earlier E3d5c4g chain already proved physical extraction/recipe/cargo; this fixture isolates stock ownership identity, not physical provenance or production readiness.

## E3d5c4i — Isolated Site-Aligned Physical Material Input (F6 Pending)

The staged `BlueprintConstructionAnchoredStagingPort : BlueprintConstructionStagingInputPort` is the first physical receiver aligned to a **real ConstructionSite planned InputPort marker** while preserving the E3d5c4h site's unique inventory ownership. The test-only receiver is a **separate Node3D sibling**, never a child of the ConstructionSite; `ConstructionSite._cancel_job_site()` queues the site for deletion, which would otherwise risk destroying buffered materials. `attach_to_authorized_site()` requires the existing opt-in flags, an already-authorized QUEUED job, a live valid planned input marker, matching complete construction bill, unique successful registry claim, and an independent receiver parent. It positions its physical port at the planned marker's exact transform. Only the physical input, not the ghost marker, has ItemPortComponent/inventory semantics. A failed claim disables the port; other authorized blueprints cannot inherit a claimed buffer.

During delivery, `can_accept_item()` additionally validates that the site is still live and QUEUED, its marker remains aligned to the fixed receiver, and the registry still resolves the exact owned inventory. The established conveyor transport validates reciprocal endpoint geometry, physical direction, cargo travel and available capacity. If the site moves, the port cannot accept cargo despite a belt being attached. Job cancellation or site tree exit immediately disables the separate receiver's intake and does not release the claim, preventing remaining belt cargo from unloading into a stale or unowned job. Existing escrow remains responsible for atomic reserve/refund; if buffered inventory cannot accept a whole cancelled-job bill, escrow stays available for explicit alternate recovery. No module grants power, workers or job progress.

`res://tests/blueprint_anchored_receiver_e3d5c4i_test.tscn` stages **16 A–P checks for developer F6**, using real ConstructionSite planned geometry and an actual ConveyorSegment and timer, with seven test-source ingots and one rejected ore to isolate attachment/cancellation behavior. The test verifies full three-ingot escrow, three more buffered under capacity, a seventh item held on the belt during backpressure and cancellation, alternative one-time refund of three held ingots, total seven-ingot conservation and no ghost-port activation. This is **NOT** a gameplay-connected, automatically placed or persistent building. Previously verified E3d5c4g independently established mined factory provenance; no evidence of production-delivered electricity, worker drones, demolition salvage or save/load exists yet.

### E3d5c4i — Screenshot-Verified Site-Anchored Input (2026-11-11)

Developer F6 output proves all **16 A–P** tests passed for a separate bill-filtered receiver aligned to a real ConstructionSite PlannedInputPort. The receiver is independent of the site's child lifecycle; physical timed belt delivery respects queued-site ownership, geometry, bill filtering and bounded capacity. Cancelling the job disables future delivery while remaining cargo, staging inventory and pending escrow can still be recovered. Seven ingots and one rejected ore were conserved. No worker or electrical readiness was manufactured.

**Residual safety problem:** existing E3d5c4h claims intentionally remain locked when their site dies; decommission and persistence have not been implemented. Next test a read-only recovery/retirement audit (including belt-in-flight cargo, staged inventory and escrow), with no automatic claim release or deletion. A site disappearing is not permission to erase its claim.
