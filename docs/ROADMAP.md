# Industrial Warfare — Development Roadmap

---

## Active Next Phase — Universal Construction, Blueprint Planning, Power (2026-11-08)

**Playable target:** One persistent zombie-planet demo, advancing the supplied defensive perimeter. Other planets/factions remain future expansion content.

### Acceptance before broader implementation

- [x] Timed Storage foundation, planned conveyor reservation, and delayed physical connection validated previously.
- [x] Planned conveyor finder **7/7** and Build Mode integration **6/6** passed in Godot 4.6.2; user confirmed live ghost hard-snapping to unfinished Storage.
- [x] Planned Storage bidirectional conveyor regression **8/8 passed** in Godot 4.6.2 (user-provided Output screenshot, 2026-11-08). Confirms rotated planned markers, two exclusive reservations, inactive precompletion flow, completion activation, input/output cargo conservation, occupied-belt demolition protection, and safe output disconnection. This is programmatic geometry/transport validation, not manual Build Mode acceptance.
- [x] **Manual planned Storage input/output placement accepted** (2026-11-08): player screenshots show a timed construction site with two correctly directed conveyor placements and, after completion, reciprocal Production Debug HUD evidence of `Input: Building port` and `Output: Building port` on the respective conveyors. This verifies visible bidirectional connection, not a new manual cargo-flow assertion.
- [x] **Manual right-turn preservation accepted** (2026-11-08): screenshot shows completed Storage, a visibly aligned 90-degree outgoing conveyor path, and the selected adjacent belt's Production Debug HUD confirming `Input: Building port` plus `Output: Next conveyor`. This confirms the first outgoing connection survives site completion; does not independently prove corner cargo transport.
- [x] **Manual opposite-direction / left-turn route accepted** (2026-11-08): user confirmed the layout works; screenshot shows a completed Storage, directional conveyor corner routing, and a selected incoming belt with `Input: Previous conveyor`, `Output: Building port`, and `Cargo: Prototype Rounds x1`. This confirms a buffered ammunition item on an attached conveyor, not yet a measured end-to-end inventory delivery or conservation total.
- [x] **Automated conveyor corner cargo regression 8/8 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08): in-place right corner preserves cargo/timer, right and rotated-left corners forward items, blocked output retains cargo and later resumes, and all three item types are conserved across the scripted test. This is standalone corner logistics validation, not yet a manual complete Storage receipt/accounting check.
- [x] **Conveyor cargo demolition safety 6/6 passed** in Godot 4.6.2 (user Output screenshot, 2026-11-08): empty conveyors allow demolition; occupied conveyors are protected; blocked removal preserves cargo; unloading restores eligibility; malformed cargo buffers fail safely; item-type-independent protection and conservation confirmed.
- [x] **Wreckage selection and cleanup 12/12 passed** in Godot 4.6.2 (user Output screenshot, 2026-11-08): selectable Layer-2 wreckage, live HUD inspection, empty cleanup, protected stocked caches, guarded material transfer, and conservation of ten recovered units all passed.
- [ ] Manual corner-to-completed-Storage receipt and end-to-end item accounting remain acceptance work for the larger sandbox. Avoid interpreting isolated cargo tests as a complete live factory conservation audit.
- [ ] Confirm local Git working tree and sandbox scene changes are reconciled before broad edits.

### Shared architecture design

Design specification drafted in [CONSTRUCTION_AND_POWER_ARCHITECTURE.md](CONSTRUCTION_AND_POWER_ARCHITECTURE.md) (2026-11-08). Review/acceptance and runtime implementation remain separate checkpoints.

- [ ] Review `BuildingDefinition`, `ConstructionLifecycle`, `ConstructionSite`, `WorldInteraction`, `FactoryGrid`, logistics ports, and existing destruction.
- [ ] Specify blueprint intent vs authorized queued work vs constructing vs operational; decide material and power gating, pausing, cancellation, footprint reservation and serialization boundaries.
- [ ] Specify hub power supply, relay connectivity, electrical coverage, and separate defense and drone-support areas *before* finalizing the universal construction model.
- [ ] Specify three candidate power-pole levels, increasing coverage and slow/medium/fast charging (exact numeric balancing deferred).

### Incremental implementation (not yet complete)

- [x] **Gate B — isolated ConstructionJob foundation 14/14 passed** in Godot 4.6.2 (user screenshot, 2026-11-08). Validated blueprint authorization, queued blockers, retained work through pause/resume, safe cancellation, one-time completion, work modifiers and explicit zero-duration test exceptions. No operational power, material delivery or worker service exists yet.
- [x] **Gate C isolated universal construction-site integration 15/15 passed** in Godot 4.6.2 (user screenshot, 2026-11-08). Validated opt-in `ConstructionSite.setup_with_job()` for planned/queued/constructing/paused Storage, non-operational conveyor and multiport merger blueprints, real activation, reserved connection, waiting cargo conservation, and cancelled jobs never spawning entities.
- [x] **Legacy backward compatibility Round 1 passed 10/10** in Godot 4.6.2 (player screenshots, 2026-11-08): `construction_site_test.tscn` 4/4 and `planned_storage_conveyor_test.tscn` 6/6. Existing timed Storage activation, footprint/port behavior, delayed conveyor reservation, conservation, and moved-link rejection remain intact after the opt-in universal site integration.
- [x] **Legacy backward compatibility Round 2 passed 13/13** in Godot 4.6.2 (developer screenshots, 2026-11-08): `planned_conveyor_port_finder_test.tscn` 7/7 and `planned_storage_build_mode_test.tscn` 6/6. Confirms nearest planned input preview, fractional port cursor alignment, reserved-port exclusion, activation after completion, and Main scene opt-in isolation.
- [x] **Legacy backward compatibility gate fully passed 23/23** across construction site 4/4, planned Storage reservation 6/6, planned-port discovery 7/7, and Build Mode integration 6/6 on the opt-in universal-site branch.
- [x] **Gate D1 per-definition construction durations 12/12 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08). All nine resources have positive provisional build times; power pauses freeze work; blueprints lack live cargo; Storage and belts activate only at completion; legacy manual-timed Storage remains unchanged.
- [x] **Gate D2 sandbox Blueprint Planning Mode scripted regression 12/12 passed** in Godot 4.6.2 (player Output screenshot, 2026-11-08): `WorldInteraction` test opt-in, P mode/HUD toggle, rotated Storage footprint and ports, overlap/off-grid rejection, fail-closed unsupported belts, requirement-blocked queue/pause, deferred Storage activation, cancellation, and explicit sandbox readiness override. Main scene flags remain OFF.
- [x] **Manual Blueprint Mode placement/authorization accepted** (2026-11-09): developer confirmed all seven F6 steps worked: enter Build Mode (B), select Storage (3), toggle Blueprint Mode (P) with correct HUD, place a transparent `PLANNED 0%` Storage through mouse click, aim at site, authorize with E, and observe timed construction to an operational Storage. This is player-facing validation, distinct from scripted 12/12.
- [x] **Manual Blueprint Mode cancellation/occupancy accepted** (2026-11-09): developer confirmed all six sandbox test steps worked, including placing a `PLANNED 0%` Storage, rejecting a second plan on its occupied footprint, hovering and cancelling via X, and successfully placing another plan in the released location. The screenshot shows the translucent `PLANNED 0%` site; cancellation/overlap outcomes are supported by the developer's explicit manual confirmation.
- [x] **Gate D2 building Blueprint Planning Mode accepted (manual + scripted)**: 12/12 scripted checks, seven-step player placement/authorization check, and six-step cancellation/overlap check completed in the Factory Testing Sandbox. This is for non-conveyor building plans only; debug availability override is sandbox-only.
- [x] **Pre-conveyor compatibility gate passed 14/14** (2026-11-09, Godot 4.6.2 user Output screenshots): `res://tests/planned_storage_build_mode_test.tscn` 6/6 and `res://tests/conveyor_corner_cargo_test.tscn` 8/8 passed after Blueprint Mode integration. The original timed Storage belt reservation/cargo flow and straight/left/right corner transport/backpressure conservation remain intact.
- [x] **Conveyor Blueprint Phase E1 scripted regression 14/14 passed** (2026-11-09, developer Godot 4.6.2 Output screenshot): `res://tests/conveyor_blueprint_e1_test.tscn` passed A–N. Verified cardinal, isolated two-second belt plans, direction/endpoints, exclusive tile reservations, inactive cargo/transport before completion, power pause and resume, exact-once real conveyor activation, safe cancellation/reuse, no phantom connections, and Main defaults off.
- [x] **Phase E1 manual interaction passed** (2026-11-09): player confirmed all seven Factory Testing Sandbox F6 steps, with screenshots showing multiple transparent `PLANNED 0%` straight belt sites and completed real directional segments. Verified mouse placement, 2s authorization, cancellation and tile reuse, plus regular conveyor placement after P-mode exit.
- [x] **Blueprint corner limitation identified, not an E1 regression:** perpendicular planned straights remain independent and do not convert to L-shaped corners. The live belt system already supports right/left in-place conversion; E2 must introduce a non-operational planned-route/endpoint contract before making planned corners visible or connectable.
- [x] **E2a planned route geometry passed 12/12** in Godot 4.6.2 (2026-11-09, player Output screenshot): direct and right/left corner intent, rotation, invalid facing/gaps, cancellation and construction eligibility recognized without changing any operational conveyor.
- [x] **E2b exclusive endpoint reservation regression passed 16/16** (developer Godot 4.6.2 Output screenshot, 2026-11-09): exclusive input/output claims; shared middle-belt completion; readiness in either build order; stable references across retired/freed sites; rejected stale geometry; right/left corner intent; cancellation, demolition and explicit release without phantom connections. Two earlier bugs (shared completion observers and freed-object casting) were corrected and now covered by the passing suite.
- [x] **E2c1 physical activation passed 15/15** (user Godot 4.6.2 Output screenshot, 2026-11-09): deferred direct/right/left connections, both build orders, three-belt chain cargo conservation, occupied-port and stale-geometry refusal, cancellation, demolition safety. `PlannedConveyorRouteActivator` remains the isolated validated adapter; operational conveyor code unchanged.
- [x] **E2c2 sandbox connected-belt integration automated 17/17 PASSED** (developer Godot 4.6.2 Output screenshot): `res://tests/connected_conveyor_blueprint_e2c2_test.tscn` passed A–Q, including straight links, rendered right/left planned corner markers, restoration after cancellation, both build orders, three-belt chain and two-hop item conservation, smaller labels, and Main opt-out. The new coordinator is enabled only in Factory Testing Sandbox; no power/material/worker service or standalone save system was added.
- [x] **E2c2 manual player acceptance passed** (2026-11-09, developer confirmation and three screenshots): six manual Factory Testing Sandbox steps succeeded, showing the planned and constructed right/left conveyor corners, authorization and completed routes, cancellation behavior, and normal P-off placement. An additional targeted manual check later confirmed E authorization is independent of selected-preview rotation; correct receiver direction is still required when first placing a valid route. The scripted 17/17 and manual checks remain accepted.
- [x] **E2c2 direction-independent E authorization confirmed manually** (2026-11-09, four screenshots and developer report): authorization and construction of already placed planned conveyor corners succeed regardless of the selected placement preview's current rotation. No targeting fix needed. Receiving-segment facing remains intentional for forming the directed connection during placement. Automatically orienting the next preview is a separate optional usability enhancement, not a current blocker.
- [x] **Post-E2c2 compatibility gate PASSED 45/45** (developer Godot 4.6.2 screenshots, 2026-11-09): E2b reservations **16/16**, E2c1 deferred physical activation **15/15**, planned Storage Build Mode **6/6**, and conveyor corner cargo **8/8**. The existing planned Storage, reservation, corner and cargo conservation behavior remains validated after E2c2 manual acceptance.
- [x] **E3a planned building-port geometry PASSED 15/15 in Godot 4.6.2** (developer Output screenshot, 2026-11-09): unfinished Storage input/output matching, rotation, correct direction, invalid/far endpoints, queued/paused eligibility, cancelled/completed rejection, and no premature operations. `res://tests/planned_building_port_geometry_e3a_test.tscn`. Main and player controller unchanged.
- [x] **E3b Storage-port reservations PASSED 18/18 in Godot 4.6.2** (developer screenshot): independent Storage input/output, duplicate rejection, build-order independence, cancellation and footprint reclaim, stale-endpoint rejection, freed construction-site cleanup, destroyed endpoint release, and legacy live-belt reservation priority. No live ports or cargo were connected.
- [x] **E3c0 shared blueprint claim broker PASSED 18/18** (developer Godot 4.6.2 Output screenshot, 2026-11-09): E2b conveyor routes and E3b Storage-port plans share atomic input/output claims, reject both claimant-order conflicts and invalid partial claims, preserve independent middle-belt sides, and release claims safely on cancellation, destruction and freed construction sites. `res://tests/shared_blueprint_endpoint_ownership_e3c0_test.tscn`. The broker is **not yet installed in the player sandbox**; no physical port link or cargo was created.
- [x] **E3c1 isolated physical Storage-port activation PASSED 18/18** in Godot 4.6.2 (developer Output screenshot): both construction orders, rotated input/output, occupied/invalid/stale connections, cancellation/demolition safety, mixed E2b/E3b broker ownership, end-to-end ore through Storage and blocked-belt backpressure. `res://tests/planned_storage_port_activation_e3c1_test.tscn`. No gameplay controller or Main changes were needed to validate this component.
- [x] **E3c2a sandbox automatic Storage-port discovery PASSED 16/16** (developer Godot 4.6.2 Output and gameplay screenshots, 2026-11-09): Storage-first/belt-first planning, independent ports, single shared E3c0 broker, deferred physical activation, rotated Storage, mixed multi-step ore conservation, backpressure, cancellation, existing conveyor corners and Main opt-out. `res://tests/connected_storage_blueprint_e3c2a_test.tscn`.
- [x] **E3c2b Stage 1 — planned Storage port preview snapping STAGED (not yet Godot validated):** `BlueprintStoragePortSnapPreview` finds the nearest unclaimed planned Storage input/output using raw mouse coordinates, existing planned-port transforms, requested conveyor rotation and strict 0.65-tile attraction. Sandbox-only `WorldInteraction` uses this read-only choice for the straight conveyor ghost and still validates footprint before placement; Main stays opted out. `res://tests/storage_blueprint_preview_snap_e3c2b_test.tscn` has **14 checks, NOT YET RUN** for markers, fractional cursor, direction, radius, input/output, cancellation, rotated Storage and Main opt-out. No new operational or cargo code.
- [ ] **E3c2b Stage 2 — manual visual acceptance after F6:** open Factory Testing Sandbox, use B → conveyor 5 → P, approach the future Storage IN/OUT markers with correct R rotation; verify the green preview hard-snaps to their future belt tiles and both placed belts reserve and complete after E. Test X cancellation, wrong facing, and old P-off snapping. Rerun conveyor and Storage compatibility suites before widening to other buildings, power, or Main.
- [ ] **Next connection scope:** planned belts to unfinished Storage and other building ports, bridge/short-gap path planning, robust multi-turn route editing, and full resource-delivery validation remain separate checkpoints before enabling in Main.
- [ ] After 16/16 passes, E2c must bind reservations to player planning, show real L-shaped blueprint placeholders, and commit existing corner/direct physical connections only when both neighboring conveyor builds complete. Test right/left turns and either build order, cargo conservation, demolition, and cancellation before enabling in Main.
- [ ] **E2/E3 later:** design/test directional graph reservations, Storage port snapping, build-order independence, corner conversion, collision and cargo conservation. These are not included in E1.
- [ ] Design/test directional planned-conveyor geometry, endpoint reservations, corner handling, queued activation order, cancellation and cargo conservation without changing Main until each independent checkpoint passes.
- [ ] Extend universal job/site integration to live, opt-in Build Mode only after regressions; implement per-building construction times and non-operational planned conveyors before enabling any universal feature in Main.
- [ ] Add Blueprint Mode with safe preplanning, port markers, cancellation, authorization and queueing.
- [ ] Implement Main Hub initial power and connected pole/relay coverage, then generation/consumption and tiered drone recharge.
- [ ] Add worker drones, material-consuming construction, physical supply priorities and powered turret/wall expansion.
- [ ] Finish a small playable zombie horde defense-and-expansion demonstration; reserve other worlds, enemy factions, and interplanetary travel for after the first slice.

**Scope guard:** Keep Main scene and validated logistics/combat systems stable. Use opt-in features and Godot F6 regression suites. No disconnected save system.

---

This roadmap tracks the major development stages for Industrial Warfare.

The current goal is to build a small, playable vertical slice before expanding into larger systems.

---

## Blueprint Conveyor Ghost Hard-Snap — Cursor Coordinate Correction (2026-11-07)

- [x] Player verified delayed connection works, but yellow conveyor placement ghost does **not** visibly hard-snap to an unfinished Storage blueprint.
- [x] Trace live WorldInteraction preview: planned finder incorrectly received integer-snapped `mouse_grid_position`, despite fractional building-port placement.
- [x] Pass the raw `hit_position` instead, preserving original building-port direction and hard-snap transform validation.
- [x] Expand `planned_conveyor_port_finder_test.tscn` to **7 checks** including fractional cursor proximity.
- [x] Run updated finder regression **7/7** and Build Mode integration regression **6/6** in Godot 4.6.2 (player-confirmed screenshots, 2026-11-07).
- [x] Recheck hard-snapping in the F6 factory sandbox with a new unfinished Storage blueprint: **player confirmed snapping works** (2026-11-07).
- [ ] If still not snapping, inspect preview precedence and camera-hit targeting before adjusting collision safety or connection logic.

**No modifications to completed building connectivity, cargo transport, or Main scene construction settings.**

---


## Planned Storage — Visible Port Snapping Correction (2026-11-07)

- [x] Manual F6 testing confirmed a reserved conveyor connects once Storage is complete, but the placement ghost does **not reliably snap** when aimed at the unfinished Storage.
- [x] Extend `PlannedConveyorPortFinder` to accept the cursor near either the planned port or the proposed belt origin, retaining direction filtering and original tight search radius.
- [x] Expand `planned_conveyor_port_finder_test.tscn` to six checks, including cursor directly over planned input.
- [ ] Run 6-check finder regression and existing 6-check sandbox Build Mode integration test.
- [ ] Verify actual ghost moves/snaps to unfinished Storage port before click in F6 sandbox, without affecting parallel belts, corners, or R rotation.

**Status:** Discovery adjustment committed; local Godot validation pending.

---


## Planned Storage Conveyor Reservation — Checkpoint 1 (2026-11-07)

- [x] Add non-operational `PlannedInputPort` / `PlannedOutputPort` marker geometry copied from the future building's actual scene.
- [x] Implement optional physical-belt reservation and revalidation of endpoint geometry when construction finishes.
- [x] Add `tests/planned_storage_conveyor_test.tscn` covering six checks: geometry, reservation exclusivity, waiting cargo, completion connection, conserved unloading, and rejection of moved belts.
- [x] Run the six-check Godot regression: **6/6 passed** in Godot 4.6.2 (2026-11-07).
- [ ] Wire Build Mode preview/click handling to planned markers without bypassing existing collision and conveyor corner rules.
- [ ] Validate live blueprint-to-conveyor construction and demolition/salvage behavior.
- [ ] Only then consider enabling planned connections in the normal zombie-planet demo.

**Status:** Reservation logic passed local tests. Preview finder is now committed for separate regression; manual in-game placement around unfinished Storage is not yet available.

### Planned-port discovery checkpoint

- [x] Add `PlannedConveyorPortFinder`, a separate read-only preview finder for planned Storage input/output markers.
- [x] Add `res://tests/planned_conveyor_port_finder_test.tscn`, checking rotated geometry, snap range, requested belt direction, reserved port exclusivity, and completed-site exclusion.
- [x] Run the five-check Godot discovery test: **5/5 passed** (2026-11-07).
- [x] Integrate the finder with an **opt-in sandbox-only** Build Mode preview/click route, keeping existing corner and collision checks.\n- [x] Add `tests/planned_storage_build_mode_test.tscn` with six checks for controller reservation, cargo conservation and Main scene isolation.\n- [x] Run the six-check sandbox Build Mode integration test in Godot 4.6.2: **6/6 passed** (2026-11-07).\n- [ ] Finish manual acceptance for both planned input/output ports, belt direction, completion and cargo transfer; **visual hard-snapping confirmed** in F6 sandbox.

**No player-facing snap changes at this checkpoint.**

 No WorldInteraction placement changes in this checkpoint.

---


## Timed Storage — Conveyor Delivery Compatibility (2026-11-07)

- [x] `construction_footprint_ports_test.tscn`: **4/4 passed locally**; unfinished sites reserve the physics footprint and expose no inventory/port.
- [x] Add `tests/timed_storage_conveyor_delivery_test.tscn` covering site completion, a physically snapped conveyor, one ore delivery, item conservation, and disconnection cleanup.
- [x] Run `timed_storage_conveyor_delivery_test.tscn` in Godot 4.6.2: **6/6 passed** (2026-11-07), including actual cargo delivery and conservation.
- [x] Verify player-built conveyor connection in F6 sandbox to completed timed Storage: user screenshot shows **11 Prototype Rounds / 200** in completed Test Storage, HP **100/100**, with adjacent physical conveyor chain (2026-11-07).
- [ ] Later: design delayed building-to-existing-belt snapping, to avoid premature connections before construction completes.

**This checkpoint adds a regression scene, not new live snapping logic.**

---


## Construction and Conveyor Compatibility — Footprint Checkpoint (2026-11-07)

- [x] Confirm factory testing sandbox accepted (3/3 test checks and manual stationary-zombie verification).
- [x] Inspect ConstructionSite collision reservation and Storage port activation on completion.
- [x] Add `tests/construction_footprint_ports_test.tscn` validating placement layer, actual Godot overlap detection, absent premature inventory/ports, and final inventory/ports.
- [ ] Execute new 4-check physics-world regression in Godot 4.6.2.
- [ ] Test physical conveyor endpoint connection and cargo conservation after timed construction completes; no automatic reconnection is implemented in this checkpoint.
- [ ] Enable timed construction for conveyor-attached buildings only after those logistics checks pass.

**Checkpoint:** Regression scene committed; local execution pending. Main game and sandbox behavior unchanged.

---


## Factory Testing Sandbox — Temporary Developer Convenience

- [x] Add `res://scenes/core/factory_testing_sandbox.tscn` as a separate developer-only copy of the current Main scene, with `PrototypeMovingZombie.process_mode = DISABLED`.
- [x] Enable timed Storage construction only in this sandbox; `main.tscn` keeps the zombie active and its original construction flag unchanged.
- [x] Add `res://tests/factory_testing_sandbox_test.tscn` with three focused settings-isolation checks.
- [x] Run sandbox regression (F6): **3/3 checks passed** in Godot 4.6.2 (2026-11-07). Player confirmed in-game sandbox operates with the green zombie inactive; construction and conveyor compatibility testing can proceed without combat interruptions.
- [ ] Reconcile the temporary sandbox scene if the main prototype scene changes in future checkpoints.

**The sandbox is an isolated development aid, not a permanent combat or zombie AI change.**

---


### Timed Storage Manual F5 Acceptance — Next Step

- [x] Controller integration `tests/timed_storage_placement_test.tscn` **4/4 checks passed locally** (2026-11-06).
- [x] In Godot Main scene, temporarily enable `WorldInteraction.enable_timed_storage_construction` for F5 demonstration (default intentionally remains false for existing regression compatibility).
- [x] Place free-standing Test Storage with shortcut 3: F5 screenshot confirmed blue site at 47%, followed by screenshot of completed Storage with IN/OUT markers (2026-11-06). Actual live cargo flow still pending verification.
- [ ] Verify ordinary conveyor placement is unaffected. Storage directly snapped to an existing belt remains on the old immediate-placement path until a separate delayed port-connection integration is tested.
- [ ] Restore the Inspector flag to disabled after this focused acceptance test to retain the established baseline.


### Timed Storage World Integration — Opt-in Validation

- [x] Local Godot passed all **4/4** isolated ConstructionSite tests on 2026-11-06; combined with lifecycle **6/6**.
- [x] Added an opt-in `WorldInteraction` path for **standalone Test Storage** to place a ConstructionSite instead of an immediate building; ordinary placement defaults remain unchanged.
- [x] Added `tests/timed_storage_placement_test.tscn` with four checks for the controller integration, site footprint, timed activation and rejection of unsupported definitions.
- [x] Run the new regression in Godot 4.6.2 (**4/4 passed**). Main-world timed placement remains deliberately opt-in pending F5 inspection.
- [ ] Integrate the specialized conveyor-attached placement path and confirm no early inventory/port transfer.
- [ ] Enable construction sites in normal F5 gameplay after passing new tests, then manually test progress, location, rotation, collisions and completion.

**Status:** Opt-in world integration committed; new Godot checks pending.

---


## Zombie-Planet Playable Demo — Active Development Focus (2026-11-06)

- [x] Confirm **one zombie-planet demo** as the immediate scope; other factions, worlds, and interplanetary launches are later campaign features.
- [x] Define fortified perimeter expansion, shared ammunition/construction resource economy, RTS command view, optional player drone, and worker construction drones as design directions.
- [x] Add isolated `ConstructionLifecycle` with planned / constructing / complete states, progress, work multiplier, and safe one-time completion event.
- [x] Add `res://tests/construction_lifecycle_test.tscn` with six focused timing and transition checks.
- [x] Execute all six construction lifecycle tests in Godot 4.6.2 (**6/6 passed**, user-confirmed).
- [x] Add isolated `ConstructionSite` prototype that reserves a footprint and replaces itself with a real Test Storage building at completion.
- [x] Add `tests/construction_site_test.tscn` for four storage-activation checks (**awaiting local Godot run**).
- [ ] Integrate construction sites with a **single simple building** before generalizing to all structures and conveyor placement variants.
- [ ] Reserve build footprints while unfinished; prevent production, port transfers, and combat until completion.
- [ ] Add construction progress UI and regression checks for placement, demolition, health, logistics and selection.
- [ ] Create the central hub and worker assistance behavior; then implement material-consuming construction.
- [ ] Add expandable defensive walls, waves and a bounded victory/lose condition for the zombie demo.

**Checkpoint status:** Standalone lifecycle committed; runtime validation and live-world integration pending. No live building placement behavior changed.

---


## Phase 0 — Foundation

**Goal:** Establish a clean and maintainable technical base.

- [x] Create Godot 4.6.2 project
- [x] Establish initial project folders
- [x] Create documentation structure
- [x] Configure Git and GitHub
- [x] Review and finalize `.gitignore`
- [x] Define naming and coding conventions
- [x] Configure essential Godot project settings
- [x] Create initial input mappings
- [x] Create basic main/test scene
- [x] Make initial Git commit

**Status: Complete**

---

## Phase 1 — Core Prototype

**Goal:** Prove the basic factory-and-defense loop in a simple test environment.

Planned major systems:

- camera and world interaction
- building placement
- resource nodes
- resource collection
- inventories
- machine production
- simple storage
- basic conveyor/logistics prototype
- basic power or machine-operation constraints
- simple zombie enemy
- enemy movement toward player structures
- basic defensive structure
- basic health and damage

### 1A — Camera & Player Interaction Foundation

- [x] Create RTS-style CameraRig
- [x] Add WASD camera movement
- [x] Add mouse-wheel zoom
- [x] Add mouse-to-world raycasting
- [x] Add selectable-object system
- [x] Add material selection highlighting
- [x] Establish interaction collision layers
- [x] Add Build Mode
- [x] Add 1-meter grid snapping
- [x] Add placement validity checks
- [x] Add green/red placement ghost
- [x] Add 90-degree placement rotation
- [x] Add rotation-aware collision footprints
- [x] Support multiple prototype building types
- [x] Add prototype Build HUD
- [x] Add `player_built` classification
- [x] Add Demolition Tool
- [x] Restrict demolition to Build Mode
- [x] Add demolition HUD state
- [x] Add demolition hover targeting
- [x] Complete interaction-system refactor
- [x] Complete regression test

**Status: Complete**

### 1B — Factory & Production Foundation

- [x] Create `BuildingDefinition` resource architecture
- [x] Create data-driven prototype building assets
- [x] Refactor Build Mode to use `BuildingDefinition`
- [x] Remove legacy direct buildable-scene collection
- [x] Add `BuildingRuntime`
- [x] Inject building definitions into placed instances
- [x] Create `ItemDefinition`
- [x] Create prototype `Test Ore`
- [x] Create reusable `ItemAmount`
- [x] Create reusable `InventoryComponent`
- [x] Verify add/check/remove inventory operations
- [x] Create `ProductionRecipe`
- [x] Create `Prototype Extraction` recipe
- [x] Create reusable `ProducerComponent`
- [x] Prevent placement ghosts from running gameplay components
- [x] Produce Test Ore automatically every 2 seconds
- [x] Verify independent inventories across multiple producers
- [x] Add Production Debug HUD
- [x] Display selected building, recipe, and live stored output
- [x] Verify non-producer and non-building debug states
- [x] Remove temporary production console spam

**Status: Complete**

> Historical note: Chat 03 validated autonomous ore generation. Chat 04 replaced the small building's free-output recipe with a source-dependent Test Extractor; the reusable producer/recipe code remains for later machines.

### 1C — Resource Nodes & Extraction Foundation (Chat 04)

- [x] Define reusable `ResourceNodeDefinition` data
- [x] Create Test Ore Deposit definition and selectable world scene
- [x] Add `ResourceNodeRuntime` and `extract(amount)`
- [x] Support and test infinite versus finite resource availability
- [x] Add reusable `ExtractorComponent` with nearby-deposit detection
- [x] Transfer extracted resources into individual building inventories
- [x] Require Test Extractor placement within resource range
- [x] Preserve normal placement for non-extractor buildings
- [x] Separate extraction detection shapes from physical placement blockers
- [x] Extend debug HUD for deposits, extraction status, and stored ore
- [x] Rename small prototype to Test Extractor
- [x] Retire the obsolete Prototype Extraction recipe asset
- [x] Complete final camera/build/selection/extraction/demolition regression tests

**Status: Complete**

### 1D — Basic Storage & Logistics (Chat 05)

- [x] Define shared item-count inventory capacity and unlimited-capacity fallback
- [x] Implement partial acceptance and capacity-aware finite-deposit extraction
- [x] Create dedicated Test Storage scene and BuildingDefinition (200 capacity)
- [x] Add Test Storage to building selection (key 3), rotation, selection, and demolition
- [x] Implement safe `InventoryComponent.transfer_to()` item movement
- [x] Validate partial transfers, full destinations, empty sources, invalid/self transfers, and conservation
- [x] Add `LogisticsTransferComponent` and nearest-eligible storage discovery within a configurable radius
- [x] Transfer Test Ore automatically on a timed interval, ignoring disabled placement ghosts
- [x] Display inventory contents/capacity, transfer status, and last successful transfer in the debug HUD
- [x] Regression-test existing camera, building, extraction, selection, and demolition systems
- [x] Complete finite-resource conservation regression: 250 deposit + 50 extractor + 200 storage = 500
- [ ] Build physical conveyors, ports, inserters, and more complex routing (follow-up milestone)
- [x] Add production recipe input availability, consumption, and outputs from actual inputs (**completed in Chat 06**)
- [ ] Explore machine-operation/power constraints (follow-up)

**Chat 05 Status: Complete — Direct proximity-based logistics working; physical conveyors remain planned.**

### 1E — Production Inputs & First Manufacturing Chain (Chat 06)

- [x] Review and preserve existing `ProductionRecipe`, `ItemAmount`, `ProducerComponent`, and `InventoryComponent` architecture
- [x] Choose independent manufacturing input/output inventories to prevent capacity conflicts
- [x] Add recipe input validation and duplicate-input aggregation
- [x] Validate total output-space requirements before manufacturing
- [x] Implement guarded, synchronous input consumption and full-cycle output creation with rollback attempt on unexpected failure
- [x] Connect safe transactions to the timed `ProducerComponent`; report waiting/blocked statuses
- [x] Create permanent `Test Ingot` and `Test Ore Smelting` resources (**2 ore → 1 ingot, 2 seconds**)
- [x] Create Test Smelter scene and BuildingDefinition (**50 input / 100 output**)
- [x] Register smelter with Build Mode as **key 4**; support selection, rotation, overlap blocking, demolition, and Build HUD highlighting
- [x] Implement `LogisticsInputComponent` to pull ore from stocked nearby Test Storage using safe transfers
- [x] Configure input logistics (**up to 5 ore per second**, range **5**, target buffer **10**)
- [x] Expose separate machine input/output quantities and capacity through the Production Debug HUD
- [x] Add shared live production and extraction activity progress bar, with stopped/blocked statuses
- [x] Correct extractor status when inventory is full or deposit depleted
- [x] Verify smelter output-full blocking, retention of ingredients, and 0% progress
- [x] Pass **36/36** Chat 06 manufacturing test assertions and re-run Chat 05 inventory transfer regression
- [x] Verify finite-500 resource conservation with deposit, extractor, storage, smelter input, and manufactured ingots
- [x] Commit and push tested Chat 06 gameplay changes to `main`
- [x] Document gameplay milestone and troubleshooting

**Chat 06 Status: Complete — First automatically supplied Test Smelter produces Test Ingots with separated inventories and live progress.**

#### Future Logistics and Manufacturing Follow-Ups

- [ ] Automate finished-ingot transfer out of the smelter and support downstream destinations
- [ ] Prototype physical conveyor/inserter/port routing beyond proximity transfers
- [ ] Add more production recipes, machine tiers, and configurable downstream processing
- [ ] Introduce power/fuel/machine-operation constraints where they improve gameplay
- [ ] Improve the prototype production debug display into a final player-facing machine interface

### 1E.1 — Recipe Selection & Input Acceptance Foundation (Chat 07, first checkpoint)

- [x] Confirm physical-belt, ammunition-first factory-defense game direction in [GAME_VISION.md](GAME_VISION.md)
- [x] Add per-machine `available_recipes` list while retaining existing active `recipe`
- [x] Implement conservative `select_recipe()` changes without deleting input/output inventory items
- [x] Add read-only `accepts_input_item()` based on the currently selected recipe
- [x] Gate temporary smelter input logistics using the producer's active-recipe acceptance decision
- [x] Update Test Smelter scene with recipe list and ProducerComponent reference
- [x] Pass **10/10** recipe-selection, **6/6** ingredient-acceptance, and **5/5** recipe-aware logistics tests
- [x] Rerun **36/36** Chat 06 manufacturing checks, existing inventory-transfer tests, and active factory gameplay
- [x] Commit and push this checkpoint's tested gameplay and isolated test scenes to `main`
- [x] Document architecture, development log, roadmap, and troubleshooting

**Checkpoint status: Complete.** This is recipe-control infrastructure, not yet a player recipe-selection UI and not yet physical material transport.

### 1E.2 — Machine Input/Output Ports & Logical Item Handoffs (Chat 07, second checkpoint)

- [x] Add reusable `ItemPortComponent extends Marker3D` with `INPUT`/`OUTPUT` roles
- [x] Define recipe-aware and universal-storage admission policies
- [x] Validate full-request free capacity and full source item availability without modifying inventory
- [x] Place and orient `InputPort` and `OutputPort` on the Test Smelter, referencing correct inventories and producer
- [x] Verify port world positions and outward directions after a 90° building rotation
- [x] Add safe manually invoked port-to-port transfers using existing `InventoryComponent.transfer_to()`
- [x] Reject invalid source/destination roles, unsupported items, same-inventory transfers and full destinations
- [x] Validate complete ore → smelter → ingot → storage handoff with blocked export and resource conservation
- [x] Pass **29/29** port checks; rerun **21/21** Chat 07 recipe checks, **36/36** Chat 06 checks, inventory tests and normal factory
- [x] Commit and push tested port scripts, scene changes and four new test scenes to `main`
- [x] Document architecture, dev log, roadmap and port-specific diagnostic expectations

**Checkpoint status: Complete — safe logical handoffs and orientable port markers, not yet an operational physical conveyor network.**

### 1E.3 — Straight Conveyors, Snapping and Build Placement (Chat 07.4)

- [x] Add world-space endpoint geometry and strict connection tolerances
- [x] Create ConveyorStraight scene with visible mesh, directional markers and footprint
- [x] Track at most one previous and one next belt; clean up reciprocal links on deletion
- [x] Implement straight snap-after, read-only snap previews, and snap-before with rotation support
- [x] Register Conveyor Belt as slot **5**, preserving the four original shortcuts
- [x] Make Build Mode ghost snap to the nearest compatible open input/output
- [x] Commit exactly one new conveyor per snapped click, or roll back on a rejected connection
- [x] Provide reliable selection/demolition and distinct Layer 2 / Layer 3 hitbox responsibilities
- [x] Pass **40/40** conveyor regression checks and verify main factory gameplay
- [x] Commit and push the tested conveyor milestone to main
- [x] Document the milestone and remaining work

**Status: Complete — connected straight conveyor geometry and placement, but no inventory transport over belts.**

### 1E.4 — Automatic Corner Conversion and Directional Conveyor Visuals (Chat 07.5, 2026-10-27)

- [x] Add tested right- and left-turn conveyor scene endpoints and world-space alignment.
- [x] Keep **one Conveyor Belt construction tool (key 5)**, with a straight placement ghost; no separate corner build-menu entries.
- [x] Convert an existing straight conveyor **in place** when a new perpendicular, correctly oriented straight is placed adjacent to its available output; retain incoming links and node identity.
- [x] Guard occupied outputs and invalid geometry; roll back unsuccessful conversions without altering the existing line.
- [x] Verify left/right conversion, rotation of connected assemblies and reciprocal-link cleanup on demolition.
- [x] Add visible steel-gray L-shaped placeholder corner meshes, widened to match straight-belt width.
- [x] Add bright directional arrows under `OutputEndpoint` for placed straight belts, converted corners, and placement ghosts.
- [x] Verify actual Build Mode turns and different travel directions, plus selection/demolition and an inspected collision overlay.
- [x] Push corner scripts, scenes and local test assets to GitHub `main`.
- [ ] Replace the committed overlapping-box corner mesh implementation with exact continuous single-surface geometry, if desired; clean up stepped seams and make physics/interaction footprints precise.
- [ ] Complete a single consolidated regression run of all prior and new test scenes, then record its aggregate result.

**Status: Core 90° construction and directional cues working.** Reported individual local passes include 8/8 corner connection, 8/8 left-corner, 6/6 corner-preview, 8/8 turn-intent, 8/8 piece-selection, 8/8 in-place conversion, 8/8 full-chain, and 8/8 visual-geometry checks, in addition to successful main-game construction and demolition. These were observed at different checkpoints; a final single-run total is **not** claimed. Closed-loop final connections and item transportation remain unimplemented/unverified.

#### Remaining Logistics Follow-Ups After Chat 07

- [ ] Verify and implement explicit closure of already placed conveyor loops, without creating an overlapping new belt; guard endpoint availability.
- [ ] Normalize `InteractionHitbox` size/slight rotation and refine corner-shaped collision/selection footprints.
- [ ] Simplify legacy corner ghost selection and remove redundant debug/reset paths when safe.
- [ ] Connect machine and storage input/output ports to conveyor endpoints.
- [ ] Prevent distant or disconnected manual port handoffs from being used by gameplay logistics.
- [x] Implement one-item, generic, connection-validated timed belt-to-belt transport and backpressure with tested conservation (Chat 08 foundation).
- [ ] Finalize throughput tuning, visible travel, machine/belt interface rates and broader end-to-end capacity behavior.
- [ ] Design universal small/medium/large slot-and-stack storage.
- [ ] Add separate placeable splitters and mergers after straight/turn routing works.
- [ ] Replace proximity logistics only after physical belts pass manufacturing regression checks.
- [ ] Build ammunition supply and supply-dependent defense for the First Night slice.

### 1E.5 — Generic Physical Conveyor Transport Foundation (Chat 08, 2026-10-27)

- [x] Add one-item `CargoInventory` and reusable `ConveyorTransportComponent` to `ConveyorStraight`.
- [x] Preserve item definitions generically; no ore-, ingot-, metal- or ammo-specific belt logic.
- [x] Require reciprocal directed segment links and aligned endpoints for belt-to-belt handoffs.
- [x] Add automatic timer, blockage preservation, and resumed transfers.
- [x] Verify right/left corner conversion retains cargo and progress.
- [x] Verify a six-segment chain carries three distinct item definitions without overtaking or loss.
- [x] Block **player-tool demolition** of occupied or invalidly configured belts.
- [x] Pass **44/44** assertions across six separately executed Godot test scenes; rerun integration and gameplay checks.
- [x] Push tested gameplay changes to GitHub `main`.
- [x] Add a generic visible box for occupied straight and in-place left/right corner belts, synchronized with travel progress.
- [ ] Add **distinct item-specific** meshes/materials/models based on `ItemDefinition` (the current box is shared).
- [x] Add Test Extractor OutputPort and reuse Test Smelter input/output ports; implement read-only port-to-belt snap transforms, reciprocal physical connections, guarded loading/unloading and automatic timer-driven transfers.
- [x] Integrate building-port snapping and connection commits into **player-facing Build Mode**; include placement obstruction checks and occupied-port previews (completed after the 08.3F foundation).
- [x] Add universal physical input/output ports to Test Storage (subsequent Chat 08 gameplay integration).
- [x] Pass isolated Extractor → three belts → Smelter → Test Ingot production route (seeded ore, manually advanced timers, without storage).
- [ ] Test full Extractor → Belt → Storage → Belt → Smelter → Belt → Storage in actual gameplay; replace proximity logistics only when safe.
- [ ] Decide a safe item recovery/drop policy for non-player belt destruction and persistence.
- [ ] Refine loop closure, speed/capacity balancing, exact corner collision shapes, and comprehensive test orchestration.

**Historical checkpoint status (08 foundation):** Belt-to-belt cargo transport validated before Build Mode integration. **Superseded:** The normal game now supports physical connections between buildings; legacy proximity components have not yet been formally retired.
### 1E.6 — Building Port Integration & Isolated Production Route (Chat 08, 2026-10-27)

- [x] Add conveyor cargo visuals for straight and left/right corners; preserve generic `ItemDefinition` behavior.
- [x] Add Extractor OutputPort and validate 90-degree building rotation.
- [x] Implement read-only building-port preview transforms and exclusive, persistent belt-to-port connections.
- [x] Enforce reciprocal links, current physical marker alignment, valid producer output ownership and recipe-controlled input acceptance.
- [x] Implement guarded loading and unloading for any valid item type, plus timer-driven building input/output handoffs and full-destination backpressure.
- [x] Pass **86/86** newer checks across ten separate Godot test scenes (total Chat 08 **130/130** across sixteen separate reported suites).
- [x] Validate isolated Extractor → three connected belts → Smelter: two seeded ore produce one ingot with correct accounting.
- [x] Commit and push this code and regression suite to `main`.
- [x] Support normal in-game placement/snap discovery and hookup from player-built belts to buildings via `WorldInteraction` (subsequent Chat 08.3F/08.3G integration).
- [x] Add Test Storage physical ports and player-built routes through Storage; final full-chain isolation from legacy proximity logic remains to be validated.
- [ ] Test deposit-fed extraction, simultaneous item traffic, steady throughput and removal of proximity transfers without breaking the original factory.

**Historical checkpoint status (08.3F-1):** The isolated seeded-ore test passed before normal Build Mode hookups existed. **Superseded by 08.3G:** Building-port links and output export work during player placement. Distinct item visuals, safe cargo recovery, and verified retirement of the parallel proximity flow remain pending.
### 1E.7 — Full Player-Built Conveyor Logistics, Unified Grid & Routing Buildings (Chat 08.3G, 2026-10-30)

- [x] Implement free-end and missing-corner preview/commit, including source/receiver existing-straight conversions.
- [x] Implement exact two-ended bridging, fractional straight connectors and perpendicular variable-leg L connectors with real collision/selection and item transport.
- [x] Normalize physical item velocity over variable connector lengths using `ConveyorPathMotion`.
- [x] Apply `FactoryGrid` origin parity and rotated port alignment to all building definitions.
- [x] Convert Merger to **1×1, 3 IN / 1 OUT**, with three independent bounded input buffers, one output buffer, round-robin fairness and per-lane counters.
- [x] Add **1×1 Splitter, 1 IN / 3 OUT**, with three independently buffered outputs, disconnected/full output skipping and conservation.
- [x] Add the build slots **6** / **7** and real-time Merger/Splitter input/output diagnostics.
- [x] Receive developer-reported passing isolated regressions for grid/merger/splitter after redesign, and live evidence of 13 Splitter transfers (**5/4/4**).
- [x] Verify that small gaps can be physically filled and their item movement appears speed-consistent in live gameplay.
- [x] Confirm live 1×1 Merger with three incoming conveyor routes and successful output-full **backpressure/recovery**. The user confirmed operation; numerical `From A/B/C` HUD counters were not separately captured and remain an optional benchmarking follow-up.
- [x] Complete final 20/20 manual Godot regression scenes (four rounds) and user-confirmed ore-to-ingot factory chain in live gameplay. **Separately verifying physical-only item conservation with legacy proximity scripts disabled/accounted for remains pending.**
- [x] Accept **core Chat 08 physical logistics milestone** and record verification evidence in the devlog/regression checklist (2026-10-30); leave robustness/migration items as follow-up work.
- [ ] Add safe cargo-recovery handling for destructive events and then retire/gate old proximity logistics after conservation tests.

**Status: Core physical logistics milestone accepted (2026-10-30): 20/20 manual regression scenes passed; Merger, Splitter, blocked-output recovery and full ore-to-ingot gameplay confirmed.** Legacy proximity retirement, measured physical-only conservation and destructive-event cargo recovery are explicitly deferred. See [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md). Earlier 08.3F sections are historical checkpoints.

### 1E.8 — Physical-Only Factory and Ammunition Production (2026-10-31)

- [x] Verify finite-deposit conservation through physically connected Extractor → Storage → Smelter → Storage, without legacy proximity movement (**9/9** Godot checks).
- [x] Add `Prototype Rounds` and a reusable `1 Test Ingot → 4 Prototype Rounds` recipe (temporary prototype ratio).
- [x] Add 2×2 Prototype Ammunition Press using existing producer/input/output components, independent inventories and physical conveyor ports (**9/9** isolated checks).
- [x] Register Ammunition Press in Build Mode slot **8**, with rotation, HUD selection and safe demolition (**9/9** integration checks).
- [x] Verify live production and physical delivery of Prototype Rounds to normal Test Storage (**6 rounds visible** in the user's HUD screenshot).
- [ ] Finalize ammunition balance, ammunition-specific cargo graphics and the turret's combat behavior.

**Status: Ammunition production and physical warehouse delivery developer-verified.** The old proximity components remain in source for compatibility, but their extractor/smelter scene nodes are disabled; retain them until the migration is fully documented and broader conservation coverage is complete.

### 1F — Enemy & Defense Prototype

**Defense foundation accepted:** The 1×1 ammunition-fed turret has a physical input port, 40-round magazine, guarded firing transactions, and cooldown. Both the isolated ammo regression (**10/10**) and main-scene Build Mode slot **9** regression (**12/12**) passed locally in Godot 4.6.2. The Debug HUD displays magazine quantity, port connection, readiness, cooldown and shot count. **Live ammunition connection now accepted (2026-11-01):** A normal gameplay screenshot showed the turret's ammunition conveyor connected and its magazine holding **9 / 40 Prototype Rounds** with `Status: Ready`, `Cooldown: 0.00 s`, and `Fired Shots: 0`. Automated turret targeting and instant-hit damage are integrated and were verified with the stationary target in both Godot regression tests and live gameplay. Visible projectiles, line of sight and moving-zombie encounters remain separate improvements.

- [x] Validate turret ammunition-only input, backpressure, firing/cooldown, conservation and demolition (**10/10** isolated regression).
- [x] Validate turret Build Mode slot 9, HUD, port placement, ammo input and connection cleanup (**12/12** local Godot regression).
- [x] Confirm physical delivery of factory-produced Prototype Rounds to a player-placed turret's magazine (**9 / 40 rounds, live HUD screenshot**).
- [x] Pass isolated turret targeting, cooldown, conservation and dummy damage regression (**12/12** in local Godot 4.6.2).
- [x] Validate the main-scene turret/hostile dummy combat integration (**11/11 passed locally in Godot 4.6.2**).
- [x] Validate automatic turret fire and visible target defeat during normal player-controlled gameplay (**TARGET DEFEATED** shown in user screenshot, 2026-11-01).
- [x] Validate main-scene automatic targeting and ammunition-dependent instant-hit damage in the isolated integration test (**11/11**).
- [x] Confirm the first regular-play combat victory against the stationary target (**TARGET DEFEATED** displayed); visible projectile simulation remains a later step.
- [x] Validate isolated moving-zombie approach, structure reacquisition and turret compatibility (**9/9** in local Godot 4.6.2).
- [x] Validate moving zombie integration in the main game (**12/12 local Godot tests passed**, Nov 1, 2026). Static target remains unchanged.
- [x] Manually verify the moving zombie approaches a placed Storage building and stops beside it in the playable main world (2026-11-01 screenshot; precise stop distance previously checked by automated tests).
- [x] Manually verify a physical-ammunition-fed turret defeats the moving zombie in the playable main world (user screenshot shows two separate **TARGET DEFEATED** labels; green zombie approached the newly placed turret).
- [ ] Add navigation toward player structures
- [x] Validate non-destructive BuildingHealthComponent and zombie melee damage (**12/12 local Godot tests passed**).
- [x] Validate 100 HP across eight player-buildable structure scenes, shared durability HUD, preserved stored cargo and zero-HP targeting (**11/11 passed in local Godot 4.6.2**).
- [x] Re-run the adjusted `tests/zombie_building_melee_test.tscn` after scene changes (**12/12 passed locally**).
- [x] Validate live zombie melee in the Main scene with durable factory buildings (**12/12 local Godot integration tests passed**).
- [x] Attach ZombieMeleeComponent to the playable moving zombie using 10 HP per attack and a one-second cooldown; validated in the Main-scene integration regression (**12/12**).
- [x] Confirm in regular gameplay that a moving zombie damages an Extractor to **0 / 100 HP**, with the building still present and **19 Test Ore** visible in its inventory (manual screenshot, 2026-11-01). The earlier 12/12 integration test specifically verified Storage stock and conveyor-link preservation; that was not independently visible in this latest screenshot.
- [x] Validate **actual Main-world building destruction at zero HP** using `res://tests/live_zombie_destruction_test.tscn` (**12/12 passed locally in Godot 4.6.2 on 2026-11-02**). The fatal tenth hit removes only the building, preserves neighboring belts and spawns salvage; failed recovery leaves the 0-HP structure intact for retry.
- [x] Confirm in regular F5 gameplay that a zombie destroys a player-placed structure and leaves visible wreckage while clearing the building HUD (**2026-11-02 screenshot: green zombie beside WRECKAGE**). The screenshot does not show a resource-filled cache; material accounting was established in earlier automated regressions.
- [x] Validate **Step 09.18F1: Independent conveyor durability** across straight, right-corner and left-corner shapes (**50 HP**, one cargo slot). `res://tests/conveyor_durability_foundation_test.tscn` passed **12/12 locally in Godot 4.6.2**.
- [x] Step 09.18F2: Validate zombies selecting, attacking and destroying straight/left/right conveyor segments in Main, with salvage, protected neighboring belts and safe recovery retry. `res://tests/live_zombie_conveyor_destruction_test.tscn` **12/12 passed locally in Godot 4.6.2 on 2026-11-02**, including the corrected diagonal retargeting arrival.
- [x] Step 09.18F3: Confirm in F5 gameplay that the moving zombie destroys placed conveyor sections and leaves visible **WRECKAGE**; screenshot shows two distinct wreckage placeholders near the green zombie (2026-11-02). The screenshot does not directly show independent neighbor-belt survival or recovered cargo; those were verified in the 12/12 automated belt-destruction suite.
- [x] Step 09.18F4: Validate **conveyor HP, cargo and connection display** for intact straight/left/right belts, dynamic damage/cargo updates, and automatic selected-belt HUD cleanup at destruction (`res://tests/conveyor_health_hud_test.tscn`, **12/12 passed in local Godot 4.6.2 on 2026-11-02**).
- [x] Step 09.18F5: Confirm in regular F5 gameplay that selecting a conveyor displays its health and logistics: screenshot shows a yellow-selected belt at **40/50 HP**, Intact, 0/1 cargo, and disconnected input/output, with the moving green zombie nearby (**2026-11-02**). Selected-object clearing on destruction was previously confirmed by the 12/12 HUD regression and F5 wreckage screenshots.
- [ ] Polish the conveyor HUD's automatically generated scene name (e.g. `@Node3D@10`) into a readable belt type/label during the planned UI pass.
- [x] Final regression Round 1 — moving enemy/combat compatibility: `prototype_moving_zombie_test.tscn`, `live_moving_zombie_integration_test.tscn`, `zombie_building_melee_test.tscn`, `live_zombie_melee_integration_test.tscn`. (all four suites passed locally in Godot 4.6.2, 2026-11-02).
- [x] Final regression Round 2 — factory/logistics compatibility: `conveyor_physical_only_conservation_test.tscn` (**9/9**), `ammunition_press_build_mode_test.tscn` (**9/9**), `defensive_turret_build_mode_test.tscn` (**12/12**). **All 30/30 checks passed in local Godot 4.6.2** (confirmed 2026-11-02).
- [x] Final regression Round 3 — destructive recovery/selection: `live_zombie_destruction_test.tscn`, `controlled_destruction_transaction_test.tscn`, `world_salvage_destruction_test.tscn`, and `live_zombie_conveyor_destruction_test.tscn` (**all 4 scenes and all 48/48 checks passed locally in Godot 4.6.2, confirmed 2026-11-02**).
- [x] Validate **lossless destruction cargo recovery** for Storage, multi-inventory manufacturing and cargo-bearing belts (`tests/destruction_cargo_recovery_test.tscn`: **12/12 passed locally in Godot 4.6.2**). Current test escrow uses 100% recovery as a temporary safe default, **not** final salvage balance.
- [x] Validate **controlled source removal after escrow** using `tests/controlled_destruction_transaction_test.tscn` (**12/12 passed locally in Godot 4.6.2**). Confirmed queued deletion, stopped processing, safe reciprocal disconnection, salvage capacity refusal, and unaffected neighboring belts.
- [x] Validate **Main-world surviving salvage placeholders** through `tests/world_salvage_destruction_test.tscn` (**12/12 passed locally in Godot 4.6.2**; 15/15 source items retained in five independent world caches). These caches are runtime-only and not yet player-pickable.
- [ ] Future follow-up: implement player collection and save/load persistence for wreckage salvage, plus resource-loss balancing. Current caches remain runtime-only; the accepted destruction milestone delivers lossless in-world salvage and safe removal, not pickup/persistence.
- [ ] Decide optional repair of damaged surviving structures and rebuilding/salvage for destroyed structures; **0-HP permanent disabled state is not the intended final gameplay**.
- [ ] Add basic defensive structure
- [ ] Add player/factory survival test

**Phase 1 Status: In Progress**

---

### 1G — Unlocked Building Catalog & Player-Customizable Build Hotbar (In Progress)

**Phase entry:** Step 09.18 building/conveyor destruction has passed three final regression rounds and F5 gameplay validation. Custom hotbar work is now underway. Its model and conveyor identity migration have been accepted, with 80/80 targeted conveyor regressions passed. Live number-key routing and dynamic HUD are newly implemented and awaiting the 1G3 Godot test; catalog UI and disk persistence are still future work.

- [x] **Phase 1G1 — Stable-ID hotbar foundation:** `res://tests/build_hotbar_configuration_test.tscn` passed **12/12** locally in Godot 4.6.2 (2026-11-02). Covers defaults, Turret → key 1, Storage → key 9, swaps, empty/locked slots, JSON payloads and catalog reordering.
- [ ] Add a Build Catalog menu listing all unlocked `BuildingDefinition` entries, organized by building category; handle locked entries explicitly.
- [x] **Phase 1G3 — Configurable live number keys and dynamic Build HUD:** `WorldInteraction` resolves 1–9 through stable building IDs and the HUD displays assignments, selection, and empty slots. `res://tests/build_hotbar_keyboard_integration_test.tscn` **12/12 passed locally in Godot 4.6.2 (confirmed 2026-11-04)**: Turret → 1, Storage → 9, Conveyor Belt → 4, empty/locked slots, and legacy defaults. First regression exposed a test-only autogenerated Turret preview node-name assumption, now corrected.
- [x] **Phase 1G3 F5 gameplay acceptance:** The developer confirmed that key **1–9 highlights switch correctly** in normal F5 gameplay (2026-11-04). Actual reassignment remains available in the model/API; player-editable controls are the next Build Catalog milestone.
- [ ] **Step 09.18G — Wreckage inspection and safe cleanup:** A discovered usability gap after F5 testing: world salvage had no selection hitbox, highlight, inventory HUD or cleanup. Implemented selectable Layer-2 wreckage, contents/status display and empty-only demolition; **12-case F6 test pending** at `res://tests/wreckage_selection_cleanup_test.tscn`. Stocked caches remain protected until player salvage collection is designed and tested.
- [ ] **Phase 1G4 — Unlocked Build Catalog menu:** Provide a selectable list of unlocked buildings, assign/swap/clear slots without affecting world placement, and later persist the configuration across sessions.
- [ ] Allow players to assign, swap, remove, and rearrange items in nine initial hotbar slots. Assigned number keys select the corresponding building while Build Mode is active.
- [x] **Phase 1G2 — Stable conveyor identity:** Replaced **22 hard-coded slot-5 comparisons** in `scripts/world_interaction.gd` with `_is_conveyor_selected()` checking `BuildingDefinition.building_id == "conveyor_belt"`. The developer confirmed `res://tests/conveyor_building_identity_test.tscn` **12/12 passed locally in Godot 4.6.2 (2026-11-04)**, including both corner variants with Conveyor Belt moved from definition index 4 to index 0, and negative tests for the former slot.
- [x] **Phase 1G2 regression Round A — Port snapping and corners (37 checks):** `conveyor_building_placement_snap_test.tscn` (8/8), `conveyor_receiver_auto_snap_test.tscn` (11/11), `conveyor_source_corner_auto_snap_test.tscn` (10/10), `conveyor_terminal_building_corner_test.tscn` (8/8). **37/37 passed locally in Godot 4.6.2 (2026-11-04).**
- [x] **Phase 1G2 regression Round B — Gap and bridge connectors (43 checks):** `conveyor_missing_corner_placement_test.tscn` (9/9), `conveyor_dual_ended_bridge_test.tscn` (11/11), `conveyor_fractional_bridge_test.tscn` (12/12), `conveyor_offset_corner_bridge_test.tscn` (11/11). **43/43 checks passed locally in Godot 4.6.2 (2026-11-04)**. Phase 1G2 closes with **80/80** targeted port, corner, snap and bridge regression checks.
- [ ] Complete a focused F5 default-key compatibility check; then make remapping available through the in-game Build Catalog so custom keys can be tested manually. Dynamic Build HUD and remapped corner previews passed the isolated 1G3 regression.
- [ ] Persist slot choices by stable `BuildingDefinition.building_id` and restore them on restart; validate changes against building unlock state.
- [ ] Add Godot regression coverage for slot customization, swaps, locked building refusal, controller/keyboard input, menu focus, saves/reloads, and previously passed conveyor tests.

**Scope:** UI/input and persistence only. The catalog model is not yet wired to the playable game; keep the current fixed shortcut system in place until placement, HUD and saving are individually validated. The accepted destruction milestone remains unchanged.

---

### Phase 1G6 — Building Catalog Expansion (Checkpoint 1)

- [x] Organize unlocked Building Catalog dropdown options by `BuildingDefinition.category` without altering stable-ID assignments.
- [x] Add `tests/build_catalog_category_test.tscn` to check grouped entries, assignment swaps, and Restore Defaults.
- [x] Validate category regression in Godot 4.6.2 (**3/3 checks passed**, 2026-11-06) and confirm the categorized M-menu dropdowns during regular F5 gameplay.
- [ ] Evaluate future building expansion only after reviewing vertical-slice priorities. Splitter and Merger physical routing are already implemented.
- [ ] Keep unlock/research progression and per-save settings with future main save/load architecture.

**Status: Checkpoint 1 complete — automated and manual validation confirmed.**

---

## Phase 2 — Zombie Colony Prototype

**Goal:** Combine factory automation and defense into a playable scenario.

Planned systems:

- small abandoned settlement
- zombie spawning zones
- resource extraction
- production chain
- defensive perimeter
- day/night progression
- increasing enemy pressure
- basic player progression
- factory expansion decisions

---

## Phase 3 — First Night Vertical Slice

**Goal:** Create the first polished, showcase-ready gameplay experience.

The player should be able to:

1. Enter a hostile colony world.
2. Explore the immediate area.
3. Locate useful resources.
4. Establish a small industrial base.
5. Build a basic production chain.
6. Prepare defensive structures.
7. Survive the first major zombie attack.

This milestone should feel like a small but complete version of the larger game concept.

---

## Phase 4 — Expansion

After the First Night vertical slice is stable, evaluate:

- larger factory systems
- more complex logistics
- additional zombie types
- abandoned towns and cities
- vehicle systems
- technology progression
- larger maps
- additional planets
- different enemy factions
- advanced warfare systems
- performance optimization

---

## Current Position

Completed:

- Phase 0 foundation
- Phase 1A camera/player interaction foundation
- Phase 1B factory/production foundation
- Phase 1C resource nodes, deposit-aware extraction, and placement validation
- Phase 1D (Chat 05) capacity-aware inventories, dedicated storage, direct automatic transfers, and storage/logistics debugging
- Phase 1E (Chat 06) guarded recipe-based manufacturing, two-inventory Test Smelter, stocked-storage input logistics, progress/status feedback, and successful conservation/regression testing

**Chat 07 recipe, machine-port and straight-conveyor checkpoints completed:** Recipe controls (**21/21** checks), safe manual machine-port handoffs (**29/29**) and buildable, snapped straight conveyor links (**40/40**) have developer-reported passing regression tests, alongside earlier manufacturing (**36/36**) and inventory/gameplay tests. Tested conveyor code was pushed to main. Details: Phase 1E.1–1E.3 and [ARCHITECTURE.md](ARCHITECTURE.md).

**Chat 07.5 checkpoint:** In-place left/right corner conversion, yellow arrows, visual L-shaped placeholders and tested connection/demolition behavior remain working.

**Accepted milestone (Chat 08.3G-3K, 2026-10-30):** Player-built physical belts, corners, variable-length connectors, uniform cargo pacing, shared grid and 1×1 Merger/Splitter are implemented on GitHub `main`. **All 20 final individual manual Godot test scenes passed**. The Splitter's live HUD recorded **13 routed items (5/4/4)**, the three-input Merger worked in gameplay, and the developer confirmed downstream backpressure/recovery and the complete ore-to-ingot factory chain. Exact live Merger per-lane counters were not captured, and safe retirement of legacy proximity scripts still requires a physical-only conservation test. Details: [CHAT_08_FINAL_REGRESSION.md](CHAT_08_FINAL_REGRESSION.md).

**Current next step (2026-11-01):** The live physical ammo chain into the turret magazine is accepted (**9 / 40 rounds**). Turret ammo-only (**10/10**), Build Mode (**12/12**), and isolated targeting/damage (**12/12**) regressions have passed locally. The player-buildable turret now has the ammo-gated targeting script, and a stationary 30-HP target is in the main world at **(-6, 0, -6)**. The `tests/live_turret_combat_integration_test.tscn` regression has now passed **11/11**, confirming main-scene targeting, belt-fed ammo, hits and defeated-state UI. Player-controlled live combat is accepted: the developer's screenshot shows the stationary dummy's **TARGET DEFEATED** state next to the ammunition-fed turret and factory conveyors. Shot counters were not visible in the screenshot; those were separately verified by the **11/11** main-scene regression. The `res://tests/live_moving_zombie_integration_test.tscn` integration suite passed **12/12** locally after the isolated movement suite passed **9/9**. The developer visually confirmed the moving zombie approaching and stopping beside player-built Storage in regular gameplay. The live moving-enemy encounter is now accepted: the moving zombie approached a newly placed turret, and the user screenshot shows both the original stationary target and the moving zombie defeated. The isolated BuildingHealth/ZombieMelee suite passed **12/12**. Eight player-buildable structure scenes now carry 100 HP and the Production Debug HUD displays it. The `res://tests/building_health_integration_test.tscn` scene passed **11/11** in local Godot 4.6.2, including cargo/port preservation and shared durability HUD. The adjusted isolated melee regression passed **12/12** after universal building health was added. The Main moving-zombie scene now includes ZombieMeleeComponent with 10 damage and a 1-second cooldown; `res://tests/live_zombie_melee_integration_test.tscn` passed **12/12** locally in Godot, validating melee, health, inventory and port preservation, and target reassignment. At zero HP structures currently remain present with cargo and ports intact **only as a testing safeguard**. The confirmed final design is that structures and conveyor sections can be destroyed, with safe local disconnection, cargo resolution and appropriate wreckage. Destroying one component must not remove an entire otherwise-undamaged belt network. Live zombie melee is regression-validated. Manual F5 gameplay acceptance is complete using a Test Extractor: the moving zombie reduced it to **0 / 100 HP**, and its HUD showed **Disabled** without deleting the building. Its production status separately still read **Extracting**, so automatic operational shutdown is the next implementation goal. A separate moving zombie is now placed in Main at **(8, 0, -7)**, and the static dummy remains at **(-6, 0, -6)**. Pathfinding and collision avoidance remain unimplemented; zombie melee has passed the dedicated integration regression and awaits manual gameplay validation. Zombie movement, spawned waves, projectile visuals, building damage, cargo recovery, slotted storage and persistence remain follow-ups.


---

### Phase E3d5a — Blueprint Construction Priorities and Waiting Queue (2026-11-10)

- [x] Add High / Normal / Low priority metadata to authorized construction jobs without changing their completion time, power/material/worker requirements, or physical factory behavior.
- [x] In sandbox Blueprint Selection Mode (Q), press **H**, **N**, or **L** to assign the selected planned sites to High, Normal, or Low priority. E and Ctrl+E keep their existing authorization behavior.
- [x] Add a stable waiting queue: **High → Normal → Low**, FIFO within each priority. Construction jobs enter only if their state is genuinely QUEUED; constructed/started/cancelled sites are pruned.
- [x] Show selection priority counts, pending queue length and next queued job in the Factory Blueprints HUD.
- [x] Retain sandbox's explicit debug requirement override: it still starts test construction immediately. Priority **does not** fabricate workers, reserve materials, create power, or throttle work before the worker system exists.
- [x] **Godot F6 validation:** `res://tests/blueprint_construction_priority_e3d5a_test.tscn` — **15/15 checkpoints passed** (developer screenshot, 2026-11-10).
- [x] Manual sandbox Q → select → H/N/L priority assignment validated (developer screenshot, 2026-11-10): six selected planned Storage blueprints, priority mix **H 2 | N 2 | L 2**, waiting queue 0 as expected before authorization. Selected-only E authorization was already covered by automated regression; a separate manual post-E construction screenshot has not been supplied.
- [ ] Implement actual finite worker-drone dispatch, real availability providers, power/material checks and progression only after isolated tests. Don't enable the new queue in Main until those requirements exist.

**Status: E3d5a priority assignment accepted — 15/15 automated checks and manual six-blueprint H2/N2/L2 assignment verified. Actual finite worker dispatch remains future scope.**



### Phase E3d5b — Finite Construction Worker Slots (Foundation; 2026-11-10)

- [x] Add `BlueprintConstructionSlotScheduler` as an isolated finite-capacity scheduler with explicit slot configuration (1–16).
- [x] Order eligible authorized jobs by **High → Normal → Low**, with stable registration-order ties; allow jobs blocked by power/material availability to remain waiting without consuming slots.
- [x] Keep active jobs non-preemptive when a higher-priority job joins the queue; when readiness is lost, pause while retaining progress and release the worker slot.
- [x] Resume paused work when readiness and a slot are available; completion/cancellation releases the slot and allows the next eligible job to start.
- [x] Add `res://tests/blueprint_construction_slots_e3d5b_test.tscn` (15 checks covering capacity, priority, explicit readiness, no-preemption, pause/resume, completion/cancellation, and isolation).
- [x] **Godot F6 verification passed (15/15)** on 2026-11-10 (developer-provided output screenshot). This is an **isolated test-only service**; not instantiated in Main or the regular Factory Testing Sandbox and has no physical worker drones.
- [ ] Next: real power and delivered-material readiness providers; assign finite physical worker-drone availability only after those services have their own regressions.

**Status:** E3d5b isolated scheduler accepted — **15/15 automated checks passed**. Real readiness providers and physical drone dispatch are future milestones; existing E3d5a UI and normal gameplay are unchanged.


### Phase E3d5c1 — Read-Only Construction Readiness Probe (Staged; 2026-11-10)

- [x] Add an isolated `BlueprintConstructionReadinessProbe` that accepts only authorized live sites; unknown/malformed power reports fail closed.
- [x] Check a caller-provided, nonempty construction bill of materials against a real live `InventoryComponent`; report shortages per `ItemDefinition`, and reject invalid costs.
- [x] Keep inventory, jobs, construction progress, authorization and worker slots untouched. **Sufficient warehouse stock is NOT a material reservation** and must never be forwarded to the E3d5b scheduler as `materials_ready=true`.
- [x] Stage 15 scripted safety checks in `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn`, including shared-stock double-count prevention by refusing dispatch.
- [ ] **Godot 4.6.2 F6 acceptance pending:** developer screenshot/log of all 15 checks with no parser/runtime errors.
- [ ] E3d5c2: define real per-building construction costs and implement atomic material reservation/escrow with release/recovery on cancellation, and conservation tests. A distinct real power-coverage provider must be validated before worker dispatch.
- [ ] E3d5c3: integrate the verified power provider + reservation ownership with E3d5b finite scheduler behind a sandbox-only opt-in. Do not enable this in Main or remove the sandbox debug override until regression-tested.
- [ ] Future construction management UI: clickable priority, authorize, cancel and queue buttons, retaining H/N/L and other shortcuts as optional alternatives.

**Boundary:** This checkpoint is a read-only observation utility, not a source of actionable construction readiness. Factory Testing Sandbox and Main scenes are unchanged.

### E3d5c1 — Accepted (2026-11-11)

- [x] **15/15 Godot 4.6.2 F6 tests passed** (PASS A–O), confirmed by developer screenshot for `res://tests/blueprint_construction_readiness_e3d5c1_test.tscn`. No new errors visible in Output.

### E3d5c2a — Atomic Material Escrow Foundation (Staged; F6 Pending)

- [x] Isolated one-inventory, one-site ledger: valid authorized QUEUED sites can atomically reserve positive integer construction bills, with no debit on invalid or insufficient bills.
- [x] Repeated and competing reservations cannot double-debit physical inventory. Source items are held in escrow, not only inspected.
- [x] Site cancellation or unexpected removal attempts an exact refund. If the original inventory is full/unavailable, a stable ID retains held items for alternative recovery; refund never deliberately drops items.
- [x] Only a job whose real structure has activated can commit/consume its escrow once.
- [x] New isolated `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` with **16 A–P checks pending developer F6 validation**.
- [ ] E3d5c2b: definition-owned real construction bills, cost balancing and missing-data rejection.
- [ ] E3d5c3: verified power coverage and sandbox-only scheduler integration after independently tested reservation ownership.
- [ ] Clickable priority/authorize/cancel and queue UI in a later phase, retaining keyboard alternatives.

**Safety boundary:** No changes to Main, Factory Testing Sandbox, conveyor logistics, combat, live construction, or the explicit sandbox-only debug readiness override. Physical drones and save/load of escrow are not yet implemented.

### E3d5c2a — Construction Material Escrow Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: 16/16 tests A–P passed**, confirmed by developer Output screenshot from `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn`. No errors visible in supplied Output.

### E3d5c2b — Definition-Owned Construction Material Costs (Staged; F6 Pending)

- [x] Reuse existing `ItemAmount` data type: `BuildingDefinition.construction_materials: Array[ItemAmount]`.
- [x] Add provisional Test Ore/Test Ingot construction bills to all nine existing `data/buildings/*.tres` resources. Original construction durations and building scenes remain unchanged. These prototype numbers are not final game balance.
- [x] Add read-only `ConstructionMaterialBill.inspect()/get_costs()` for valid, nonempty, positive, unique item bills. Missing/invalid costs fail closed.
- [x] Stage `res://tests/blueprint_construction_costs_e3d5c2b_test.tscn`, **17 tests A–Q**, including escrow ownership, competing jobs, refunds, paused construction, and successful completion.
- [ ] **Local Godot 4.6.2 F6 verification pending.** Do not connect this bill resolver to live construction until accepted and power/material dispatch contracts are tested.
- [ ] Next: validated power coverage, per-site escrow-to-scheduler adapter, and Main Hub initial inventory/bootstrap. Future clickable construction controls will supplement H/N/L keyboard shortcuts.

**Isolation:** Existing WorldInteraction, Main, Factory Testing Sandbox, conveyor logistics, combat, production recipes and sandbox debug readiness override are unchanged. Construction materials are metadata in regular sandbox play; player building authorization does not yet debit them.

### E3d5c2b — Definition Construction Costs Accepted (2026-11-11)

- [x] **All 17/17 Godot 4.6.2 F6 checks passed** (A–Q), confirmed by developer Output screenshot. Nine definition-owned cost bills validate, existing build durations are retained, malformed bills fail closed, escrow refunds cannot double-spend, and construction pause/finish conserves time and materials. No errors visible in supplied Output.

### E3d5c3a — Isolated Explicit Power Network and Footprint Coverage (Staged; F6 Pending)

- [x] Stage `ConstructionPowerNetworkNode` as an opt-in, offline-by-default node for a future completed Main Hub/Power Pole. Explicit `operational`, `is_source`, and `source_online` states are controlled by the test fixture only for now, **not** by a real power provider.
- [x] Stage `ConstructionPowerCoverageNetwork`: links are explicit, range-checked graph edges, never inferred from overlapping construction coverage circles. Energized status requires an operational live source and a valid connected path; disconnected, disabled, moved or deleted relays fail closed.
- [x] A construction site is covered only when **one energized node covers all four actual rotated footprint corners**. This intentionally conservative rule avoids partial-footprint false positives; planned sites can be previewed without authorizing construction.
- [x] Stage `res://tests/construction_power_coverage_e3d5c3a_test.tscn` with **16 A–P isolated checks** for offline sources, link requirements, outage, physical relay loss, multi-relay chains, rotation, and no implicit worker/material/time grants.
- [ ] **Godot 4.6.2 F6 validation pending.** Review developer screenshot/errors before integrating power with materials and scheduling.
- [ ] Future E3d5c3b: actual completed Hub/Power Pole ownership, generator availability, and energy budget/supply-demand rules. E3d5c3c: escrow-backed scheduler integration behind a sandbox-only opt-in, tested with power loss and restoration.
- [ ] UI buttons and Main Hub drone charging remain separate future checkpoints.

**Safety boundary:** This is *topology and construction coverage only*, using synthetic fixture power states. It does not create actual electrical energy, allocate consumer demand, produce charging or authorize jobs. No edits to WorldInteraction, Main, Factory Testing Sandbox, cargo, combat, or debug construction override.

### E3d5c3a — Power Topology Accepted (2026-11-11)

- [x] **All 16/16 Godot 4.6.2 F6 checks A–P passed**, confirmed by developer Output screenshot. Verified explicit links, disconnected/disabled/moved/destroyed relays, generator outage, complete rotated footprint coverage, and no automatic worker/material/time grants. No new errors visible in Output.

### E3d5c3b1 — Completed Power Structure Ownership (Staged; F6 Pending)

- [x] Stage **isolated prototype scenes** for a *prebuilt* Main Hub generator and a player-constructible-but-not-yet-listed Power Pole relay. The pole definition includes a 6-second construction timer and 2 Test Ingot provisional cost.
- [x] Add `PrototypePowerStructure` runtime: completed physical structure health, service enable and generator enable determine its child `ConstructionPowerNetworkNode.operational` and `source_online` state. The Main Hub starts with a **12-unit nameplate generation rating**; the pole generates **zero** and must receive power via an explicit link.
- [x] Planned/queued/half-built poles have NO electrical node; `ConstructionSite` adds the actual physical relay scene only after all construction job gates and its timer complete. Damaged/depleted structures stay offline even when toggled back on.
- [x] Keep topology fail-closed when an existing power structure parent is queued for deletion; no immediate ghost electricity.
- [x] Stage `res://tests/completed_power_structures_e3d5c3b1_test.tscn` with **16 A–P scripted checks**, including construction lifecycle, generator and pole shutdown, health destruction, parent removal, explicit links and no job-readiness bypass.
- [ ] **Godot 4.6.2 F6 acceptance pending.** Also rerun E3d5c3a 16/16 when this checkpoint passes to ensure topology compatibility.
- [ ] Next: capacity-limited **real energy allocation** (generator rating vs consumer demand), outage/recovery, explicit link provenance; then opt-in escrow-backed worker scheduler integration. Starter Hub scene placement in actual gameplay remains future scope.
- [ ] Clickable priority/authorize/queue controls and drone charging remain future work.

**Isolation:** Main and Factory Testing Sandbox remain untouched; neither new scene appears on the build hotbar. The Hub's fixed rating is **not** an energy-demand allocator, and prototype operational flags must NOT be used as verified construction power readiness until allocation, ownership, and coordinator tests pass.

### E3d5c3b1 — Completed Power Structures: Dedicated F6 Passed (2026-11-11)

- [x] Developer Godot 4.6.2 screenshot confirms **all 16/16 A–P checks passed** in `res://tests/completed_power_structures_e3d5c3b1_test.tscn`.
- [x] Verified Hub source online state, physical pole activation only after construction completion, generator/service shutdown, relay health depletion, queued-for-removal protection and unchanged construction job gates.
- [ ] **Compatibility gate remains outstanding:** rerun `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) after the new owning-parent deletion guard. Do not proceed to energy demand allocation until compatibility is confirmed.

### E3d5c3b1 — Completed Power Structures: Compatibility Accepted (2026-11-11)

- [x] **Post-implementation E3d5c3a regression: 16/16 A–P PASSED** in developer Godot 4.6.2 screenshot, with no errors visible in Output.
- [x] Together with the separate E3d5c3b1 16/16 acceptance, **32/32 power topology and completed-structure checks passed** on the current implementation.

### E3d5c3b2 — Finite Construction Power Budget Prototype (Staged; F6 Pending)

- [x] Add read-only `ConstructionPowerCoverageNetwork.get_operational_component()`, traversing explicit valid power links without granting permission or assuming sources exist.
- [x] Add isolated `PrototypeConstructionPowerAllocator`: sum **online, intact, completed `PrototypePowerStructure` nameplate ratings** per connected component. Offline, destroyed, disconnected, or bare/synthetic test nodes supply **zero** available generation.
- [x] Require an authorized live `ConstructionSite`, explicit positive integer-like demand in prototype service, and full rotated footprint coverage by an energized relay. Only grant whole demands; total allocations cannot exceed that component's current rating.
- [x] Preserve active `CONSTRUCTING` jobs first (non-preemptive), then High → Normal → Low with stable FIFO ordering for waiting sites. Recompute as generator output, topology, health, and requests change. Power allocations are observations only and do **not** change `ConstructionJob`, actual inventory, escrow, worker slots, or timers.
- [x] Stage `res://tests/finite_construction_power_e3d5c3b2_test.tscn` with **18 checks A–R**, including real completed sources, bounded demand, queued priorities, active-work preference, generator outage, multiple disconnected/connected sources, link loss, fake-source rejection, cancellation, and health depletion.
- [ ] **Godot 4.6.2 F6 validation pending.** Then rerun E3d5c3a (16 checks) and E3d5c3b1 (16 checks) to validate the additive topology API.
- [ ] Next: define production demand and realistic energy accounting (fuel/consumption, charging budgets), then a fail-closed sandbox-only coordinator using **per-site escrow ownership**, verified power allocation, and E3d5b worker slots. No Main integration until all component tests and regressions pass.

**Safety:** This stage allocates prototype *nameplate budget*, NOT measured generated energy; no live supply/fuel model or persistent power reservation exists yet. The new allocator is never instantiated by Main or the Factory Testing Sandbox. No gameplay power, materials, worker service, or existing debug bypass is changed.

### E3d5c3b2 — Test-Q Harness Fix (2026-11-11; Retest Pending)

- [x] Investigate developer F6 debugger error at line 216 of `finite_construction_power_e3d5c3b2_test.gd`: an already-freed `ConstructionSite` was passed into a typed allocator method.
- [x] Replace invalid post-`free()` call with a `WeakRef` validity assertion and before/after count of allocation entries; verify surviving Normal allocation remains five power units. **Only isolated test and documentation changed**.
- [ ] Rerun `res://tests/finite_construction_power_e3d5c3b2_test.tscn` — 18 checks A–R pending. Do not mark E3d5c3b2 accepted based on the failed first run.
- [ ] After successful retest, rerun E3d5c3a and E3d5c3b1 topology/structure tests to protect the current 32/32 compatibility baseline.

### E3d5c3b2 — Finite Power Allocation Dedicated F6 Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: all 18/18 checks A–R passed**, confirmed in developer-provided Output screenshot after correcting the test-Q use-after-free. No errors visible in the supplied Output.
- [x] Verified 12-unit nameplate budget limits, all-or-nothing construction demands, active job non-preemption, priority queue preference, explicit shared-versus-independent grids, outage and destruction behavior, fake source rejection, and release of cancelled/freed site allocations.
- [ ] **Compatibility regression still required on the current code:** `res://tests/construction_power_coverage_e3d5c3a_test.tscn` (16 checks) and `res://tests/completed_power_structures_e3d5c3b1_test.tscn` (16 checks). Prior passes are not a substitute for rerunning after E3d5c3b2's topology API changes.
- [ ] Only then proceed to the next isolated checkpoint connecting verified power, actual per-site material escrow, and finite worker-slot scheduling. Do not enable the new systems in Main or remove the sandbox debug override until integrated regressions pass.

**Status:** E3d5c3b2 dedicated allocator test accepted **18/18**, but full compatibility milestone pending **32 power regression checks**. Allocation is still a prototype nameplate-demand observation, not measured energy delivery.

### E3d5c3b2 — Full Power Regression Accepted (2026-11-11)

- [x] **E3d5c3a post-change compatibility 16/16 passed**, confirmed by developer Godot 4.6.2 Output screenshot (A–P).
- [x] **E3d5c3b1 post-change compatibility 16/16 passed**, confirmed by separate developer Godot 4.6.2 Output screenshot (A–P).
- [x] With E3d5c3b2's dedicated **18/18**, all **50/50 relevant power checks** passed on the current implementation; no errors visible in either new screenshot.
- [x] E3d5c3b2 accepted as an isolated finite *nameplate-budget* allocator (not measured electrical delivery or live construction authority).

### E3d5c3c1 — Isolated Power/Materials/Workers Readiness Coordinator (Staged; F6 Pending)

- [x] Add an opt-in `BlueprintConstructionReadinessCoordinator` that composes the already-tested `ConstructionMaterialBill`, `BlueprintConstructionMaterialEscrow`, `PrototypeConstructionPowerAllocator`, and finite `BlueprintConstructionSlotScheduler`, without modifying their existing dispatch logic.
- [x] Restrict registration to freshly authorized, fully gated `QUEUED` jobs with valid building material bills and positive finite prototype power demands. Debug/bootstrap-gate bypasses cannot register.
- [x] Reconcile in a deliberate sequence: **High → Normal → Low** material reservation (existing active work protected), then request finite power **only for owned escrow bills**, then pass verified flags to the existing worker scheduler. All-or-nothing material escrow prevents double spending; jobs without materials do not occupy a power allocation.
- [x] Keep active jobs non-preemptive; outages pause and release worker slots, preserve material escrow and construction progress, and allow queued/paused jobs to resume when resources return. Completion commits escrow; cancellation refunds. No automatic timer advancing occurs in the coordinator.
- [x] Stage `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn` with **18 A–R F6 checks** spanning scarce materials, priority ordering, worker caps, no preemption, cancellation, power outage/recovery, timed completion and material conservation.
- [ ] **Run the 18-check F6 scene and review errors/screenshots before enabling any integration in Factory Testing Sandbox.**
- [ ] After acceptance, run E3d5b finite-worker (15), E3d5c2a escrow (16), and E3d5c3b2 power allocator (18) regressions. UI buttons, save/load, starter stock and physical drones remain future phases.

**Hard safety boundary:** This coordinator is **not** instantiated in Main or the Factory Testing Sandbox and still relies on prototype generator **nameplate ratings**, not measured generation. It is an isolated integration test, not player-facing construction enforcement. Neither normal sandbox debug readiness nor logistics/combat code is changed.

### E3d5c3c1 — Integrated Readiness Coordinator Accepted (2026-11-11)

- [x] **Godot 4.6.2 F6: 18/18 A–R tests PASSED** in `res://tests/construction_readiness_coordinator_e3d5c3c1_test.tscn`, verified by developer-supplied Output screenshot. No new errors visible in Output.
- [x] Isolated test confirms complete material escrow before power requests, actual power allocation before finite workers, priority ordering, non-preemption, pause/resume, cancellation refund, completed building activation, and conservation of test items.
- [ ] **Compatibility acceptance pending:** rerun `res://tests/blueprint_construction_slots_e3d5b_test.tscn` (15 checks), `res://tests/blueprint_construction_material_escrow_e3d5c2a_test.tscn` (16 checks), and `res://tests/finite_construction_power_e3d5c3b2_test.tscn` (18 checks), for **49 regression checks**. Prior passes predate the isolated coordinator.
- [ ] Do not attach the coordinator to Factory Testing Sandbox/Main or remove the explicit sandbox debug requirement override until compatibility checks and live integration prerequisites (save/load escrow recovery, source validity, Main Hub starter inventory, actual energy/charging, construction UI and world destruction) have been resolved.

**Status:** E3d5c3c1 dedicated integration F6 is **accepted 18/18**, but post-change **49/49 compatibility regression verification remains outstanding**. Finite allocation still derives from prototype nameplate ratings, not metered real power.
