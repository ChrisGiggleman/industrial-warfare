# Universal Construction, Blueprint Planning, and Power Grid — Architecture Proposal

**Project:** Industrial Warfare — one zombie-planet playable demo  
**Date:** 2026-11-08  
**Status:** ConstructionJob **14/14**, universal ConstructionSite **15/15**, original compatibility suites **23/23**, per-definition durations **12/12**, and building Blueprint Mode **12/12** passed in Godot 4.6.2. Building Blueprint Mode passed 7-step manual authorization and 6-step cancellation/overlap checks. Post-Blueprint-Mode conveyor compatibility **14/14 passed** (2026-11-09). Stand-alone straight conveyor blueprint E1 **passed 14/14 scripted F6 checks** and its seven-step manual placement/authorization/cancellation sequence was confirmed (2026-11-09). E2a planned direct/right/left route-geometry discovery **passed 12/12 in Godot 4.6.2** (2026-11-09). E2b exclusive endpoint reservation registry and its **16-check F6 suite are committed but not yet validated**. Visible planned corner conversion and physical graph activation remain unimplemented. Connected conveyor blueprint topology, Main scene and power grid remain unimplemented.  
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
