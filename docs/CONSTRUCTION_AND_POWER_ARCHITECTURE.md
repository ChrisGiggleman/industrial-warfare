# Universal Construction, Blueprint Planning, and Power Grid — Architecture Proposal

**Project:** Industrial Warfare — one zombie-planet playable demo  
**Date:** 2026-11-08  
**Status:** Architecture proposal with an **isolated ConstructionJob foundation committed for Godot validation** (2026-11-08). No live construction-site or power-grid integration has been enabled.  
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

`scripts/components/construction_job.gd` is now committed as a `RefCounted` policy wrapper around `ConstructionLifecycle`; `tests/construction_job_test.tscn` is the corresponding **14-check local F6 regression, pending developer execution**.

- Its public state machine is `PLANNED → QUEUED → CONSTRUCTING ↔ PAUSED → COMPLETE`, plus `CANCELLED` from any nonterminal state. `authorize()` is the only way out of `PLANNED`.
- Power, materials, and workers are separate externally supplied **availability flags**. Each required flag defaults to false (fail-closed), and `get_wait_reasons()` reports the missing requirements. The future power grid, material transfer, and worker fleet must validate their availability truthfully.
- Construction time stays exclusively in the existing `ConstructionLifecycle`. A paused job never invokes `advance()` on its timer; resuming preserves accrued work, and completion signals only once.
- Deliberate bootstrap/test jobs may opt out of individual gates (for example, the Main Hub) and may use zero seconds in a test; real conveyors and normal structures will later use positive construction durations from building definitions.
- Cancellation **does not return materials or free a world footprint in this isolated class**, because neither is owned by it. The later construction-site integration must handle safe cancellation transactions, port reservation cleanup, material salvage and collision ownership.
- None of these scripts currently activates scene objects or connects physical conveyors. Main, WorldInteraction, Production Debug, and factory transport remain unchanged.

Do not mark Gate B validated or move this job into world placement until the new F6 scene passes.

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
